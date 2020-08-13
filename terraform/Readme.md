# Terraform

source : https://www.terraform.io/

Le téléchargement du binaire s'effectue ici : https://www.terraform.io/downloads.html 
J'ai rencontré des problèmes avec la version 0.13. 
Je conseille d'utiliser la dernière release 0.12 en attendant de corriger les problèmes de compatibilités.

Une fois décompressé, celui-ci devra être déplacé dans un des répertoires du PATH pour pouvoir l'exécuter.

## Installation

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

Une fois placé dans le répertoire contenant la configuration au format ".tf".
Créer l'arborescence ci-dessous afin d'y placer le provider nouvellement généré.

```
mkdir -p terraform.d/plugins/linux_amd64
mv terraform-provider-esxi_v1.6.4 terraform.d/plugins/linux_amd64
```

L'initialisation du répertoire se fait à travers l'exécution de la commande : ```terraform init```.
