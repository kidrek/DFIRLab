![](./DFIRLab.png)


DFIRLab est une plateforme d'investigation numérique facilement déployable.

Elle est actuellement constituée :
* d'un serveur de fichier SAMBA
* d'un serveur d'analyse, contenant une instance ELK
* d'un serveur d'analyse en sandbox Cuckoo/Capev2
* de deux machines contenant des outils d'analyse Forensic, Tsurugi (Ubuntu) et un environnement Microsoft Windows.

Les preuves sont à transférer vers le serveur de stockage (Samba). 
Une fois le transfert effectué, elles seront accessibles des autres serveurs.

!! Ce projet est toujours en cours d'élaboration !! 

# Table d'index

- [1. Mise en oeuvre](#1-mise-en-oeuvre)
  * [1.1. Installation de Packer](#11-installation-de-packer)
  * [1.2. Installation de Terraform](#12-installation-de-terraform)
- [2. Usage](#2-usage)
  * [2.1. Génération des templates via Packer](#21-génération-des-templates-via-packer)
  * [2.2. Déploiement de la plateforme via Terraform](#22-déploiement-de-la-plateforme-via-terraform)
  * [2.3 Tips](#23-tips)

  

## 1. Mise en oeuvre

Les templates de machine virtuelle sont générés grâce à l'outil Packer.
Le déploiement de la plateforme est quant à lui assuré par l'outil Terraform.
Il est préférable de dédier un serveur virtuel sous Linux de préférence pour y installer Packer et Terraform, pour faciliter la génération des templates et de leur déploiement.

Pré-requis logiciels : 
* Terraform
* Packer 
* Ovftool

Pré-requis :
* Portgroup dédié pour que le serveur Terraform puisse communiquer avec les templates nouvellement déployé.

### 1.1. Installation de Packer

Packer est une solution développée par HashiCorp disponible gratuitement.
Son rôle est de faciliter la génération de machines virtuelles à travers des fichiers de configuration "virtualmachineAScode".

Packer a un rôle important au sein de mon projet **DFIRLab**.
Il me permet d'élaborer, au format OVA, les templates des machines constituant l'analyse en SandBox, et celles dédiées à l'utilisation d'outils spécifiques.
Ces templates seront ensuite déployés grâce à Terraform.

L'installation de Packer s'effectue très facilement sur une grande majorité des systèmes d'exploitation.
Le binaire est téléchargeable ici : https://www.packer.io/downloads

Une fois téléchargé, le binaire devra être placé dans un répertoire du ```PATH``` pour pouvoir l'exécuter.

* Tips

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


### 1.2. Installation de Terraform 

source : https://www.terraform.io/

Le téléchargement du binaire s'effectue ici : https://www.terraform.io/downloads.html 
J'ai rencontré des problèmes avec la version 0.13. Je conseille pour l'instant d'utiliser la dernière release 0.12 en attendant de corriger les problèmes de compatibilités.
Une fois décompressé le binaire devra être déplacé dans un des répertoires du PATH.


``` 
wget https://releases.hashicorp.com/terraform/0.12.29/terraform_0.12.29_linux_amd64.zip
unzip terraform_0.12.29_linux_amd64.zip
mv terraform /usr/bin/

sudo apt install golang
mkdir $HOME/go
export GOPATH="$HOME/go"
go get -u -v golang.org/x/crypto/ssh

git clone https://github.com/kidrek/terraform-provider-esxi.git
cd terraform-provider-esxi
git checkout remotes/origin/feature/add-networking-resources
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -ldflags '-w -extldflags "-static"' -o terraform-provider-esxi_`cat version`
``` 

Une fois le provider compilé celui-ci devra être placé dans le répertoire ou se trouvent les fichiers de configuration au format ".tf" en respectant une arborescence spécifique.

```
mkdir -p ./terraform/terraform.d/plugins/linux_amd64
mv terraform-provider-esxi_v1.6.4 ./terraform/terraform.d/plugins/linux_amd64
```

L'initialisation du répertoire se fait à travers l'exécution de la commande : ```terraform init```.

```
cd ./terraform
terraform init
```


## 2. Usage

### 2.1. Génération des templates via Packer

L'outil Packer va permettre de générer les templates de machines virtuelles qui seront déployés par la suite par Terraform.
Avant que le processus ne soit automatisé, il est nécessaire de se placer dans le répertoire "/packer" puis dans chacun des répertoires nommés "template-XXXX" et d'y exécuter le script ```build.sh```. 
Chaque template a son fichier ```Readme.md``` apportant les informations nécessaires à son utilisation.

Ainsi en guise d'exemple, pour générer l'image de référence Debian :

```
cd ./packer/template-debian10/
./build.sh
```

L'ensemble des templates peut être généré en une fois en exécutant le script ```01_BuildTemplatesWithPacker.sh```. 


--
Cependant toute cette phase de génération de template ne peut être automatisée dans son intégralité.
La distribution Tsurugi ne permet pas pour le moment de s'installer de manière automatisée. Il n'est pas possible non plus d'interagir via Terraform lors du déploiement car le service SSH n'est pas activé de base (ce qui est une très bonne chose en soit).
Il est donc nécessaire dans un premier temps de télécharger la machine virtuelle Tsurugi mise à disposition sur leur site : https://tsurugi-linux.org/downloads.php.
Puis l'importer pour y apporter les modifications nécessaires et enfin l'exporter au format OVA pour que terraform puisse la déployer. 
Voici les actions à mener : 

* Activer le SSH.
* Configurer le SSH pour autoriser une authentification avec la clé privée générée précédemment, ou veiller à ce que le compte utilisateur tsurugi ait comme mot de passe "tsurugi".


### 2.2. Déploiement de la plateforme via Terraform

Le déploiement de l'architecture se déroule aussi facilement que la génération des templates. Il suffit de se placer dans le répertoire "/terraform", et d'y exécuter le script ```build.sh```.
Il est nécessaire d'éditer au préalable les fichiers ```00_main.tf``` et ```00_variables.tf``` pour y spécifier les informations indispensables au déploiement de l'architecture.

```
cd ./terraform/
./build.sh
```

Une fois déployée, le lab est accessible via une connexion VPN. 
Les preuves pourront être envoyées sur le serveur Samba, puis analysées.

### 2.3 Tips

Packer et Terraform utilisent une connexion SSH sur les machines virtuelles nouvellement créées pour y installer des paquets ou y appliquer certaines configurations. Afin d'éviter l'attente d'une validation 'Fingerprint' durant le déploiement, j'ai du appliquer la configuration suivante :

```
# vi $HOME/.ssh/config 
Host *
  StrictHostKeyChecking no
  UserKnownHostsFile=/dev/null
  ControlMaster auto
  ControlPath /tmp/socket-%r@%h:%p
  ControlPersist 3600
```


## 3. Analyse des preuves

### 3.1 Analyse statique
#### via Tsurugi
La distribution Tsurugi est composée de nombreux si ce n'est de l'intégralité des outils nécessaires pour mener à bien une investigation numérique.
Les preuves sont accessibles via le partage réseau fourni par le serveur Samba.

Seul le script ```/media/evidences/MEMORY/memory_autoanalyse.sh``` a été pour le moment ajouté. Il permet d'analyser de manière automatisée un prélèvement mémoire d'un système Windows. 
Il va déterminer seul le profil adéquat puis exécuter les différents plugins de l'outil **Volatility**. Les résultats seront analysés à leur tour par **Loki**, **Clamav** et **Yara** puis envoyés à l'instance **ElasticSearch**.


#### via la machine virtuelle Win10


### 3.2 Analyse dynamique
* via Cuckoo sandbox / CAPEv2

TODO

