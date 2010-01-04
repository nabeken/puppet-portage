Puppet::Type.newtype(:portage) do
    @doc = "Portage provider."

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
	desc "The file in which to store the aliases.  Only used by
	    those providers that write to disk."

	defaultto {
		@resource.class.defaultprovider.default_target
	}
    end
end

