require 'optparse'

def parse_command_line_arguments
    options = { p: 30 }

    OptionParser.new do |opts|
        opts.banner = "Usage: ruby schelling.rb -f FILE [options]"

        opts.on('-f FILE', 'Input file (required)') do |f|
            raise "File missing" unless File.exist?(f)
            options[:f] = f
        end

        opts.on('-p NUMBER', 'Satisfaction threshold (0-100)') do |p|
            options[:p] = Integer(p).tap { |n| raise "Invalid p" unless (0..100).cover?(n) }
        end

        opts.on('-s NUMBER', 'Max simulation steps') do |s|
            options[:s] = Integer(s).tap { |n| raise "Steps must >0" if n <= 0 }
        end

        opts.on('-h', 'Show help') do
            puts opts
            exit
        end
    end.parse!

    raise "Missing -f" unless options.key?(:f)
    options

rescue => e
    puts "Error: #{e.message}"
    exit(1)
end
