resource "esxi_guest" "dfirlab-win10" {
  count                 = 1
  guest_name            = "DFIRLab-${count.index + 1}-win10"
  notes                 = "Contact : me"
  disk_store            = var.datastore
  boot_disk_type        = "thin"
  memsize               = "4096"
  numvcpus              = "2"
  power                 = "on"
  guest_startup_timeout = "180"
  ovf_source            = "../packer/ova/template-Win10.ova"

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

  ## Send powershell script
  provisioner "file" {
    source = "../packer/SCRIPTS/install-zimmermantools.ps1"
    destination = "c:/windows/temp/install-zimmermantools.ps1"
  }
  provisioner "file" {
    source = "../packer/SCRIPTS/syspin.exe"
    destination = "c:/windows/temp/syspin.exe"
  }

  ## Command executed on remote VM through WINRM connection
  provisioner "remote-exec" {
    inline = [
      "powershell.exe \"Set-WinUserLanguageList -LanguageList fr-FR -Force\"",
      "powershell.exe \"Set-ItemProperty -Path 'HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize' -Name 'SystemUsesLightTheme' -Type DWord -Value 1\"",
      "powershell.exe \"netsh interface ip set address 'Ethernet0' static 10.1.1.13 255.255.255.0 10.1.1.254\"",
      "powershell.exe \"sleep 3; ping -n 3 10.1.1.15\"",
      "powershell.exe \"net use Z: \\\\10.1.1.15\\evidences /persistent:yes\"",
      "powershell.exe \" choco install -y --force ghidra\"",
      "powershell.exe \" choco install -y --force git\"",
      "powershell.exe \" choco install -y --force golang\"",
      "powershell.exe \" choco install -y --force putty\"",
      "powershell.exe \" choco install -y --force python2\"",
      "powershell.exe \" choco install -y --force python3\"",
      "powershell.exe \" choco install -y --force winscp\"",
      "powershell.exe \"Set-WindowsExplorerOptions -EnableShowFileExtensions -EnableShowFullPathInTitleBar -EnableExpandToOpenFolder -EnableShowRibbon\"",
      "powershell.exe \"Import-Module 'C:\\ProgramData\\Chocolatey\\helpers\\chocolateyInstaller.psm1' -Force; Install-ChocolateyShortcut -shortcutFilePath 'C:\\Users\\Public\\Desktop\\Evidences.lnk' -targetPath Z:; Install-ChocolateyShortcut -shortcutFilePath 'C:\\Users\\Public\\Desktop\\Tools.lnk' -targetPath C:\\ProgramData\\chocolatey\\bin; Install-ChocolateyShortcut -shortcutFilePath 'C:\\Users\\%USERNAME%\\Desktop\\putty.lnk' -targetPath C:\\ProgramData\\chocolatey\\bin\\putty.exe -PinToTaskbar\"; Install-ChocolateyShortcut -shortcutFilePath 'C:\\Users\\%USERNAME%\\Desktop\\ghidra.lnk' -targetPath C:\\ProgramData\\chocolatey\\lib\\ghidra\\tools\\ghidra_9.1.2_PUBLIC\\ghidraRun.bat -IconLocation C:\\ProgramData\\chocolatey\\lib\\ghidra\\tools\\ghidra_9.1.2_PUBLIC\\support\\ghidra.ico -PinToTaskbar \"",
      "powershell.exe \" choco install -y firefoxesr foxitreader googlechrome greenshot filezilla 7zip vscodium notepadplusplus keepass vlc\"",
      "powershell.exe \" choco install -y wireshark\"",
      "powershell.exe \" choco install -y volatility autopsy sleuthkit eraser network-miner\"",
      "powershell.exe \" choco install -y sysinternals --force --params '/InstallDir:C:\\ProgramData\\chocolatey\\bin\\sysinternals'\"",
      "powershell.exe -ep bypass -File c:/windows/temp/install-zimmermantools.ps1",
      "powershell.exe \" Invoke-WebRequest -uri https://vorboss.dl.sourceforge.net/project/autopsy/NSRL/NSRL-266m-computer-Autopsy.zip -OutFile C:\\Users\\%USERNAME%\\Downloads\\NSRL-266m-computer-Autopsy.zip \"",
      "powershell.exe \" 7z.exe e -oC:\\Users\\%USERNAME%\\Downloads\\  C:\\Users\\%USERNAME%\\Downloads\\NSRL-266m-computer-Autopsy.zip \"",
      "powershell.exe \"shutdown.exe /r /t 1\"",
      "powershell.exe \"shutdown.exe /r /t 1\"",
    ]
  }
}
