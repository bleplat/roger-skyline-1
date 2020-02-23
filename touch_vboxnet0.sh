ifs=$(vboxmanage list hostonlyifs | grep vboxnet0)
if [ -z $ifs ];then
	vboxmanage hostonlyif create
fi
