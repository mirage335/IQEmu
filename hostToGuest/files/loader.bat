:checkMount
ping -n 2 127.0.0.1 > nul
IF NOT EXIST "Z:\root" GOTO checkMount
