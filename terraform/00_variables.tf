## Network : portgroup used by terraform to established connection with remote system
variable "network-portgroup-deployment" {
  type    = string
  default = "<portgroup--terraform-deployment>"
}

## Storage : Datastore used to store VM
variable "datastore" {
  type    = string
  default = "<esx_datastore>"
}

## Storage : Disk size
variable "extended-storage_sizes" {
  type    = map
  default = {
    "vm--storage-disk2-evidences" = "50"
  }
}
