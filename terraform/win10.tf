resource "esxi_guest" "pin-win10" {
  count                 = 1
  guest_name            = "PIN-${count.index + 1}-WIN10"
  notes                 = "Contact : me"
  disk_store            = "datastore1"
  boot_disk_type        = "thin"
  #boot_disk_size        = "100"
  memsize               = "2048"
  numvcpus              = "2"
  power                 = "on"
  guest_startup_timeout = "180"

  ovf_source = "../ovf-template/packer-vmware-win10-iso.ova"

  network_interfaces {
    virtual_network = "Terraform-deployment"
    nic_type        = "e1000"
  }

  network_interfaces {
    virtual_network = "PIN-${count.index + 1}-vm"
    nic_type        = "e1000"
  }

  connection {
    host        = self.ip_address
    type        = "winrm"
    user        = "analyste"
    password    = "analyste"
    timeout     = "180s"
  }

  ## Command executed on remote VM through SSH connection
  provisioner "remote-exec" {
    inline = [
      "powershell.exe \"Set-WinUserLanguageList -LanguageList fr-FR -Force\"",
      "powershell.exe \"netsh interface ip set address 'Ethernet0' static 10.1.1.13 255.255.255.0 10.1.1.254\"",
      "powershell.exe \"sleep 3; ping -n 3 10.1.1.15\"",
      "powershell.exe \"net use Z: \\\\10.1.1.15\\evidences /persistent:yes\"",
      "powershell.exe \" choco install -y --force git\"",
      "powershell.exe \" choco install -y --force python2\"",
      "powershell.exe \" choco install -y --force python3\"",
      "powershell.exe \" choco install -y --force golang\"",
      "powershell.exe \" choco install -y --force putty\"",
      "powershell.exe \" choco install -y --force winscp\"",
      "powershell.exe \"Set-WindowsExplorerOptions -EnableShowFileExtensions -EnableShowFullPathInTitleBar -EnableExpandToOpenFolder -EnableShowRibbon\"",
      "powershell.exe \"Import-Module 'C:\\ProgramData\\Chocolatey\\helpers\\chocolateyInstaller.psm1' -Force; Install-ChocolateyShortcut -shortcutFilePath 'C:\\Users\\Public\\Desktop\\Evidences.lnk' -targetPath Z:; Install-ChocolateyShortcut -shortcutFilePath 'C:\\Users\\Public\\Desktop\\Tools.lnk' -targetPath C:\\ProgramData\\chocolatey\\bin; Install-ChocolateyShortcut -shortcutFilePath 'C:\\Users\\%USERNAME%\\Desktop\\putty.lnk' -targetPath C:\\ProgramData\\chocolatey\\bin\\putty.exe\"",
      "powershell.exe \" choco install -y firefoxesr googlechrome greenshot filezilla 7zip vscode notepadplusplus keepass vlc\"",
      "powershell.exe \" choco install -y wireshark\"",
      "powershell.exe \" choco install -y volatility autopsy sleuthkit eraser network-miner\"",
      "powershell.exe \" choco install -y sysinternals --force --params '/InstallDir:C:\\ProgramData\\chocolatey\\bin\\sysinternals'\"",
      "powershell.exe \"shutdown.exe /r /t 0\"",
      "powershell.exe \"shutdown.exe /r /t 0\"",
    ]
  }
}
