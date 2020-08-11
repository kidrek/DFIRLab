resource "esxi_guest" "pin-dfir-debian" {
  count                 = 1
  guest_name            = "PIN-${count.index + 1}-DFIR-debian"
  notes                 = "Contact : <contact_data>"
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
    user        = "ansible"
    private_key = file("../packer/FILES/ansible.key")
    timeout     = "180s"
  }

  ## Command executed on remote VM through SSH connection
  provisioner "remote-exec" {
    inline = [
      "echo 'DFIR-debian' | sudo tee /etc/hostname",
      "echo '127.0.0.1    DFIR-debian' | sudo tee /etc/hosts",
      "sudo apt update;  export DEBIAN_FRONTEND=noninteractive; sudo -E bash -c 'apt install -y python3-pip git-core clamav forensics-full libvshadow-utils qemu-utils libevtx-utils tcpdump tshark cifs-utils'",
      "sudo mkdir /media/evidences; echo '//10.1.1.15/evidences /media/evidences cifs guest,rw,iocharset=utf8 0 0' | sudo tee -a /etc/fstab; sudo mount -a; sudo chmod -R 777 /media/evidences",
      "sudo git clone https://github.com/log2timeline/plaso.git /opt/log2timeline",
      "cd /opt/log2timeline/; sudo pip3 install -r requirements.txt",
      "cd /opt/log2timeline/; sudo python3 setup.py install",
      "sudo apt install -y libpcre++-dev python-dev python-distorm3 python-openpyxl python-pil python-ujson",
      "sudo git clone https://github.com/volatilityfoundation/volatility.git /opt/volatility",
      "cd /opt/volatility; sudo python setup.py install",
      "echo 'auto ens37' | sudo tee -a /etc/network/interfaces",
      "echo 'iface ens37 inet static' | sudo tee -a /etc/network/interfaces",
      "echo '  address 10.1.1.12' | sudo tee -a /etc/network/interfaces",
      "echo '  netmask 255.255.255.0' | sudo tee -a /etc/network/interfaces",
      "sudo ifup ens37",
      "sudo reboot",
    ]
  }
}
