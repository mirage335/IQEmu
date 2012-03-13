#!/bin/bash
#modified version of win-nix_param_converter.sh
#adds 'root' as in 'Z:\root\xyz' instead of 'Z:\xyz'
#Old, crude script for converting unix /home/xyz/abc file parameters to Z:\home\xyz\abc style parameters windows can understand.

# Copyright (c) 2012 mirage335

# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#First parameter passed to this script is the "parameter" to check for local dir or fileparam information. If it does not contain "local_dir" or does not exist, it is assumed to be a regular parameter.
#Second parameter is the local dir (directory which mounts remote Windows PC or VM C drive).
#Conversion to realpaths will not occur if argument points to a file that actually exists. However, if an absolute parameter is input to $1 and/or $2, they will be treated as if existant for the purposes of shared location translation.

#Deprecated: Using realpath now
#param="$1"
#local_dir="$2"

#Retrieves absolute path, while maintaining symlinks, even when "./" would translate with "readlink -f" into something disregarding symlinked components in $PWD.
#Suitable for finding absolute paths, when it is desirable not to interfere with symlink specified folder structure.
if [[ (-e $PWD\/$1) && ($1 != "") ]]
	then
param="$PWD"\/"$1"
param=$(realpath -s "$param")
	else
param="$1"
fi

#Retrieves absolute path, while maintaining symlinks, even when "./" would translate with "readlink -f" into something disregarding symlinked components in $PWD.
#Suitable for finding absolute paths, when it is desirable not to interfere with symlink specified folder structure.
if [[ (-e $PWD\/$2) && ($2 != "") ]]
	then
local_dir="$PWD"\/"$2"
local_dir=$(realpath -s "$local_dir")
	else
local_dir="$2"
fi

#Declare our functions
function checkl {

#Check for local dir information.
if [[ $param == ${local_dir}* ]]
	then
shared_location=${param}

#Remove mount point information
shared_location=${shared_location/${local_dir}}
shared_location=${shared_location/#\/}

#Translate location
shared_location=C:\\${shared_location}

#Translate slashes
shared_location=${shared_location//\//\\}

#Print result
echo $shared_location
exit 0				#End this script
	else
#This parameter does not contain local dir information.
checkf	#Check for fileparam information anyway.
fi

}

function checkf {

#Check for fileparam information.
if [[ -e $param || -e ${param/#file:\/\/} ]]
	then
fileparam=${param/#file:\/\/}

#Translate location
fileparam=Z:\\root\\${fileparam/\/}

#Translate slashes
fileparam=${fileparam//\//\\}

#Print result
echo $fileparam
exit 0				#End this script
	else
echo $param			#Print parameter.
exit 0				#End this script.
fi

}


if [[ $param == !* ]] 		#Check for abort character.
	then
param=${param/#\!}		#Remove first character.
echo $param			#Print parameter.
exit 0				#End this script.
	else
sleep 0				#Continue script execution.
fi


#Check that the local_dir is not blank. If it is, return parameter and abort.
if [[ ${local_dir} != \/* ]]
	then
checkf	#Check for fileparam information anyway.
	else
checkl	#Check for local dir information.
fi
