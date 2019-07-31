module DisavowTool
	module DomainAndUrl
		attr_accessor :disavowed_links, :disavowed_domains
		alias_method :links, :disavowed_links
		alias_method :domains, :disavowed_domains
		def initialize(import_files=nil)
			import_files = import_files || OPTIONS.disavow_files
			@disavowed_domains = Set.new
			@links = Set.new
			super(import_files)
		end

		def clean_line!(line)
			case domain_or_url(line)
			when :domain
				@disavowed_domains << remove_domain_prefix(line)
			when :url
				@links << line
			end
		end

		def finished_import_hook
			@original_domains = @disavowed_domains.clone
			@original_links = @links.clone
		end

		def add_domain(domain)
			super(domain, @disavowed_domains)
		end

		def add_url(url, list=nil)
			super(url, @links)
		end

	end
end
