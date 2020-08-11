
resource "esxi_virtual_switch" "pin-vswitch" {
  count             = 1
  virtual_switch_name = "PIN-${count.index + 1}-vswitch"
}

resource "esxi_port_group" "pin-vm" {
  count             = 1
  port_group_name   = "PIN-${count.index + 1}-vm"
  virtual_switch_id = esxi_virtual_switch.pin-vswitch[count.index].id
}

resource "esxi_port_group" "pin-malware-analysis" {
  count             = 1
  port_group_name   = "PIN-${count.index + 1}-malware-analysis"
  virtual_switch_id = esxi_virtual_switch.pin-vswitch[count.index].id
}
