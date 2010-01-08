require 'puppet/provider/parsedfile'

Puppet::Type.newtype(:portage_useflag) do
    @doc = "Portage useflag provider."

    ensurable

    newparam(:name, :namevar => true) do
	desc "The package name."
    end

    newproperty(:enable, :array_matching => :all) do
	desc "A enabled useflags."

	def is_to_s(value)
	    if value.include?(:absent)
		super
	    else
		value.join(" ")
	    end
	end
    end

    newproperty(:disable, :array_matching => :all) do
	desc "A disabled useflags."

	def is_to_s(value)
	    if value.include?(:absent)
		super
	    else
		value.join(" ")
	    end
	end
    end

    newproperty(:target) do
	desc "The file in which to store the settings.  Only used by
	    those providers that write to disk."

	defaultto {
		@resource.class.defaultprovider.default_target
	}
    end

    provide(:useflag,
	:parent => Puppet::Provider::ParsedFile,
	:filetype => :flat,
	:default_target => "/etc/portage/package.use"
    ) do

	text_line :comment, :match => /^#/
	text_line :blank, :match => /^\s*$/

	record_line :useflag, :fields => %w{name flags}, :separator => /\s/, :block_eval => :instance do
	    def post_parse(record)
		enable = []
		disable = []

		record[:flags].split(" ").each do |f|
		    if f =~ /^-/
			disable.push f[1..-1]
		    else
			enable.push f
		    end
		end

		record[:enable] = enable
		record[:disable] = disable

		record
	    end

	    def to_line(record)
		enable = record[:enable].join(" ") unless record[:enable].first.empty?
		disable = record[:disable].collect { |u| "-#{u}" }.join(" ") unless record[:disable].first.empty?

		return "%s %s %s" % [record[:name], enable, disable]
	    end
	end
    end
end

