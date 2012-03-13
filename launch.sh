#!/bin/bash
#This script begins all application logic. Parameters should be those desired for the VM application to receive (with win-nix parameter translation).

#Import ubiquitous_bash.
. ubiquitous_bash.sh

scriptLocation="$(getScriptAbsoluteFolder)"

InstanceDirUUID=$(getUUID)

"$scriptLocation"/commInit.sh $InstanceDirUUID
"$scriptLocation"/wrapper.sh $InstanceDirUUID "$@"
"$scriptLocation"/createISO.sh $InstanceDirUUID
"$scriptLocation"/execVM.sh $InstanceDirUUID
"$scriptLocation"/commNULL.sh $InstanceDirUUID