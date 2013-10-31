# Necessary for the subsequent installations
exec { 'apt-get update':
	command => '/usr/bin/apt-get update'
}

# DHCP

class { 'dhcp':
  dnsdomain    => [
    'cloud.local',
    'metal.cloud.local',
    ],
  nameservers  => ['172.16.0.2'],
  ntpservers   => ['us.pool.ntp.org'],
  interfaces   => ['eth1'],
  dnsupdatekey => "/etc/bind/keys.d/$ddnskeyname",
  require      => Bind::Key[ $ddnskeyname ],
  pxeserver    => '172.16.0.2',
  pxefilename  => 'pxelinux.0',
}

dhcp::pool{ 'cloud.local':
  network => '172.16.0.0',
  mask    => '255.255.255.0',
  range   => '172.16.0.16 172.16.0.255',
  gateway => '172.16.0.1',
}


# DHCPd
#
#class { 'dhcpd':
#  configsource => 'puppet:///modules/foremanPOC/dhcpd.conf',
#  # Restrict listening to a single interface
#  dhcpdargs    => 'eth1',
#  # Default is to enable but allow to be stopped (for active/passive)
#  ensure       => 'running',
#}


# BIND

include bind
bind::server::conf { '/etc/named.conf':
  listen_on_addr    => [ 'any' ],
  listen_on_v6_addr => [ 'any' ],
  forwarders        => [ '8.8.8.8', '8.8.4.4' ],
  allow_query       => [ 'localnets' ],
  zones             => {
    'cloud.local' => [
      'type master',
      'file "cloud.local"',
    ],
    'metal.cloud.local' => [
      'type master',
      'file "metal.cloud.local"',
    ],
  },
}

bind::server::file { [ 'cloud.local', 'metal.cloud.local' ]:
  source_base => 'puppet:///modules/foremanPOC/dns/',
}
