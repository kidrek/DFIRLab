resource "esxi_guest" "dfirlab-tsurugi" {
  count                 = 1
  guest_name            = "DFIRLab-${count.index + 1}-tsurugi"
  notes                 = "Contact : me"
  disk_store            = var.datastore
  memsize               = "4096"
  numvcpus              = "4"
  power                 = "on"
  guest_startup_timeout = "180"
  ovf_source            = "../packer/ova/tsurugi_linux_2020.1_vm.ovf"

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
    user        = "tsurugi"
    password    = "tsurugi"
    timeout     = "180s"
  }

  ## Command executed on remote VM through SSH connection
  provisioner "remote-exec" {
    inline = [
      "echo 'dfirlab-tsurugi' | sudo tee /etc/hostname",
      "echo 'alias ll=\"ls -la\"' | sudo tee -a /home/tsurugi/.bashrc",
      "echo 'sudo setxkbmap fr' | sudo tee -a /home/tsurugi/.bashrc",
      "echo 'alias ll=\"ls -la\"' | sudo tee -a /root/.bashrc",
      "echo '127.0.0.1    dfirlab-tsurugi' | sudo tee /etc/hosts",
      "sudo apt update; sudo apt upgrade -y",
      "echo 'auto ens34' | sudo tee -a /etc/network/interfaces",
      "echo 'iface ens34 inet static' | sudo tee -a /etc/network/interfaces",
      "echo '  address 10.1.1.12' | sudo tee -a /etc/network/interfaces",
      "echo '  netmask 255.255.255.0' | sudo tee -a /etc/network/interfaces",
      "sudo ip link set dev ens34 down",
      "sudo ip link set dev ens34 up;",
      "sudo mkdir -p /media/encase",
      "sudo mkdir /media/evidences/",
      "echo '//10.1.1.15/evidences /media/evidences cifs guest,rw,iocharset=utf8 0 0' | sudo tee -a /etc/fstab",
      "sudo /sbin/mount.cifs //10.1.1.15/evidences /media/evidences -o guest,rw,iocharset=utf8; sudo chmod -R 777 /media/evidences",
      "cd /opt/volatility; sudo wget https://patch-diff.githubusercontent.com/raw/volatilityfoundation/volatility/pull/563.patch; sudo patch -fs -p1  < ./563.patch",
      "cd /opt/volatility; sudo python setup.py install",
      "sudo git clone https://github.com/Neo23x0/Loki.git /opt/Loki; cd /opt/Loki; sudo apt install -y python-pip; sudo pip2 install -r requirements.txt; sudo python2 loki.py --update;",
       "sudo apt update; sudo apt -y install libpcre3 libpcre3-dbg libpcre3-dev build-essential autoconf automake libtool libpcap-dev libnet1-dev libyaml-0-2 libyaml-dev zlib1g zlib1g-dev libmagic-dev libcap-ng-dev libjansson-dev pkg-config rustc cargo",
       "cd /opt/; sudo wget https://www.openinfosecfoundation.org/download/suricata-5.0.4.tar.gz; sudo tar xvzf suricata-5.0.4.tar.gz; cd suricata-5.0.4; sudo ./configure --enable-nfqueue --prefix=/usr --sysconfdir=/etc --localstatedir=/var; sudo make; sudo make install-full",
      "echo 'up route add -net 10.8.0.0/24 gw 10.1.1.254 dev ens34' | sudo tee -a /etc/network/interfaces",
      "sudo shutdown -r +1"
    ]
  }
}
