VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.hostname = "bootstrap.local.cloud"
  config.vm.box = "precise32"
  config.vm.box_url = "http://files.vagrantup.com/precise32.box"


  config.vm.define "dns" do |dns|
	dns.vm.network "public_network", :bridge => 'wlan1' #eth0
	dns.vm.network "private_network", ip: "172.16.0.2"
	
	dns.vm.provider "virtualbox" do |vb|
		vb.customize ["modifyvm", :id, "--nic3", "intnet"]
	end

	dns.vm.provision "puppet" do |puppet|
		puppet.manifests_path = "manifests"
		puppet.manifest_file = "dns.pp"
		puppet.module_path = "modules"
	end
  end

  config.vm.define "client" do |client|
	client.vm.network "private_network", type: :dhcp
	
	client.vm.provider "virtualbox" do |vb|
		vb.customize ["modifyvm", :id, "--nic2", "intnet"]
	end

        client.vm.provision "puppet" do |puppet|
                puppet.manifests_path = "manifests"
                puppet.manifest_file = "client.pp"
		puppet.module_path = "modules"
        end
  end

end
