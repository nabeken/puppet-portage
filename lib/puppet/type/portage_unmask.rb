require 'puppet/provider/parsedfile'

Puppet::Type.newtype(:portage_unmask) do
    @doc = "Portage unmask provider."

    ensurable

    newparam(:name, :namevar => true) do
	desc "The package name."
    end

    newproperty(:version, :array_matching => :all) do
	desc "A unmasked version."

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

    provide(:unmask,
	:parent => Puppet::Provider::ParsedFile,
	:filetype => :flat,
	:default_target => "/etc/portage/package.unmask"
    ) do

	text_line :comment, :match => /^#/
	text_line :blank, :match => /^\s*$/


	record_line :version, :fields => %w{name version}, :block_eval => :instance do
	    def process(line)
		pkg = /^([><=]|>=|<=)([\w+][\w+.-]*\/[\w+][\w+-]*?)-((?:([0-9.a-zA-Z]+(?:_(?:alpha|beta|pre|rc|p)[0-9]*)*(?:-r[0-9]*)?)(?:\([^\)]+\))?(?:\[([^\]]+)\])?[ ]*)*)$/
		ret = {}
		line =~ pkg
		mark = $1
		ret[:name] = $2
		ret[:version] = "#{mark}#{$3}"
		ret
	    end
	end

	def self.to_file(records)
	    ret = ''

	    pkgs = {}
	    records.each do |r|
		pkgs[r[:name]] = [] if pkgs[r[:name]].nil?
		pkgs[r[:name]].push r[:version]
	    end

	    pkgs.each do |name, ver|
		ver.flatten!
		ver.uniq!
		ver.each do |v|
		    v =~ /^([><=]|>=|<=)((?:([0-9.a-zA-Z]+(?:_(?:alpha|beta|pre|rc|p)[0-9]*)*(?:-r[0-9]*)?)(?:\([^\)]+\))?(?:\[([^\]]+)\])?[ ]*)*)$/
		    mark = $1
		    version = $2
		    ret << "%s%s-%s\n" % [mark, name, version]
		end
	    end
	    ret
	end

	def self.prefetch_hook(target_records)
	    pkgs = {} # :name => [version, version]

	    new_records = []

	    keys = target_records.first.keys - [:name, :version]

	    target_records.each do |p|
		pkgs[p[:name]] = {} if pkgs[p[:name]].nil?
		pkgs[p[:name]][:version] = [] if pkgs[p[:name]][:version].nil?
		pkgs[p[:name]][:version].push p[:version]

		keys.each do |k|
		    pkgs[p[:name]][k] = p[k]
		end
	    end

	    pkgs.each do |key, val|
		hash = {:name => key}
		hash.update(val)
		new_records.push hash
	    end
	    new_records
	end
    end
end

