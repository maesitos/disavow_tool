require 'optparse'
require 'ostruct'

module DisavowTool
  class Commands
    def self.parse_inputs
       Commands.new.parse(ARGV)
    end

    def parse(args)
      options = OpenStruct.new
      options.library = []
      options.whitelist  = false
      options.verbose = false
      options.hardcore_verbose = false

      opt_parser = OptionParser.new do |opts|
          opts.banner = "Usage: disavow.rb [options] --disavow FILE --import file_1,file_2,file_3 [--whitelist file1,file2,file3]"
          opts.separator ""
          opts.separator "Requited options:"
          opts.on("-d","--disavow FILE", Array, "Disavow file as exported from Google Search Console") do |file|
            options.disavow_file = file
          end
          opts.on("-i","--import file_1,file_2", Array, "List of URLS to analyse. The file must have one URL per line") do |file|
            options.import_files = file
          end

          opts.separator ""
          opts.separator "Optional options:"
          opts.on("--whitelist file1,file2,file3", Array, "Enter any number of whitelisted files",
                                                       "whitelisted files must have one URL per line") do |file|
            options.whitelist  = true
            options.whitelist_files  = file
          end

          opts.on("-v", "--verbose", "Vervose mode") do
            options.verbose = true
          end
          opts.on("-V", "--hardcore-vervose", "Print out even your mama") do
            options.hardcore_verbose = true
            options.verbose = true            # Hardcose verbose includes regular verbose
          end

          opts.separator ""
          opts.separator "Common options:"
          # No argument, shows at tail.  This will print an options summary.
          opts.on_tail("-h", "--help", "Show this message") do
            puts opts
            exit
          end
          opts.on_tail("--version", "Show version") do
            puts VERSION
            exit
          end
      end

      opt_parser.parse!(args)
      options
    end
  end

  OPTIONS = Commands.parse_inputs
end
