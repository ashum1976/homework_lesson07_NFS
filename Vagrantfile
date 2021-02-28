# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
            #config.vm.box = "ashum1976/centos7_kernel_5.10"
             config.vm.box = "centos/7"
            #  config.vm.provision "ansible" do |ansible|
            #    ansible.verbose = "vvv"
            #    ansible.playbook = "playbook.yml"
            #    ansible.become = "true"
            #  end

            config.vm.provider "virtualbox" do |v|
                v.memory = 256
                v.cpus = 1
            end

            config.vm.define "nfs_server" do |nfss|
                #nfss.vm.synced_folder "./sync_data_server", "/home/vagrant/mnt"
                nfss.vm.network "private_network", ip: "192.168.50.10", virtualbox__intnet: "net1"
                nfss.vm.hostname = "nfssrv"
                #nfss.vm.provision "shell", path: "nfss_script.sh"
            end

            config.vm.define "nfs_client" do |nfsc|
                #nfsc.vm.synced_folder "./sync_data_client", "/home/vagrant/mnt"
                nfsc.vm.network "private_network", ip: "192.168.50.11", virtualbox__intnet: "net1"
                nfsc.vm.hostname = "nfscln"
                #nfsc.vm.provision "shell", path: "nfsc_script.sh"
            end

end
