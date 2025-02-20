require_relative 'io'
require_relative 'schellingSimulation'

begin
    args = parse_command_line_arguments
    puts "Parsed arguments: #{args}"

    simulation = SchellingSimulation.new(args[:f], args[:p], args[:s])
    simulation.run
    
rescue => e
    puts "Runtime error: #{e.message}"
    exit(1)
end
