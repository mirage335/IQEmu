#!/bin/bash 

#Import ubiquitous bash functions
. ubiquitous_bash.sh

InstanceDirUUID=$1

InstanceDir=/tmp/IQemu/$InstanceDirUUID

mkisofs -R -uid 0 -gid 0 -dir-mode 0555 -file-mode 0555 -new-dir-mode 0555 -J -hfs -o $InstanceDir/hostToGuest/hostToGuest.iso $InstanceDir/hostToGuest/files
