require 'puppet/provider/parsedfile'

Puppet::Type.type(:portage).provide(:useflags,
    :parent => Puppet::Provider::ParsedFile,
    :filetype => :flat,
    :default_target => "/etc/portage/package.use"
) do

    text_line :comment, :match => /^#/
    text_line :blank, :match => /^\s*$/

    record_line :useflags, :fields => %w{name flags}, :separator => /\s/, :block_eval => :instance do
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
	    enable = record[:enable].join(" ")
	    disable = record[:disable].collect { |u| "-#{u}" }.join(" ")

	    return "%s %s %s" % [record[:name], enable, disable]
	end
    end
end

