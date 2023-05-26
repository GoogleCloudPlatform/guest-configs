#!/usr/bin/bash
# Install 65-gce-disk-naming.rules and
# google_nvme_id into the initramfs

# called by dracut
install() {
  inst_multiple nvme grep sed
  inst_simple /usr/lib/udev/google_nvme_id
  inst_simple /usr/lib/udev/rules.d/65-gce-disk-naming.rules
}

installkernel() {
  instmods nvme
}
