resource "esxi_guest" "dfirlab-win10" {
  count                 = 1
  guest_name            = "DFIRLab-${count.index + 1}-win10"
  notes                 = "Contact : me"
  disk_store            = var.datastore
  boot_disk_type        = "thin"
  memsize               = "2048"
  numvcpus              = "2"
  power                 = "on"
  guest_startup_timeout = "180"
  ovf_source            = "../packer/ova/template-Win10--dfir.ova"

  # Network configuration
  network_interfaces {
    virtual_network     = var.network-portgroup-deployment
    nic_type            = "e1000"
  }

  network_interfaces {
    virtual_network = "DFIRLab-${count.index + 1}-vm"
    nic_type        = "e1000"
  }

  # Connection used to apply some modifications on system
  connection {
    host        = self.ip_address
    type        = "winrm"
    user        = "analyste"
    password    = "analyste"
    timeout     = "280s"
  }

  ## Command executed on remote VM through WINRM connection
  provisioner "remote-exec" {
    inline = [
      "powershell.exe \"netsh interface ip set address 'Ethernet0' static 10.1.1.13 255.255.255.0 10.1.1.254\"",
      "powershell.exe \"sleep 3; ping -n 3 10.1.1.15\"",
      "powershell.exe \"net use Z: \\\\10.1.1.15\\evidences /persistent:yes\"",
      "powershell.exe \"Import-Module 'C:\\ProgramData\\Chocolatey\\helpers\\chocolateyInstaller.psm1' -Force; Install-ChocolateyShortcut -shortcutFilePath 'C:\\Users\\Public\\Desktop\\Evidences.lnk' -targetPath Z:;\""
   ]
  }
}
