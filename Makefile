###############
# C O N F I G #
###############
VM_FOLDER = ~/roger-skyline-1/
VM_NAME = RS1
VM_CHECKSUM = sha1-disk-checksum
VM_SNAPSHOT = $(VM_NAME).snapshot
VM_SNAPSHOT_FILE = ./$(VM_NAME)/Snapshots/$(VM_SNAPSHOT)


VM_GOINFRE = ~/roger-skyline-1/goinfre
VM_STORAGE = $(VM_GOINFRE)/RS1.vdi

VM_ISO = /tmp/debian.iso
REMOTE_ISO = https://gensho.ftp.acc.umu.se/debian-cd/current/i386/iso-cd/debian-10.4.0-i386-netinst.iso

NET_INTERFACE = wlp3s0



#############
# R U L E S #
#############

all: hostonlyif $(VM_NAME) $(VM_STORAGE) $(VM_ISO) attachment

$(VM_GOINFRE):
	mkdir -p $@

$(VM_NAME):
	VBoxManage createvm --name $@ --ostype Debian --register --basefolder $(VM_FOLDER)
	VBoxManage modifyvm $@ --memory 2048
	VBoxManage storagectl $@ --name 'SATA Controller' --add sata --controller IntelAhci
	VBoxManage storagectl $@ --name 'IDE Controller' --add ide
	VBoxManage modifyvm $@ --boot1 dvd --boot2 disk
	vboxmanage modifyvm $@ --nic1 bridged
	vboxmanage modifyvm $@ --bridgeadapter1 $(NET_INTERFACE)
	vboxmanage modifyvm $@ --nic2 hostonly
	vboxmanage modifyvm $@ --hostonlyadapter2 vboxnet0

$(VM_STORAGE): | $(VM_GOINFRE)
	VBoxManage createhd --filename $(VM_STORAGE) --size 8000 --format VDI

$(VM_ISO):
	curl $(REMOTE_ISO) > $(VM_ISO)
	ls -lh $@

.PHONY: attachment
attachment: $(VM_NAME) $(VM_STORAGE) $(VM_ISO)
	VBoxManage storageattach $(VM_NAME) --storagectl 'SATA Controller' --port 0 --device 0 --type hdd --medium $(VM_STORAGE)
	VBoxManage storageattach $(VM_NAME) --storagectl 'IDE Controller' --port 1 --device 0 --type dvddrive --medium $(VM_ISO)

.PHONY: info
info:
	VBoxManage showvminfo $(VM_NAME)

.PHONY: clean_iso
clean_iso:
	rm -f $(VM_ISO)

.PHONY: clean
clean: stop

.PHONY: hostonlyif
hostonlyif:
	sh touch_vboxnet0.sh
	vboxmanage hostonlyif ipconfig vboxnet0 --ip 192.168.56.1 --netmask 255.255.255.252

.PHONY: fclean
fclean: stop clean
	VBoxManage unregistervm $(VM_NAME) --delete

.PHONY: re
re: fclean all


################
# RUN AND TEST #
################

.PHONY: start
start: hostonlyif attachment
	VBoxManage modifyvm $(VM_NAME) --vrde on
	VBoxManage modifyvm $(VM_NAME) --vrdemulticon on --vrdeport 3390
	VBoxManage startvm $(VM_NAME) --type headless

.PHONY: stop
stop:
	sh stop.sh $(VM_NAME) 4

.PHONY: $(VM_CHECKSUM)
$(VM_CHECKSUM):
	shasum $(VM_STORAGE) > $@
	git add $@
.PHONY: checksum
checksum: $(VM_CHECKSUM)

.PHONY: run_snapshot
run_snapshot: snapshot
	VBoxManage startvm $(VM_NAME) --type headless

.PHONY: snapshot
snapshot: $(VM_SNAPSHOT_FILE)
$(VM_SNAPSHOT_FILE):
	VBoxManage snapshot $(VM_NAME) take $(VM_SNAPSHOT)

.PHONY: restore
restore: stop
	VBoxManage snapshot $(VM_NAME) restore $(VM_SNAPSHOT)
	VBoxManage snapshot $(VM_NAME) delete $(VM_SNAPSHOT)

.PHONY: add
add: checksum
	git add $(VM_CHECKSUM)
