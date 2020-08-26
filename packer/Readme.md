# Packer 

Packer est une solution développée par HashiCorp disponible gratuitement.
Son rôle est de faciliter la génération de machines virtuelles à travers des fichiers de configuration "virtualmachineAScode".

Packer a un rôle important au sein de mon projet PIN "Plateforme d'Investigation Numérique".
Il me permet d'élaborer, au format OVA, les templates des machines constituant l'analyse en SandBox, et celles dédiées à l'utilisation d'outils spécifiques.

Ces templates seront ensuite déployés grâce à Terraform.
Les configurations appliquées à Terraform permettront l'installation de nouveaux outils, notamment grâce à Chocolatey.

## Installation

L'installation s'effectue très facilement sur une grande majorité des systèmes d'exploitation.
Le binaire est téléchargeable ici : https://www.packer.io/downloads

Une fois téléchargé, le binaire devra être placé dans un répertoire du PATH pour pouvoir l'exécuter.



## Pré-requis

Packer utilise le protocole VNC pour l'installation des systèmes d'exploitation.
J'utilise dans mon cas un ESXi free, j'ai du ajouter via une connexion SSH sur l'hyperviseur une règle sur le parefeu pour authoriser le traffic VNC. 
Cette règle devra être accompagnée de l'adresse ip publique utilisée par le serveur Packer.

```
#!/bin/sh

## source : https://gist.github.com/Nonymus/6b8cc7653072fe7af74e064104717ad7

mkdir /store/firewall

# Copy the service.xml firewall rules to a central storage
# so they can survive reboot
cp /etc/vmware/firewall/service.xml /store/firewall

# Remove end tag so rule addition works as expected
sed -i "s/<\/ConfigRoot>//" /store/firewall/service.xml

# Add rule for vnc connections
echo "
  <service id='0033'>
    <id>vnc</id>
    <rule id='0000'>
      <direction>inbound</direction>
      <protocol>tcp</protocol>
      <porttype>dst</porttype>
      <port>
        <begin>5900</begin>
        <end>6000</end>
      </port>
    </rule>
    <enabled>true</enabled>
    <required>true</required>
  </service>
</ConfigRoot>" >> /store/firewall/service.xml

# Copy updated service.xml firewall rules to expected location
# Refresh the firewall rules
chmod 0644 /etc/vmware/firewall/service.xml
chmod +t /etc/vmware/firewall/service.xml
cat /store/firewall/service.xml > /etc/vmware/firewall/service.xml
chmod 0444 /etc/vmware/firewall/service.xml
chmod -t /etc/vmware/firewall/service.xml
esxcli network firewall refresh
sed -i "s/exit 0//" /etc/rc.local.d/local.sh

# Add steps to profile.local to repeat these steps on reboot
echo "
chmod 0644 /etc/vmware/firewall/service.xml
chmod +t /etc/vmware/firewall/service.xml
cat /store/firewall/service.xml > /etc/vmware/firewall/service.xml
chmod 0444 /etc/vmware/firewall/service.xml
chmod -t /etc/vmware/firewall/service.xml
esxcli network firewall refresh
exit 0" >> /etc/rc.local.d/local.sh
```
