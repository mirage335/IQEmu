#!/bin/bash
#Developed and tested with VirtualBox version 4.1.4 on Linux host. Other configurations may be undefined.

. ubiquitous_bash.sh

if [[ -e "$(getScriptAbsoluteFolder)"/base_vBox_HOME && -e "$(getScriptAbsoluteFolder)"/Base ]]
then
	echo -e '\E[1;31;44mRemoving folders:\E[0m\E[1;34m'
	echo -e "$(getScriptAbsoluteFolder)/base_vBox_HOME"
	echo -en "$(getScriptAbsoluteFolder)/Base"
	echo -e '\E[0m'
	#echo -e '\E[1;31;44mPress ENTER to continue or Ctrl+C to abort. \E[0m'
	#read
	rm --preserve-root -rfv "$(getScriptAbsoluteFolder)"/base_vBox_HOME
	rm --preserve-root -rfv "$(getScriptAbsoluteFolder)"/Base
	echo -e '\E[1;32;46mDeletion complete.\E[0m'
fi

export VBOX_IPC_SOCKETID=tempVBox_$(getUUID | sed s/-//g)
export VBOX_USER_HOME="$(getScriptAbsoluteFolder)"/base_vBox_HOME

#Create temporary VM around persistent disk image.
VBoxManage createvm --name "tempVBoxBase" --ostype Windows2003 --register --basefolder "$(getScriptAbsoluteFolder)"/Base
VBoxManage modifyvm "tempVBoxBase" --vram 128 --memory 512 --nic1 nat --nictype1 "82543GC" --vrde off --ioapic on --acpi on --pae on --chipset ich9 --audio null --usb on --cpus 4 --accelerate3d off --accelerate2dvideo off
VBoxManage sharedfolder add "tempVBoxBase" --name "root" --hostpath "/"
VBoxManage storagectl "tempVBoxBase" --name "IDE Controller" --add ide --controller PIIX4
VBoxManage storageattach "tempVBoxBase" --storagectl "IDE Controller" --port 0 --device 0 --type hdd --medium "$(getScriptAbsoluteFolder)"/virtualHardDisk.vdi --mtype normal
VBoxManage storageattach "tempVBoxBase" --storagectl "IDE Controller" --port 1 --device 0 --type dvddrive --medium "$(getScriptAbsoluteFolder)"/../guestAssets/blank.iso
VBoxManage showhdinfo "$(getScriptAbsoluteFolder)"/virtualHardDisk.vdi

#Suppress annoying warnings.
VBoxManage setextradata global GUI/SuppressMessages "remindAboutAutoCapture,remindAboutMouseIntegrationOn,showRuntimeError.warning.HostAudioNotResponding,remindAboutGoingSeamless,remindAboutInputCapture,remindAboutGoingFullscreen,remindAboutMouseIntegrationOff,confirmGoingSeamless,confirmInputCapture,remindAboutPausedVMInput,confirmVMReset,confirmGoingFullscreen,remindAboutWrongColorDepth"

echo -e '\E[1;32;46m Preparatory work finished. VirtualBox GUI with registered base VM available. \E[0m'

VirtualBox

if [[ -e "$(getScriptAbsoluteFolder)"/base_vBox_HOME && -e "$(getScriptAbsoluteFolder)"/Base ]]
then
	echo -e '\E[1;31;44mRemoving folders:\E[0m\E[1;34m'
	echo -e "$(getScriptAbsoluteFolder)/base_vBox_HOME"
	echo -en "$(getScriptAbsoluteFolder)/Base"
	echo -e '\E[0m'
	#echo -e '\E[1;31;44mPress ENTER to continue or Ctrl+C to abort. \E[0m'
	#read
	rm --preserve-root -rfv "$(getScriptAbsoluteFolder)"/base_vBox_HOME
	rm --preserve-root -rfv "$(getScriptAbsoluteFolder)"/Base
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