#!/bin/bash
#This script should not exit until the application and VM are finished.
#This script was written for VMWare Workstation 7.11. It is not guaranteed to succeed with other versions. Furthermore, it is not known whether VMWare Player offers the necessary vmrun command line functionality.

#Import ubiquitous_bash.
. ubiquitous_bash.sh

scriptLocation="$(getScriptAbsoluteFolder)"

InstanceDirUUID=$1

InstanceDir=/tmp/IQemu/$InstanceDirUUID

#QEMU Command from reference implementation.
#qemu -drive file="$scriptLocation"/vmImage.img,index=0,media=disk -drive file="$scriptLocation"/guestAssets/XP_Pro_SP3_Activated.iso,index=1,media=cdrom -drive file="$scriptLocation"/guestAssets/VMWareDrivers.iso,index=2,media=cdrom -drive file="$InstanceDir"/hostToGuest/hostToGuest.iso,index=3,media=cdrom -m 256 -rtc base=localtime,clock=host -usb -usbdevice tablet -net nic,model=pcnet -net user -sdl -vga cirrus -soundhw es1370 -name $InstanceDirUUID

vmrun snapshot "$scriptLocation"/VM/AppVM.vmx "$InstanceDirUUID"

vmrun clone "$scriptLocation"/VM/AppVM.vmx "$InstanceDir"/VM_Clone/AppVM_TemporaryClone.vmx linked "$InstanceDirUUID"

#Attach hostToGuest.iso image to VMX. 
echo "scsi0:1.present = \"TRUE\"" >> "$InstanceDir"/VM_Clone/AppVM_TemporaryClone.vmx
echo "scsi0:1.fileName = \"$InstanceDir/hostToGuest/hostToGuest.iso\"" >> "$InstanceDir"/VM_Clone/AppVM_TemporaryClone.vmx
echo "scsi0:1.deviceType = \"cdrom-image\"" >> "$InstanceDir"/VM_Clone/AppVM_TemporaryClone.vmx

# Set VMX window title.
cat "$InstanceDir"/VM_Clone/AppVM_TemporaryClone.vmx | grep -v displayName > "$InstanceDir"/VM_Clone/AppVM_TemporaryClone.vmx.edit
rm "$InstanceDir"/VM_Clone/AppVM_TemporaryClone.vmx
mv "$InstanceDir"/VM_Clone/AppVM_TemporaryClone.vmx.edit "$InstanceDir"/VM_Clone/AppVM_TemporaryClone.vmx
echo "displayName = \"$InstanceDirUUID\"" >> "$InstanceDir"/VM_Clone/AppVM_TemporaryClone.vmx

#Below, two sets of commands are available. The first starts vmplayer, a free and minimalistic interface. The second statrs a full VMWare Workstation GUI, the primary advantages of which are snapshot, record, and replay support.

#Start vmplayer.
#vmplayer "$InstanceDir"/VM_Clone/AppVM_TemporaryClone.vmx

#Start VMWare Workstation console.
vmware --name "$InstanceDirUUID - VMWare Workstation  VM Window" -n -x "$InstanceDir"/VM_Clone/AppVM_TemporaryClone.vmx

wait #wait for process
echo "Process wait finished. Waiting for window to close..."
while (wmctrl -lx | grep "$InstanceDirUUID.*-.*VMWare.*Workstation.*VM.*Workstation" > /dev/null) #Sometimes the vmware process will exit before GUI. Wait for GUI to end.
do
	sleep 1
done

#Forcibly poweroff VM if it was sent to background.
echo "Ensuring VM is powered down..."
vmrun stop "$InstanceDir"/VM_Clone/AppVM_TemporaryClone.vmx hard

echo "Cleaning up old snapshot..."
vmrun deleteSnapshot "$scriptLocation"/VM/AppVM.vmx "$InstanceDirUUID"