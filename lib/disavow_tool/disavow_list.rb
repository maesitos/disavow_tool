require_relative 'list'
require 'uri'

module DisavowTool
  class DisavowList < List
    attr_accessor :disavowed_links, :disavowed_domains
    alias_method :links, :disavowed_links
    alias_method :domains, :disavowed_domains

    def initialize(import_file=nil)
      import_file = import_file || OPTIONS.disavow_file
      @disavowed_domains = Set.new
      @disavowed_links = Set.new
      super(import_file)
    end

    def clean_line!(line)
      case domain_or_url(line)
      when :domain
        @disavowed_domains << remove_domain_prefix(line)
      when :url
        @disavowed_links << line
      end
    end

    def add_domain(domain)
      super(domain, @disavowed_domains)
    end

    def add_url(domain, list=nil)
      super(domain, @disavowed_url)
    end

    def add_domain_from_url(url)
      domain = URI.parse(URI.escape(url)).host
      add_domain(domain)
      return domain
    end

    def import_message(domain)
      "Importing #{is_url?(domain).to_s} #{remove_domain_prefix(domain)} into Disavow list"
    end
    def add_url_message(url)
      "+++ Inserting #{is_url?(url).to_s} #{url} in Disavow"
    end

    def export_write(file)
      file.puts "# Domains"
      file.puts @disavowed_domains.to_a
      file.puts "# urls"
      file.puts @disavowed_links.to_a
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
