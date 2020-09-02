resource "esxi_guest" "dfirlab-debian" {
  count                 = 1
  guest_name            = "DFIRLab-${count.index + 1}-debian"
  notes                 = "Contact : me"
  disk_store            = var.datastore
  boot_disk_type        = "thin"
  memsize               = "2048"
  numvcpus              = "2"
  power                 = "on"
  guest_startup_timeout = "180"
  ovf_source            = "../packer/ova/template-Debian10.ova"

  # Network configuration
  network_interfaces {
    virtual_network     = var.network-portgroup-deployment
    nic_type            = "e1000"
  }

  network_interfaces {
    virtual_network     = "DFIRLab-${count.index + 1}-vm"
    nic_type            = "e1000"
  }

  # Connection used to apply some modifications on system
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
      "echo 'dfirlab-debian' | sudo tee /etc/hostname",
      "echo '127.0.0.1    dfirlab-debian' | sudo tee /etc/hosts",
      "sudo apt update;  export DEBIAN_FRONTEND=noninteractive; sudo -E bash -c 'apt install -y python3-pip git-core clamav forensics-full libvshadow-utils qemu-utils libevtx-utils tcpdump tshark cifs-utils'",
      "sudo mkdir /media/evidences; echo '//10.1.1.15/evidences /media/evidences cifs guest,rw,iocharset=utf8 0 0' | sudo tee -a /etc/fstab; sudo mount -a; sudo chmod -R 777 /media/evidences",
      "sudo git clone https://github.com/log2timeline/plaso.git /opt/log2timeline",
      "cd /opt/log2timeline/; sudo pip3 install -r requirements.txt",
      "cd /opt/log2timeline/; sudo python3 setup.py install",
      "sudo apt install -y libpcre++-dev python-dev python-distorm3 python-openpyxl python-pil python-ujson",
      "sudo git clone https://github.com/volatilityfoundation/volatility.git /opt/volatility",
      "cd /opt/volatility; sudo python setup.py install",
      "sudo mkdir /media/evidences/documentation",
      "cd /media/evidences/documentation; sudo wget https://raw.githubusercontent.com/teamdfir/sift-saltstack/master/sift/files/sift/resources/Evidence-of-Poster.pdf",
      "cd /media/evidences/documentation; sudo wget https://raw.githubusercontent.com/teamdfir/sift-saltstack/master/sift/files/sift/resources/Find-Evil-Poster.pdf",
      "cd /media/evidences/documentation; sudo wget https://raw.githubusercontent.com/teamdfir/sift-saltstack/master/sift/files/sift/resources/SANS-DFIR.pdf",
      "cd /media/evidences/documentation; sudo wget https://raw.githubusercontent.com/teamdfir/sift-saltstack/master/sift/files/sift/resources/Smartphone-Forensics-Poster.pdf",
      "cd /media/evidences/documentation; sudo wget https://raw.githubusercontent.com/teamdfir/sift-saltstack/master/sift/files/sift/resources/memory-forensics-cheatsheet.pdf",
      "cd /media/evidences/documentation; sudo wget https://raw.githubusercontent.com/teamdfir/sift-saltstack/master/sift/files/sift/resources/network-forensics-cheatsheet.pdf",
      "cd /media/evidences/documentation; sudo wget https://raw.githubusercontent.com/teamdfir/sift-saltstack/master/sift/files/sift/resources/sift-cheatsheet.pdf",
      "cd /media/evidences/documentation; sudo wget https://raw.githubusercontent.com/teamdfir/sift-saltstack/master/sift/files/sift/resources/windows-to-unix-cheatsheet.pdf",
      "echo 'auto eth1' | sudo tee -a /etc/network/interfaces",
      "echo 'iface eth1 inet static' | sudo tee -a /etc/network/interfaces",
      "echo '  address 10.1.1.12' | sudo tee -a /etc/network/interfaces",
      "echo '  netmask 255.255.255.0' | sudo tee -a /etc/network/interfaces",
      "sudo ifup eth1",
      "echo 'up route add -net 10.8.0.0/24 gw 10.1.1.254 dev eth1' | sudo tee -a /etc/network/interfaces",
      "sudo shutdown -r +1"
    ]
  }
}
