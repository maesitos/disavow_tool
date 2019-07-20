require 'optparse'

module DisavowTool
  module Parameters
    OPTIONS = {}
    OptionParser.new do |opts|
      opts.banner = "Usage: disavow.rb [options]"
      opts.separator ""
      opts.separator "Optional options:"
      opts.on("--whitelist file1,file2,f3", Array, "Enter any number of whitelisted files",
                                                   "whitelisted files must have one URL per line") do
        OPTIONS[:whitelist] = true
      end

      opts.on("-v", "--verbose", "Vervose mode") do
        OPTIONS[:verbose] = true
      end
      opts.on("-V", "--tought-vervose", "Even more verbose") do
        OPTIONS[:hardcore_verbose] = true
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

    end.parse!
  end
end
