require_relative 'list'
module DisavowTool
  class WhiteList < List
    include DomainAndUrl

    def initialize(import_files=nil)
      raise "No whitelist option given" unless OPTIONS.whitelist
      import_files = import_files || OPTIONS.whitelist_files
      super(import_files)
    end

    def  add_urls_with_same_domain_as(url, import_list)
      domain = URI.parse(URI.escape(url)).host
      puts "Adding to whitelist all imported urls with the domain #{domain}"
      import_list.each do |link|
        add_url(link) if URI.parse(URI.escape(link)).host == domain
      end
      puts "Attempting to remove URLs with the domain #{domain} from imported links to stop anaylsing"
      import_list.delete_urls_if_domains(domain)
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
      super(file)
      puts "Writing #{total_elements} White links into whitelist".blue if @verbose
    end


  end
end
