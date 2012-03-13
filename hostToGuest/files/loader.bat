net use z: \\VBOXSVR\root

:checkZmount
ping -n 2 127.0.0.1 > nul
IF NOT EXIST "Z:\" GOTO checkZmount

net use x: \\VBOXSVR\appFolder

:checkXmount
ping -n 2 127.0.0.1 > nul
IF NOT EXIST "X:\" GOTO checkXmount
