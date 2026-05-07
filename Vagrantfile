# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure("2") do |config|
  config.vm.box = "debian/bookworm64" # Box Debian 12 (Bookworm) 64 bits
  config.vm.box_version = "12.20250126.1" 

    config.vm.define "vm-kubernetes" do |node|
      node.vm.hostname = "vm-kubernetes" # Hostname unique
      node.vm.network "private_network", ip: "192.168.56.10" # IP statique

      node.vm.disk :disk, size: "25GB", primary: true # Disque dur de 25 Go

      node.vm.provider "virtualbox" do |vb|
        vb.memory = 2048 # 2 Go de RAM
      end
    end

    config.vm.define "vm-monitoring" do |node|
      node.vm.hostname = "vm-monitoring" # Hostname unique
      node.vm.network "private_network", ip: "192.168.56.11" # IP statique

      node.vm.disk :disk, size: "10GB", primary: true # Disque dur de 25 Go

      node.vm.provider "virtualbox" do |vb|
        vb.memory = 2048 # 2 Go de RAM
      end
    end

  # Node exporter est installé et lancé sur les 2 VMs
  config.vm.provider "node-exporter", type: "ansible" do |ansible|
    ansible.playbook = "ansible/node-exporter.yaml" # Chemin vers le playbook Ansible
  end

  # Provisionnement vm k3s
  config.vm.provision "vm1", type: "ansible" do |ansible|
    ansible.playbook = "ansible/k3s.yaml" # Chemin vers le playbook Ansible
  end

  # Provisionnement vm monitoring
  config.vm.provision "vm2", type: "ansible" do |ansible|
    ansible.playbook = "ansible/monitoring.yaml" # Chemin vers le playbook Ansible
  end
end
