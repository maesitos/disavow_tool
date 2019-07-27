require_relative 'list'
module DisavowTool
  class WhiteList < List
    def initialize(import_files=nil)
      raise "No whitelist option given" unless OPTIONS.whitelist
      import_files = import_files || OPTIONS.whitelist_files
      super(import_files)
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
    def message_sumary_imported; "Whitelist links imported" end
    def mensaje_sumary_before_export; "Whitelist before exporting" end

    def export_write(file)
      file.puts "# Whitelist"
      file.puts self.to_a
      puts "Writing #{self.to_a.count} White links".blue if @verbose
    end

    private :restore
    :protected
    def clean_line!(link)
      link.gsub!(/\"/, '')  # cleaning some bad links
    end
  end
end
