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
      options.network_requests = true

      opt_parser = OptionParser.new do |opts|
          opts.banner = "Usage: disavow_tool [options] --disavow file_1,file_2,file_3 --import file_1,file_2,file_3 [--whitelist file1,file2,file3]"
          opts.separator ""
          opts.separator "Requited options:"
          opts.on("-d","--disavow file_1,file_2", Array, "Disavow files as exported from Google Search Console") do |file|
            options.disavow_files = file
          end
          opts.on("-i","--import file_1,file_2", Array, "List of URLS to analyse. The file must have one URL per line") do |file|
            options.import_files = file
          end

          opts.separator ""
          opts.separator "Optional options:"
          opts.on("-w", "--whitelist file1,file2,file3", Array, "Enter any number of whitelisted files",
                                                       "whitelisted files must have one URL per line") do |file|
            options.whitelist  = true
            options.whitelist_files  = file
          end

          opts.on("-v", "--verbose", "Vervose mode") do
            options.verbose = true
          end

          opts.on("-t", "--no-titles", "Don't request tittles from websites thus making the command faster") do
            options.network_requests = false
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
      check_arguments(options)
      options
    end

    def check_arguments(options)
      raise "You must to specify one disallow file" if options.disavow_files.blank?
      raise "You must to specify one import file" if options.import_files.blank?
      if options.whitelist
        raise "You need to specify at least one white list file" if options.whitelist_files.blank?
      end
    end

  end

  OPTIONS = Commands.parse_inputs

end
