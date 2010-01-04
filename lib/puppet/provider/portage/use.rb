require 'puppet/provider/parsedfile'

Puppet::Type.type(:portage).provide(:use,
    :parent => Puppet::Provider::ParsedFile,
    :filetype => :flat,
    :default_target => "/etc/portage/package.use"
) do

    text_line :comment, :match => /^#/
    text_line :blank, :match => /^\s*$/

    record_line :use, :fields => %w{name use}, :separator => /\s/, :block_eval => :instance do
	def post_parse(record)
	    use = record[:use].split(" ")
	    record[:use] = use
	    record
	end

	def to_line(record)
	    use = record[:use].join(" ")

	    return "%s %s" % [record[:name], use]
	end
    end
end

