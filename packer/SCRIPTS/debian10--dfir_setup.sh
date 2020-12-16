#!/bin/bash

## Tools 
sudo apt install -y keepassxc remmina terminator screen tmux
# keepassxc : to store passwords
# remmina : to open RDP connection


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
sudo sudo apt install -y gnome-shell-extension-dash-to-panel gnome-shell-extension-desktop-icons caffeine gnome-shell-extension-caffeine
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



