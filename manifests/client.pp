exec { 'apt-get update':
	command => '/usr/bin/apt-get update'
}

package {
    'vim':
        ensure => installed
}

file { "/etc/resolv.conf":
	ensure => present,
	source => "/vagrant/files/resolv.conf",
}
