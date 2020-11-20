
resource "esxi_virtual_switch" "dfirlab-vswitch" {
  count             = 1
  virtual_switch_name = "DFIRLab-${count.index + 1}-vswitch"
}

resource "esxi_port_group" "dfirlab-vm" {
  count             = 1
  port_group_name   = "DFIRLab-${count.index + 1}-vm"
  virtual_switch_id = esxi_virtual_switch.dfirlab-vswitch[count.index].id
}

resource "esxi_port_group" "dfirlab-malware-analysis" {
  count             = 1
  port_group_name   = "DFIRLab-${count.index + 1}-malware-analysis"
  virtual_switch_id = esxi_virtual_switch.dfirlab-vswitch[count.index].id
}
