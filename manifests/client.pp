exec { 'apt-get update':
	command => '/usr/bin/apt-get update'
}

file_line { 'static_nameserver':
	path => '/etc/network/interfaces',
	line => '      dns-nameservers  172.16.0.2 8.8.8.8 8.8.4.4',
}

