![](./DFIRLab.png)


DFIRLab est une plateforme d'investigation numérique facilement déployable.

Elle est actuellement constituée :
* d'un serveur de fichier SAMBA
* d'un serveur d'analyse, contenant une instance ELK
* d'un serveur d'analyse en sandbox Cuckoo/Capev2
* de deux machines contenant des outils d'analyse Forensic, en environnement Debian et Microsoft Windows.

Les preuves sont à transférer vers le serveur de stockage (Samba). 
Une fois le transfert effectué, elles seront accessibles des autres serveurs.

!! Ce projet est toujours en cours d'élaboration !! 

## Mise en oeuvre

Les templates de machine virtuelle sont générés grâce à l'outil Packer.
Le déploiement de la plateforme est quant à lui assuré par l'outil Terraform.
Il est préférable de dédier un serveur virtuel sous Linux de préférence pour y installer Packer et Terraform, pour faciliter la génération des templates et de leur déploiement.

Pré-requis logiciels : 
* Terraform
* Packer 
* Ovftool

Pré-requis :
* Portgroup dédié pour que le serveur Terraform puisse communiquer avec les templates nouvellement déployé.

### 1. Installation de Packer

Packer est une solution développée par HashiCorp disponible gratuitement.
Son rôle est de faciliter la génération de machines virtuelles à travers des fichiers de configuration "virtualmachineAScode".

Packer a un rôle important au sein de mon projet **DFIRLab**.
Il me permet d'élaborer, au format OVA, les templates des machines constituant l'analyse en SandBox, et celles dédiées à l'utilisation d'outils spécifiques.
Ces templates seront ensuite déployés grâce à Terraform.

L'installation de Packer s'effectue très facilement sur une grande majorité des systèmes d'exploitation.
Le binaire est téléchargeable ici : https://www.packer.io/downloads

Une fois téléchargé, le binaire devra être placé dans un répertoire du ```PATH``` pour pouvoir l'exécuter.

#### Tips

Packer utilise le protocole VNC pour l'installation des systèmes d'exploitation.
J'utilise dans mon cas un ESXi free, j'ai du ajouter via une connexion SSH sur l'hyperviseur une règle sur le parefeu pour authoriser le traffic VNC. 
Cette règle devra être accompagnée de l'adresse ip publique utilisée par le serveur Packer afin de limiter l'accès à ce service.

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


## Usage

### 1. Génération des templates via Packer (/packer)

L'outil Packer va permettre de générer les templates de machines virtuelles qui seront déployés par la suite par Terraform.
Avant que le processus ne soit automatisé, il est nécessaire de se placer dans le répertoire "/packer" puis dans chacun des répertoires nommés "template-XXXX" et d'y exécuter le script ```build.sh```.

Ainsi en guise d'exemple, pour générer l'image de référence Debian :

```
cd packer/template-debian10/
./build.sh
```


### 2. Déploiement de l'architecture via Terraform (/terraform)

Le déploiement de l'architecture se déroule aussi facilement que la génération des templates. Il suffit de se placer dans le répertoire "/terraform", et d'y exécuter le script ```build.sh```.
Il est nécessaire d'éditer au préalable les fichiers ```00_main.tf``` et ```00_variables.tf``` pour y spécifier les informations indispensables au déploiement de l'architecture.

```
cd terraform/
./build.sh
```

### Tips

Packer et Terraform utilise une connexion SSH sur les machines virtuelles nouvelles créées pour y installer des paquets ou y appliquer certaines configurations. Afin d'éviter l'attente d'une validation 'Fingerprint' durant le déploiement, j'ai du appliquer la configuration suivante :

```
# vi $HOME/.ssh/config 
Host *
  StrictHostKeyChecking no
  UserKnownHostsFile=/dev/null
  ControlMaster auto
  ControlPath /tmp/socket-%r@%h:%p
  ControlPersist 3600
```
