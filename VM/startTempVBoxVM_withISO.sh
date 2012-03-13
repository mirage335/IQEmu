#!/bin/bash
#Developed and tested with VirtualBox version 4.1.4 on Linux host. Other configurations may be undefined.
#First parameter is ISO file to attach to VM. Intended to support IQEMU usage.

. ubiquitous_bash.sh

scriptFolder="$(getScriptAbsoluteFolder)"

export VBOX_IPC_SOCKETID=tempVBox_$(getUUID | sed s/-//g)
echo -e '\E[1;32;46mSocket id is '"$VBOX_IPC_SOCKETID"' .\E[0m'

VM_Name=$(getUUID | sed s/-//g)
VM_Folder="/tmp/tempVBox/$VM_Name"
echo -e '\E[1;32;46mVM_Folder is '"$VM_Folder"' .\E[0m'

export VBOX_USER_HOME="$VM_Folder"/temp_vBox_HOME

mkdir -p "$VM_Folder"

VBoxManage createvm --name "$VM_Name" --ostype Windows2003 --register --basefolder "$VM_Folder"
VBoxManage modifyvm "$VM_Name" --boot1 disk --biosbootmenu disabled --bioslogofadein off --bioslogofadeout off --bioslogodisplaytime 5 --vram 128 --memory 512 --nic1 nat --nictype1 "82543GC" --vrde off --ioapic on --acpi on --pae on --chipset ich9 --audio null --usb on --cpus 4 --accelerate3d off --accelerate2dvideo off
VBoxManage sharedfolder add "$VM_Name" --name "root" --hostpath "/"
VBoxManage storagectl "$VM_Name" --name "IDE Controller" --add ide --controller PIIX4
VBoxManage storageattach "$VM_Name" --storagectl "IDE Controller" --port 0 --device 0 --type hdd --medium "$scriptFolder"/virtualHardDisk.vdi --mtype multiattach
VBoxManage storageattach "$VM_Name" --storagectl "IDE Controller" --port 1 --device 0 --type dvddrive --medium "$1"

#Suppress annoying warnings.
VBoxManage setextradata global GUI/SuppressMessages "remindAboutAutoCapture,remindAboutMouseIntegrationOn,showRuntimeError.warning.HostAudioNotResponding,remindAboutGoingSeamless,remindAboutInputCapture,remindAboutGoingFullscreen,remindAboutMouseIntegrationOff,confirmGoingSeamless,confirmInputCapture,remindAboutPausedVMInput,confirmVMReset,confirmGoingFullscreen,remindAboutWrongColorDepth"

#Create suspend script.
echo '
#!/bin/bash'"
export VBOX_USER_HOME=""$VM_Folder""/temp_vBox_HOME""
export VBOX_IPC_SOCKETID=""$VBOX_IPC_SOCKETID"""'
VBoxManage controlvm '"$VM_Name"' savestate
' > "$VM_Folder"/suspend.sh
chmod ug+rx "$VM_Folder"/suspend.sh

VBoxSDL --startvm "$VM_Name"

while true
do
	sleep 1
	if [[ $(VBoxManage showvminfo --details --machinereadable "$VM_Name" | grep VMState\= | cut -d\= -f2 | sed s/\"//g) == "saved" ]]
	then #VM has not stopped, it has been suspended. Wait for user input, then resume, then loop again.
		xmessage "Press OK to resume VM."
		VBoxSDL --startvm "$VM_Name"
	else #VM has died. Time to move on.
		break
	fi
done

VBoxManage unregistervm "$VM_Name" --delete

if [[ -e "$VM_Folder" ]]
then
	echo -e '\E[1;31;44mRemoving folders:\E[0m\E[1;34m'
	echo -en "$VM_Folder"
	echo -e '\E[0m'
	#echo -e '\E[1;31;44mPress ENTER to continue or Ctrl+C to abort. \E[0m'
	#read
	rm --preserve-root -rfv "$VM_Folder"
	echo -e '\E[1;32;46mDeletion complete.\E[0m'
fi

VBoxXPCOMIPCD_PID=$(cat /tmp/\.vbox-"$VBOX_IPC_SOCKETID"-ipc/lock)
echo -e '\E[1;32;46mWaiting for VBoxXPCOMIPCD to finish.\E[0m'
while kill -0 "$VBoxXPCOMIPCD_PID"
do
	sleep 0.5
done
echo -e '\E[1;32;46mVBoxXPCOMIPCD finished. Removing IPC folder from filesystem.\E[0m'

rm -v /tmp/\.vbox-"$VBOX_IPC_SOCKETID"-ipc/ipcd
rm -v /tmp/\.vbox-"$VBOX_IPC_SOCKETID"-ipc/lock
rmdir -v /tmp/\.vbox-"$VBOX_IPC_SOCKETID"-ipc

echo -e '\E[1;32;46mVBoxXPCOMIPCD residue removed.\E[0m'