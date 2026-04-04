# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure("2") do |config|
  config.vm.box = "debian/bookworm64" # Box Debian 12 (Bookworm) 64 bits
  config.vm.box_version = "12.20250126.1" 

    config.vm.define "devops-final" do |node|
      node.vm.hostname = "devops-final" # Hostname unique
      node.vm.network "private_network", ip: "192.168.56.10" # Réseau interne/privé + IP statique

      node.vm.disk :disk, size: "25GB", primary: true # Disque dur de 25 Go

      node.vm.provider "virtualbox" do |vb|
        vb.gui = true # Affiche la GUI
        vb.memory = 2048 # 2 Go de RAM
      end
    end

  # Script de provisionnement (exécuté qd la VM est créée)
  config.vm.provision "shell", inline: <<-SHELL
    sudo apt-get update # Mise à jour des paquets
    sudo apt-get install -y curl # Installation de curl
    curl -sfL https://get.k3s.io | sh - # Installation de k3s (non disponible dans les paquets)
  SHELL
end
