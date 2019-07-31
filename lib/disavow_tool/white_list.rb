require_relative 'list'
module DisavowTool
  class WhiteList < List
    include DomainAndUrl

    def initialize(import_files=nil)
      raise "No whitelist option given" unless OPTIONS.whitelist
      import_files = import_files || OPTIONS.whitelist_files
      p "Whitelist"
      super(import_files)
    end

    def add_url_message(url)
      "+++ Inserting #{url.on_green} in Whitelist"
    end

    def import_message(domain)
      "Importing #{is_url?(domain).to_s} #{remove_domain_prefix(domain)} into White list"
    end
    def add_url_message(url)
      "+++ Inserting #{is_url?(url).to_s} #{url} into White lis"
    end
    def message_sumary_imported; "Whitelist links imported" end
    def mensaje_sumary_before_export; "Whitelist before exporting" end

    def message_sumary_links_imported; "Whitelisted URLs:" end
    def message_sumary_domains_imported; "Whitelisted Domains:" end

    def export_write(file)
      file.puts "# Whitelist"
      file.puts self.to_a
      puts "Writing #{self.to_a.count} White links".blue if @verbose
    end
  end
end
