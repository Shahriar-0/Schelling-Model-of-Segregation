class SchellingSimulation
    def initialize(input_file, p_threshold = 30, max_steps = nil)
        @grid = load_grid(input_file)
        @p = p_threshold
        @max_steps = max_steps
        @steps = 0
        @rows = @grid.size
        @cols = @grid[0].size
    end

    def run
        clean_pics
        loop do
            unhappy_agents = find_unhappy_agents
            break if unhappy_agents.empty? || (@max_steps && @steps >= @max_steps)

            generate_iteration_picture(@steps)
            move_unhappy_agents(unhappy_agents)
            @steps += 1
        end
        generate_iteration_picture(@steps)
        generate_gif
    end

    private

    def clean_pics
        Dir.glob("pics/*.ppm").each { |file| File.delete(file) }
    end

    def unhappy_empty?(unhappy_empty)
        return unhappy_empty.reject { |cell| empty_cell?(cell[0], cell[1]) }.empty?
    end

    def load_grid(file_path)
        grid = File.readlines(file_path).map do |line|
        row = line.chomp.chars
        row.each do |cell|
            unless ['R', 'B', 'E'].include?(cell)
            raise "Invalid cell character '#{cell}' in input file"
            end
        end
        row
    end

    row_lengths = grid.map(&:size)
    if row_lengths.uniq.size != 1
      raise "Invalid grid format: All rows must have equal length"
    end

    return grid

    rescue Errno::ENOENT => e
        raise "Input file not found: #{file_path}"
    rescue => e
        raise "Error loading grid: #{e.message}"
    end

    def find_unhappy_agents
        unhappy = []
        @grid.each_with_index do |row, i|
            row.each_with_index do |cell, j|
                unhappy << [i, j] if unhappy?(i, j) && !empty_cell?(i, j)
            end
        end
        return unhappy
    end

    def find_unhappy_empty_agents
        unhappy_empty = []
        @grid.each_with_index do |row, i|
            row.each_with_index do |cell, j|
                unhappy_empty << [i, j] if unhappy?(i, j) || empty_cell?(i, j)
            end
        end
        return unhappy_empty
    end

    def empty_cell?(row, col)
        return @grid[row][col] == 'E'
    end

    def unhappy?(row, col)
        total = 0
        different = 0

        [-1, 0, 1].each do |i|
            [-1, 0, 1].each do |j|
                next if i == 0 && j == 0

                next if row + i < 0 || row + i >= @rows
                next if col + j < 0 || col + j >= @cols

                total += 1
                different += 1 if @grid[row][col] != @grid[row + i][col + j] && !empty_cell?(row + i, col + j)
            end
        end

        return (different.to_f / total) * 100 > @p
    end

    def move_unhappy_agents(unhappy_empty_agents)
        unhappy_empty_agents.shuffle!

        unhappy_empty_agents.each_slice(2) do |group|
            if group.size == 2
                cell1, cell2 = group
                @grid[cell1[0]][cell1[1]], @grid[cell2[0]][cell2[1]] = @grid[cell2[0]][cell2[1]], @grid[cell1[0]][cell1[1]]
            end
        end
    end

    def generate_iteration_picture(step)
        display_cols = @cols * 10
        display_rows = @rows * 10

        File.open("pics/iteration#{step}.ppm", "w") do |file|
            file.write("P3\n#{display_cols} #{display_rows}\n255\n")
            @grid.each do |row|
                10.times do
                    row.each do |cell|
                        10.times do
                            if cell == 'R'
                                file.write("255 0 0 ")
                            elsif cell == 'B'
                                file.write("0 0 255 ")
                            else
                                file.write("255 255 255 ")
                            end
                        end
                    end
                    file.write("\n")
                end
            end
        end
    end

    def generate_gif
        system("convert -delay 100 -loop 0 pics/*.ppm schelling.gif")
    end
end
