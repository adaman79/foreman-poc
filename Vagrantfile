VAGRANTFILE_API_VERSION = "2"

# global vagrantfile for both server and client

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # os image
  config.vm.box = "precise32"
  config.vm.box_url = "http://files.vagrantup.com/precise32.box"

  # server
  config.vm.define "dns" do |dns|

	# hostname
	dns.vm.hostname = "dns.local.cloud"

	# public network
	dns.vm.network "public_network", :bridge => 'wlan1'

	# private network
	dns.vm.network "private_network", ip: "172.16.0.2"
	dns.vm.provider "virtualbox" do |vb|
		vb.customize ["modifyvm", :id, "--nic3", "intnet"]
	end

	# provisioning with puppet
	dns.vm.provision "puppet" do |puppet|
		puppet.manifests_path = "manifests"
		puppet.manifest_file = "dns.pp"
		puppet.module_path = "modules"
	end
  end

  # client
  config.vm.define "client" do |client|

	# hostname
	client.vm.hostname = "client.local.cloud"

	# private network
	client.vm.network "private_network", type: :dhcp
	client.vm.provider "virtualbox" do |vb|
		vb.customize ["modifyvm", :id, "--nic2", "intnet"]
	end

	# provisioning with puppet
        client.vm.provision "puppet" do |puppet|
                puppet.manifests_path = "manifests"
                puppet.manifest_file = "client.pp"
		puppet.module_path = "modules"
        end
  end

end
