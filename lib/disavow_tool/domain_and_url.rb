module DisavowTool
	module DomainAndUrl
		attr_accessor :links, :domains

		def initialize(import_files)
			@domains = Set.new
			@links = Set.new
			p "DomainAndUrl"
			super(import_files)
		end

		def clean_line!(line)
			case domain_or_url(line)
			when :domain
				@domains << remove_domain_prefix(line)
			when :url
				@links << line
			end
		end

		def finished_import_hook
			@original_domains = @domains.clone
			@original_links = @links.clone
		end

		def add_domain(domain)
			super(domain, @domains)
		end

		def add_url(url, list=nil)
			super(url, @links)
		end

		def add_domain_from_url(url)
			domain = URI.parse(URI.escape(url)).host
			add_domain(domain)
			p domain
			return domain
		end

		def export_write(file)
			file.puts "# Domains"
			add_domain_prefix
			file.puts @domains.to_a
			puts "Writing #{@domains.count} domains".blue if @verbose
			file.puts "# urls"
			file.puts @links.to_a
			puts "Writing #{@links.count} URLS".blue if @verbose
		end

		def summary
			puts message_sumary_links_imported.green
			super(@links, @original_links)
			puts message_sumary_domains_imported.green
			super(@domains, @original_domains)
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
			unless( link.match(/^http(s)?\:/) )
				:domain
			else
				:url
			end
		end

		def remove_domain_prefix(domain)
			domain.gsub(/^domain\:/, '')
		end
		def remove_domain_prefix!(domain)
			domain.gsub!(/^domain\:/, '')
		end

		def add_domain_prefix
			@domains.collect!{|domain| domain="domain:" + domain}
		end

		def total_elements
			@domains.count + @links.count
		end

	end
end
