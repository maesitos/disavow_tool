require_relative 'list'
require_relative 'domain_and_url'
require 'uri'

module DisavowTool
  class DisavowList < List
    include DomainAndUrl

    def initialize(import_files=nil)
      import_files = import_files || OPTIONS.disavow_files
      super(import_files)
    end

    def import_message(domain)
      "Importing #{is_url?(domain).to_s} #{remove_domain_prefix(domain)} into Disavow list"
    end
    def add_url_message(url)
      "+++ Inserting #{is_url?(url).to_s} #{url} in Disavow"
    end
    def message_sumary_imported; "Disavowed elements imported" end
    def mensaje_sumary_before_export; "Disavow elements before exporting" end

    def message_sumary_links_imported; "Disavowed URLs:" end
    def message_sumary_domains_imported; "Disavowed Domains:" end

    def export_write(file)
      file.puts "# Domains"
      file.puts @domains.to_a
      puts "Writing #{@domains.count} Disavowed domains".blue if @verbose
      file.puts "# urls"
      file.puts @links.to_a
      puts "Writing #{@links.count} Disavowed URLS".blue if @verbose
    end

  end
end
