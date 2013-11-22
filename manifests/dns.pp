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
	source => "/vagrant/files/DHCP/named.conf.options",
	owner => root,
	group => bind,
	mode => 644,
}
file { "/etc/bind/named.conf.local":
	ensure => present,
	source => "/vagrant/files/DHCP/named.conf.local",
	owner => root,
	group => bind,
	mode => 644,
}
file { "/etc/bind/db.local.cloud":
	ensure => present,
	source => "/vagrant/files/DHCP/db.local.cloud",
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
	source => "/vagrant/files/DHCP/dhcp_updater",
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
  pxefilename  => 'ubuntu-12.04/pxelinux.0',
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
	source => "/vagrant/files/DHCP/apparmor_usr.sbin.dhcpd",
}

# symlink necessary for DNS updates
file { '/var/cache/bind/db.local.cloud':
   ensure => 'link',
   target => '/etc/bind/db.local.cloud',
}

# replace configuration of interfaces to ensure correct dns name server
file { "/etc/network/interfaces":
	ensure => present,
	source => "/vagrant/files/DHCP/interfaces_dns",
	owner => root,
	group => root,
	mode => 644,
}

# PXE

# PXE is composed of a DHCP and a TFTP server

# DHCP:	offers an IP
#   (already configured further up)


# TFTP:	supplies the images

# installation of the TFTP-server
package {
    'tftpd-hpa':
        ensure => installed
}

# replace the TFTPd-configuration
file { '/etc/default/tftpd-hpa':
	ensure => present,
	source => '/vagrant/files/TFTP/tftpd-hpa',
	owner => root,
	group => root,
	mode => 644,
}

# create the TFTP-root directory and set the permissions
file { '/var/lib/tftpboot':
	ensure => directory,
	owner => nobody,
	group => nogroup,
	mode => 777,
}

# netboot image for Ubunu 12.04
file { '/var/lib/tftpboot/ubuntu-12.04':
	ensure => directory,
	recurse => true,
	purge => true,
	force => true,
	owner => nobody,
	group => nogroup,
	mode => 777,
	source => "/vagrant/files/TFTP/ubuntu-12.04",
}



# default configuration if no match is found

# config-folder
file { '/var/lib/tftpboot/pxelinux.cfg':
	ensure => directory,
	owner => nobody,
	group => nogroup,
	mode => 777,
}

# config: list of available boot image
file { '/var/lib/tftpboot/pxelinux.cfg/default':
	ensure => present,
	owner => nobody,
	group => nogroup,
	mode => 777,
	source => "/vagrant/files/TFTP/default",
}

# boot menu text
file { '/var/lib/tftpboot/boot.txt':
	ensure => present,
	owner => nobody,
	group => nogroup,
	mode => 777,
	source => "/vagrant/files/TFTP/boot.txt",
}



# make sure that TFTP gets restarted after the configuration is changed
service { "tftpd-hpa":
	ensure => running,
	subscribe => File["/etc/default/tftpd-hpa"],
}



# FOREMAN

# set up module
class { 'apt': 
	always_apt_update	=> true,
}

# add repository

# AN FELIX:
# habe noch nicht ganz herausgefunden, welche Parameter gleiche Einträge wie in http://theforeman.org/manuals/1.3/quickstart_guide.html erzeugen
apt::source { 'foreman':
  location	=> 'http://deb.theforeman.org/',
  release	=> 'precise',
  key_source	=> 'http://deb.theforeman.org/foreman.asc',
}


# install foreman-installer
package {
    'foreman-installer':
        ensure => installed,
}

exec { "foreman-installer":
    command => "foreman-installer",
    path    => "/usr/local/bin/:/bin/",
}

