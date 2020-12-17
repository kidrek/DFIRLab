#cloud-config
autoinstall:
  version: 1
  locale: en_US
  keyboard:
    layout: fr
  network:
    network:
      version: 2
      ethernets:
        ens33:
          dhcp4: true
  storage:
    layout:
      name: lvm
  identity:
    hostname: template-ubuntu2004
    username: analyste
    password: <password_analyste>
  ssh:
    install-server: yes
  user-data:
    disable_root: false
  late-commands:
    - echo 'analyste ALL=(ALL) NOPASSWD:ALL' > /target/etc/sudoers.d/analyste
    - mkdir -p /target/home/analyste/.ssh/
    - echo '<analyste_ssh_key>' >> /target/home/analyste/.ssh/authorized_keys
