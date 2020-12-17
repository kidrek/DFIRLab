#!/bin/bash


###########################################
## Tools 
echo "[*] Install common tools"
sudo apt update; export DEBIAN_FRONTEND=noninteractive; echo "wireshark-common wireshark-common/install-setuid boolean true" | sudo debconf-set-selections ;sudo -E bash -c 'sudo apt install -yq jq keepassxc remmina terminator screen tmux python3-pip git-core cifs-utils clamav libvshadow-utils qemu-utils libevtx-utils tcpdump cifs-utils forensics-full'
# keepassxc : to store passwords
# remmina : to open RDP connection

## Docker installation
echo "[*] Install docker"
export DEBIAN_FRONTEND=noninteractive;sudo -E bash -c 'sudo apt install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common'
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
sudo apt update; export DEBIAN_FRONTEND=noninteractive;sudo apt install -y docker-ce docker-ce-cli containerd.io

## Docker Compose installation
echo "[*] Install docker-compose"
sudo wget $(curl -sL https://api.github.com/repos/docker/compose/releases/latest | jq -r '.assets[].browser_download_url' | grep -i linux | grep -v sha256) -O /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose



###########################################
## Install theme
git clone https://github.com/vinceliuice/vimix-gtk-themes.git /tmp/vimix-gtk-themes
chmod +x /tmp/vimix-gtk-themes/install.sh 
/tmp/vimix-gtk-themes/install.sh -c dark -t doder -s laptop
gsettings set org.gnome.desktop.interface gtk-theme "vimix-dark-laptop-doder"
gsettings set org.gnome.shell.extensions.user-theme name "vimix-dark-laptop-doder"
#gsettings set org.gnome.desktop.interface cursor-theme "Arc-Dark"

## Install theme-icon
mkdir $HOME/.icons
git clone https://github.com/daniruiz/flat-remix.git /tmp/flat-remix-icons
mv /tmp/flat-remix-icons/Flat-Remix-Blue-Dark $HOME/.icons/
gsettings set org.gnome.desktop.interface icon-theme "Flat-Remix-Blue-Dark"

## Configure Gnome
##
### Set wallpaper
mkdir -p /home/analyste/Pictures/
wget -O /home/analyste/Pictures/wallpaper_secubian.png https://github.com/kidrek/secubian/raw/master/wallpaper/wallpaper_secubian.png
gsettings set org.gnome.desktop.background picture-uri 'file:///home/analyste/Pictures/wallpaper_secubian.png'
##
### Enable maximize,minimize button on window
#gsettings get org.gnome.desktop.wm.preferences button-layout
gsettings set org.gnome.desktop.wm.preferences button-layout "appmenu:minimize,maximize,close"
##
### Set font size
gsettings set org.gnome.desktop.interface monospace-font-name 'Monospace 10'
gsettings set org.gnome.desktop.interface font-name 'Cantarell 10'
##
## Disable Auto-lock, Sleep
# disable session idle
gsettings set org.gnome.desktop.session idle-delay 0
##
# disable sleep when on AC power
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
##
## Disabling Animations
gsettings set org.gnome.desktop.interface enable-animations false


## Setup Gnome addon
sudo sudo apt install -y gnome-shell-extension-dash-to-panel gnome-shell-extension-desktop-icons
### Identify installed extension :  ll /usr/share/gnome-shell/extensions/
gnome-shell-extension-tool -e apps-menu@gnome-shell-extensions.gcampax.github.com
gnome-shell-extension-tool -e auto-move-windows@gnome-shell-extensions.gcampax.github.com
gnome-shell-extension-tool -e caffeine@patapon.info
gnome-shell-extension-tool -e dash-to-panel@jderose9.github.com
gnome-shell-extension-tool -e desktop-icons@csoriano
gnome-shell-extension-tool -e places-menu@gnome-shell-extensions.gcampax.github.com
gnome-shell-extension-tool -e user-theme@gnome-shell-extensions.gcampax.github.com
gnome-shell-extension-tool -e workspace-indicator@gnome-shell-extensions.gcampax.github.com
#gnome-shell-extension-tool -e apps-menu@gnome-shell-extensions.gcampax.github.com

## Configure dash-to-panel
# gsettings list-keys org.gnome.shell.extensions.dash-to-panel
gsettings set org.gnome.shell.extensions.dash-to-panel panel-size 38
gsettings set org.gnome.shell.extensions.dash-to-panel dot-style-focused 'DOTS'
gsettings set org.gnome.shell.extensions.dash-to-panel dot-style-unfocused 'DOTS'

## Set/Remove favorites from Dash-panel
#gsettings get org.gnome.shell favorite-apps
gsettings set org.gnome.shell favorite-apps "['firefox-esr.desktop', 'terminator.desktop', 'gedit.desktop','org.keepassxc.KeePassXC.desktop', 'org.remmina.Remmina.desktop']"


###########################################
## DOCUMENTATION
###########################################
mkdir -p /home/analyste/Documents/ebook
cd /home/analyste/Documents/ebook
wget https://raw.githubusercontent.com/teamdfir/sift-saltstack/master/sift/files/sift/resources/Evidence-of-Poster.pdf
wget https://raw.githubusercontent.com/teamdfir/sift-saltstack/master/sift/files/sift/resources/Find-Evil-Poster.pdf
wget https://raw.githubusercontent.com/teamdfir/sift-saltstack/master/sift/files/sift/resources/SANS-DFIR.pdf
wget https://raw.githubusercontent.com/teamdfir/sift-saltstack/master/sift/files/sift/resources/Smartphone-Forensics-Poster.pdf
wget https://raw.githubusercontent.com/teamdfir/sift-saltstack/master/sift/files/sift/resources/memory-forensics-cheatsheet.pdf
wget https://raw.githubusercontent.com/teamdfir/sift-saltstack/master/sift/files/sift/resources/network-forensics-cheatsheet.pdf
wget https://raw.githubusercontent.com/teamdfir/sift-saltstack/master/sift/files/sift/resources/sift-cheatsheet.pdf
wget https://raw.githubusercontent.com/teamdfir/sift-saltstack/master/sift/files/sift/resources/windows-to-unix-cheatsheet.pdf
ln -s /home/analyste/Documents/ /home/analyste/Desktop


###########################################
## DFIR / TOOLS
###########################################


########################################### ANALYSE ANTIVIRUS
########################### SIGMA Rules
sudo git clone https://github.com/Neo23x0/sigma /opt/sigma
########################### YARA RULES by fortuna
cd /opt/; sudo wget https://gist.githubusercontent.com/andreafortuna/29c6ea48adf3d45a979a78763cdc7ce9/raw/4ec711d37f1b428b63bed1f786b26a0654aa2f31/malware_yara_rules.py -O ./malware_yara_rules.py; sudo mkdir rules 2>/dev/null; sudo python malware_yara_rules.py

########################### Loki
sudo git clone https://github.com/Neo23x0/Loki.git /opt/Loki; cd /opt/Loki; sudo apt install -y python-pip; sudo pip2 install -r requirements.txt; yes yes | sudo python2 loki.py --update
########################### CAPA
sudo git clone https://github.com/kidrek/docker-capa.git /opt/docker-capa; cd /opt/docker-capa; sudo docker build -t capa .
########################### SURICATA
sudo apt update; sudo apt -y install libpcre3 libpcre3-dbg libpcre3-dev build-essential autoconf automake libtool libpcap-dev libnet1-dev libyaml-0-2 libyaml-dev zlib1g zlib1g-dev libmagic-dev libcap-ng-dev libjansson-dev pkg-config rustc cargo
cd /opt/; sudo wget --no-check-certificate https://www.openinfosecfoundation.org/download/suricata-5.0.4.tar.gz; sudo tar xvzf suricata-5.0.4.tar.gz; cd suricata-5.0.4; sudo ./configure --enable-nfqueue --prefix=/usr --sysconfdir=/etc --localstatedir=/var; sudo make; sudo make install-full


########################################### ANALYSE Tools
########################### ELK
sudo useradd elk
sudo usermod -a -G docker elk
sudo /etc/init.d/docker start
sudo mkdir /opt/docker-elk
sudo chown -R elk: /opt/docker-elk
sudo -u elk git clone https://github.com/deviantony/docker-elk.git /opt/docker-elk
sudo -u elk sed -i 's/xpack.security.enabled: true/xpack.security.enabled: false/g'  /opt/docker-elk/elasticsearch/config/elasticsearch.yml
cd /opt/docker-elk; sudo -u elk docker-compose up -d

########################### Timesketch
### Timesketch docker
cd /opt/; sudo curl -s -O https://raw.githubusercontent.com/google/timesketch/master/contrib/deploy_timesketch.sh; sudo chmod 755 deploy_timesketch.sh; sudo ./deploy_timesketch.sh
sudo cp -rf /opt/sigma/rules/windows/ timesketch/etc/timesketch/sigma/rules/
sudo cp -rf /opt/sigma/rules/linux/ timesketch/etc/timesketch/sigma/rules/
cd /opt/timesketch/etc/timesketch; sudo ln -s . data
cd /opt/timesketch; sudo docker-compose up -d
#echo "cd /opt/timesketch; sudo -u elk docker-compose exec timesketch-web tsctl add_user -u analyste -p analyste 1>/dev/null 2>&1" | sudo tee -a /home/analyste/.bashrc

###########################################
## Log2timeline
sudo git clone https://github.com/log2timeline/plaso /opt/docker-plaso
cd /opt/docker-plaso/config/docker; sudo docker build -f Dockerfile .
sudo docker run log2timeline/plaso log2timeline.py --version
echo 'docker run -v $(pwd):/data log2timeline/plaso log2timeline --no_dependencies_check -u -q --partitions all --volumes all -z UTC --yara_rules /data/malware_rules.yar -f /data/filter_windows.txt  /data/evidences.plaso /data/<evidence>' | sudo tee /opt/readme_plaso.txt
echo 'docker run -v $(pwd):/data log2timeline/plaso psort -o l2tcsv -w /data/evidence-timeline.csv /data/evidence.plaso' | sudo tee -a /opt/readme_plaso.txt
mkdir -p /home/analyste/Documents/DFIR
cd /home/analyste/Documents/DFIR; wget https://raw.githubusercontent.com/log2timeline/plaso/master/data/filter_windows.txt

