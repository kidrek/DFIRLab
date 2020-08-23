resource "esxi_guest" "pin-elk" {
  count                 = 1
  guest_name            = "PIN-${count.index + 1}-ELK"
  notes                 = "Contact : me"
  disk_store            = "<esx_datastore>"
  boot_disk_type        = "thin"
  #boot_disk_size        = "100"
  memsize               = "2048"
  numvcpus              = "2"
  power                 = "on"
  guest_startup_timeout = "180"

  ovf_source = "../packer/ova/template-Debian10.ova"

  network_interfaces {
    virtual_network = "<portgroup--terraform-deployment>"
    nic_type        = "e1000"
  }

  network_interfaces {
    virtual_network = "PIN-${count.index + 1}-vm"
    nic_type        = "e1000"
  }


  connection {
    host        = self.ip_address
    type        = "ssh"
    user        = "analyste"
    private_key = file("../packer/FILES/analyste.key")
    timeout     = "180s"
  }

  ## Command executed on remote VM through SSH connection
  provisioner "remote-exec" {
    inline = [
      "echo 'elk' | sudo tee /etc/hostname",
      "echo '127.0.0.1    elk' | sudo tee /etc/hosts",
      "sudo apt update; sudo apt install -y git-core docker-compose",
      "sudo useradd elk",
      "sudo usermod -a -G docker elk",
      "sudo mkdir /opt/docker-elk",
      "sudo chown -R elk: /opt/docker-elk",
      "sudo -u elk git clone https://github.com/deviantony/docker-elk.git /opt/docker-elk",
      "sudo -u elk sed -i 's/xpack.security.enabled: true/xpack.security.enabled: false/g'  /opt/docker-elk/elasticsearch/config/elasticsearch.yml",
      "sudo /etc/init.d/docker start",
      "( sudo crontab -l; echo \"@reboot sleep 30 && cd /opt/docker-elk; sudo -u elk docker-compose up -d 1>/dev/null 2>&1\" ) | sudo crontab  -",
      "cd /opt/docker-elk; sudo -u elk docker-compose up -d",
      "echo 'auto eth1' | sudo tee -a /etc/network/interfaces",
      "echo 'iface eth1 inet static' | sudo tee -a /etc/network/interfaces",
      "echo '  address 10.1.1.11' | sudo tee -a /etc/network/interfaces",
      "echo '  netmask 255.255.255.0' | sudo tee -a /etc/network/interfaces",
      "sudo ifup eth1",
      "echo \"up route add -net 10.8.0.0/24 gw 10.1.1.254 dev eth1\" | sudo tee -a /etc/network/interfaces",
      "sudo reboot"
    ]
  }
}
