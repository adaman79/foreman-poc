# Necessary for the subsequent installations
exec { 'apt-get update':
	command => '/usr/bin/apt-get update'
}

package {
    'vim':
        ensure => installed
}

package {
    'bind9':
        ensure => installed
}

file { "/etc/resolv.conf":
	ensure => present,
	source => "/vagrant/files/resolv.conf",
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

#file { "/var/named":
#    ensure => "directory",
#}


# BIND

#include bind
#bind::server::conf { '/etc/bind/named.conf':
#  listen_on_addr    => [ 'any' ],
#  listen_on_v6_addr => [ 'any' ],
#  forwarders        => [ '8.8.8.8', '8.8.4.4' ],
#  allow_query       => [ 'localnets' ],
#  allow_recursion   => ['any' ],
#  zones             => {
#    'local.cloud' => [
#      'type master',
#      'file "local.cloud"',
#    ],
##    'metal.cloud.local' => [
##      'type master',
##      'file "metal.cloud.local"',
##    ],
#  },
#}

#bind::server::file { 
#  [
#    'local.cloud', 
##    'metal.cloud.local'
#  ]:
#  source_base => '/vagrant/files/',
#}


# DHCP

#$ddnskeyname = 'dhcp_updater'

class { 'dhcp':
  dnsdomain    => [
    'local.cloud',
 #   'metal.cloud.local',
    ],
  nameservers  => ['172.16.0.2'],
  ntpservers   => ['us.pool.ntp.org'],
  interfaces   => ['eth2'],
#  dnsupdatekey => "/etc/bind/keys.d/$ddnskeyname",
#  require      => Bind::Key[ $ddnskeyname ],
  pxeserver    => '172.16.0.2',
  pxefilename  => 'pxelinux.0',
}

dhcp::pool{ 'local.cloud':
  network => '172.16.0.0',
  mask    => '255.255.255.0',
  range   => '172.16.0.16 172.16.0.255',
  gateway => '172.16.0.2',
}

