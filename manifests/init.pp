define portage::use($enable = '', $disable = '', $ensure = 'present') {
    portage_useflag { $name:
	enable => $enable,
	disable => $disable,
	ensure => $ensure,
    }
}

define portage::keyword($keyword, $ensure = 'present') {
    portage_keyword { $name:
	keyword => $keyword,
	ensure => $ensure,
    }
}

define portage::mask($version, $ensure = 'present') {
    portage_mask { $name:
	version => $version,
	ensure => $ensure,
    }
}

define portage::unmask($version, $ensure = 'present') {
    portage_unmask { $name:
	version => $version,
	ensure => $ensure,
    }
}
