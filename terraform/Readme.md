# Terraform

source : https://www.terraform.io/

Le téléchargement du binaire s'effectue ici : https://www.terraform.io/downloads.html 

Une fois décompressé, celui-ci devra être déplacé dans un des répertoires du PATH pour pouvoir l'exécuter.

## Installation

``` 
sudo apt install golang
mkdir $HOME/go
export GOPATH="$HOME/go"

go get -u -v golang.org/x/crypto/ssh
go get -u -v github.com/hashicorp/terraform

git clone https://github.com/dzflack/terraform-provider-esxi.git
cd terraform-provider-esxi
git checkout -b "feature/add-network-ressources"

CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -ldflags '-w -extldflags "-static"' -o terraform-provider-esxi_`cat version`
sudo cp terraform-provider-esxi_`cat version` /usr/local/bin
``` 
