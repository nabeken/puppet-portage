require 'puppet/provider/parsedfile'

Puppet::Type.newtype(:portage_keyword) do
    @doc = "Portage keyword provider."

    ensurable

    newparam(:name, :namevar => true) do
	desc "The package name."
    end

    newproperty(:keyword) do
	desc "A ACCEPT_KEYWORDS."
    end

    newproperty(:target) do
	desc "The file in which to store the keywords.  Only used by
	    those providers that write to disk."

	defaultto {
		@resource.class.defaultprovider.default_target
	}
    end

    provide(:keyword,
	:parent => Puppet::Provider::ParsedFile,
	:filetype => :flat,
	:default_target => "/etc/portage/package.keywords"
    ) do

	text_line :comment, :match => /^#/
	text_line :blank, :match => /^\s*$/

	record_line :keyword, :fields => %w{name keyword}, :separator => /\s/
    end
end

