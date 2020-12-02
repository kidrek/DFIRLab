#!/bin/bash

echo 3 | sudo tee /proc/sys/vm/drop_caches 1>/dev/null

## Installation des paquets necessaires
sudo apt update; sudo apt install -y bridge-utils curl libvirt0 libvirt-dev qemu-kvm ssdeep swig tcpdump unzip virtinst libvirt-clients virt-manager zlib1g-dev python3-elasticsearch

## Activation du reseau
sudo virsh net-autostart default
sudo virsh net-start default

## Installation de CAPEv2
wget https://raw.githubusercontent.com/doomedraven/Tools/master/Sandbox/cape2.sh
chmod +x cape2.sh
sudo ./cape2.sh base cape

## Ajout de l'utilisateur CAPE aux groupes qemu/kvm
sudo usermod -a -G kvm cape
sudo usermod -a -G libvirt cape
sudo usermod -a -G libvirt-qemu cape

## Configuration de CAPEv2
sudo rm -rf /opt/CAPEv2/storage; sudo ln -s /media/evidences/ /opt/CAPEv2/storage
sudo sed -i 's/freespace =.*/freespace = 10000/' /opt/CAPEv2/conf/cuckoo.conf
sudo sed -i 's/ip =.*/ip = 192.168.122.1/' /opt/CAPEv2/conf/cuckoo.conf
sudo sed -i 's/interface =.*/interface = virbr0/' /opt/CAPEv2/conf/kvm.conf
sudo sed -i 's/label =.*/label = win10/' /opt/CAPEv2/conf/kvm.conf
sudo sed -i 's/ip =.*/ip = 192.168.122.110/' /opt/CAPEv2/conf/kvm.conf
sudo sed -i 's/snapshot =.*/snapshot = CUCKOO_READY/' /opt/CAPEv2/conf/kvm.conf


## Enregistrement de la machine virtuelle win10
sudo virt-install --import --name win10 --memory 2048 --vcpus 2 --cpu host --accelerate --virt-type kvm --hvm --os-type windows --os-variant win10 --disk /var/lib/libvirt/images/Win10.qcow2,format=qcow2,bus=virtio --network bridge=virbr0,model=virtio --noautoconsole

## Attribution d'une addresse ipv4 statique
sleep 180
sudo virsh net-update default delete ip-dhcp-range "`sudo virsh net-dumpxml default | grep 'range' | sed 's/      //'`" --live --config
sudo virsh destroy win10
sudo virsh net-update default add-last ip-dhcp-host "<host mac='`sudo virsh dumpxml win10 | grep -i 'mac address' | awk -F "'" '{print $2}'`' name='win10' ip='192.168.122.110'/>" --live --config

## Création du snapshot nécessaire à cuckoo
sudo virsh start win10
sleep 900
sudo virsh snapshot-create-as --domain win10 --name CUCKOO_READY
sudo virsh destroy win10

## Création du template d'index cukoo dans ELK
curl -H 'Content-Type: application/json' -XPUT http://10.1.1.11:9200/_template/cuckoo_template -d '{"index_patterns":["cuckoo"],"template":{"mappings":{"_doc":{"_meta":{},"_source":{},"properties":{}}}}}'


sudo reboot
