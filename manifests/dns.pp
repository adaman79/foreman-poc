# Necessary for the subsequent installations
exec { 'apt-get update':
	command => '/usr/bin/apt-get update'
}


# BIND configuration

# install BIND
package {
    'bind9':
        ensure => installed
}

# create necessary directories
file { "/etc/bind":
	ensure => directory,
}

# copy configurations from host and set permissions
file { "/etc/bind/named.conf.options":
	ensure => present,
	source => "/vagrant/files/named.conf.options",
	owner => root,
	group => bind,
	mode => 644,
}
file { "/etc/bind/named.conf.local":
	ensure => present,
	source => "/vagrant/files/named.conf.local",
	owner => root,
	group => bind,
	mode => 644,
}
file { "/etc/bind/db.local.cloud":
	ensure => present,
	source => "/vagrant/files/db.local.cloud",
	owner => root,
	group => bind,
	mode => 644,
}

# make sure that BIND gets restarted after the configuration is changed
service { "bind9":
	ensure => running,
	subscribe =>	[
			File["/etc/bind/named.conf.options"],
			File["/etc/bind/named.conf.local"],
			File["/etc/bind/db.local.cloud"]
			],
}


# DHCP

# copy key for secure DDNS updates
file { "/etc/bind/keys.d":
	ensure => directory,
}
file { "/etc/bind/keys.d/dhcp_updater":
	ensure => present,
	source => "/vagrant/files/dhcp_updater",
}

# set up puppet-module for DHCP
class { 'dhcp':
  dnsdomain    => [
    'local.cloud',
 #   'metal.cloud.local',
    ],
  nameservers  => ['172.16.0.2, 8.8.8.8, 8.8.4.4'],
  ntpservers   => ['us.pool.ntp.org'],
  interfaces   => ['eth2'],
  dnsupdatekey => "/etc/bind/keys.d/dhcp_updater",
  require      => File["/etc/bind/keys.d/dhcp_updater"],
  pxeserver    => '172.16.0.2',
  pxefilename  => 'pxelinux.0',
}

# domain local.cloud
dhcp::pool{ 'local.cloud':
  network => '172.16.0.0',
  mask    => '255.255.255.0',
  range   => '172.16.0.16 172.16.0.255',
  gateway => '172.16.0.2',
}

# workaround that dhcp can read key for secure DNS updates
# replace existing DHCPd-apparmor configuration
file { "/etc/apparmor.d/usr.sbin.dhcpd":
	ensure => present,
	owner => root,
	group => root,
	mode => 644,
	source => "/vagrant/files/apparmor_usr.sbin.dhcpd",
}

# symlink necessary for DNS updates
file { '/var/cache/bind/db.local.cloud':
   ensure => 'link',
   target => '/etc/bind/db.local.cloud',
}

# replace configuration of interfaces to ensure correct dns name server
file { "/etc/network/interfaces":
	ensure => present,
	source => "/vagrant/files/interfaces_dns",
	owner => root,
	group => root,
	mode => 644,
}


