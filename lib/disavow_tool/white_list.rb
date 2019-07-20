require_relative 'list'
module DisavowTool
  class WhiteList < List
    def initialize(import_file=nil)
      raise "No whitelist option given" unless ::Disavow::Parameters::OPTIONS[:whitelist]
      import_file = import_file || ARGV[1]
      super(import_file)
    end

    def add_url_message(url)
      "+++ Inserting #{url.on_green} in Whitelist"
    end

    def delete_url_message(url)
      "--- Deleting #{url} from Whitelist"
    end

    def import_message(link)
      "Importing #{link} into White list"
    end

    private :restore
    :protected
    def clean_line!(link)
      link.gsub!(/\"/, '')  # cleaning some bad links
    end
  end
end
