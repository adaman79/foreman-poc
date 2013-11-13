# Necessary for the subsequent installations and further configuration
exec { 'apt-get update':
	command => '/usr/bin/apt-get update'
}


# BIND

package {
    'bind9':
        ensure => installed
}

file { "/etc/bind":
	ensure => directory,
}

file { "/etc/bind/named.conf.options":
	ensure => present,
	source => "/vagrant/files/named.conf.options",
}
file { "/etc/bind/named.conf.local":
	ensure => present,
	source => "/vagrant/files/named.conf.local",
}
file { "/etc/bind/db.local.cloud":
	ensure => present,
	source => "/vagrant/files/db.local.cloud",
}

service { "bind9":
	ensure => running,
	subscribe =>	[
			File["/etc/bind/named.conf.options"],
			File["/etc/bind/named.conf.local"],
			File["/etc/bind/db.local.cloud"]
			],
}

# DHCP


file { "/etc/bind/keys.d":
	ensure => directory,
}
file { "/etc/bind/keys.d/dhcp_updater":
	ensure => present,
	source => "/vagrant/files/dhcp_updater",
}


class { 'dhcp':
  dnsdomain    => [
    'local.cloud',
 #   'metal.cloud.local',
    ],
  nameservers  => ['172.16.0.2'],
  ntpservers   => ['us.pool.ntp.org'],
  interfaces   => ['eth2'],
  dnsupdatekey => "/etc/bind/keys.d/dhcp_updater",
  require      => File["/etc/bind/keys.d/dhcp_updater"],
  pxeserver    => '172.16.0.2',
  pxefilename  => 'pxelinux.0',
}

dhcp::pool{ 'local.cloud':
  network => '172.16.0.0',
  mask    => '255.255.255.0',
  range   => '172.16.0.16 172.16.0.255',
  gateway => '172.16.0.2',
}

file { "/etc/apparmor.d/usr.sbin.dhcpd":
	ensure => present,
	owner => root,
	group => root,
	mode => 644,
	source => "/vagrant/files/apparmor_usr.sbin.dhcpd",
}

file_line { 'static_nameserver':
	path => '/etc/network/interfaces',
	line => '      dns-nameservers  172.16.0.2 8.8.8.8 8.8.4.4',
}


