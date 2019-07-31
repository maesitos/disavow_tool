require_relative 'list'
require_relative 'domain_and_url'
require 'uri'

module DisavowTool
  class DisavowList < List
    include DomainAndUrl

    def add_domain_from_url(url)
      domain = URI.parse(URI.escape(url)).host
      add_domain(domain)
      p domain
      return domain
    end

    def import_message(domain)
      "Importing #{is_url?(domain).to_s} #{remove_domain_prefix(domain)} into Disavow list"
    end
    def add_url_message(url)
      "+++ Inserting #{is_url?(url).to_s} #{url} in Disavow"
    end
    def message_sumary_imported; "Disavowed elements imported" end
    def mensaje_sumary_before_export; "Disavow elements before exporting" end

    def summary
      puts "Disavowed URLs:".light_blue
      super(@links, @original_links)
      puts "Disavowed Domains:".light_blue
      super(@domains, @original_domains)
    end

    def export_write(file)
      file.puts "# Domains"
      file.puts @domains.to_a
      puts "Writing #{@domains.count} Disavowed domains".blue if @verbose
      file.puts "# urls"
      file.puts @links.to_a
      puts "Writing #{@links.count} Disavowed URLS".blue if @verbose

    end

    :private
    def domain_or_url(line)
      if( /^domain/.match(line))
        return :domain
      elsif( /^http/.match(line) )
        return :url
      else
        raise "Error parsing Disavow file"
      end
    end

    def is_url?(link)
      if( link.match(/^http(s)?\:/) )
        :url
      else
        :domain
      end
    end

    def remove_domain_prefix(domain)
      domain.gsub(/^domain\:/, '')
    end
    def remove_domain_prefix!(domain)
      domain.gsub!(/^domain\:/, '')
    end

    def add_domain_prefix
    end
  end
end
