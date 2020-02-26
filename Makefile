###############
# C O N F I G #
###############
VM_NAME = RS1
VM_STORAGE = ~/goinfre/RS1.vdi
VM_ISO = /tmp/debian.iso
REMOTE_ISO = https://gemmei.ftp.acc.umu.se/debian-cd/current/i386/iso-cd/debian-10.3.0-i386-netinst.iso


#############
# R U L E S #
#############

all: hostonlyif $(VM_NAME) $(VM_STORAGE) $(VM_ISO) attachment

$(VM_NAME):
	VBoxManage createvm --name $@ --ostype Debian --basefolder . --register
	VBoxManage modifyvm $@ --memory 2048
	VBoxManage storagectl $@ --name 'SATA Controller' --add sata --controller IntelAhci
	VBoxManage storagectl $@ --name 'IDE Controller' --add ide
	VBoxManage modifyvm $@ --boot1 dvd --boot2 disk
	vboxmanage modifyvm $@ --nic1 bridged
	vboxmanage modifyvm $@ --bridgeadapter1 en0
	vboxmanage modifyvm $@ --nic2 hostonly
	vboxmanage modifyvm $@ --hostonlyadapter2 vboxnet0

$(VM_STORAGE):
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

.PHONY: start
start: hostonlyif attachment
	VBoxManage modifyvm $(VM_NAME) --vrde on
	VBoxManage modifyvm $(VM_NAME) --vrdemulticon on --vrdeport 3390
	VBoxManage --startvm $(VM_NAME)

.PHONY: stop
stop:
	VBoxManage controlvm $(VM_NAME) acpipowerbutton || true

.PHONY: clean
clean: stop
	rm -f $(VM_ISO)

.PHONY: hostonlyif
hostonlyif:
	sh touch_vboxnet0.sh
	vboxmanage hostonlyif ipconfig vboxnet0 --ip 192.168.56.1 --netmask 255.255.255.252

.PHONY: fclean
fclean: stop clean
	VBoxManage unregistervm $(VM_NAME) --delete

.PHONY: re
re: fclean all
