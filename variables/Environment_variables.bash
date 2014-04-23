#!/bin/bash
#Environment variables are variables that are not defined in the current process, but are received from the parent processes.
HTTP_PROXY=http://192.168.0.2:3128
export HTTP_PROXY
#The export command is used to set the env variable. Now any application, executed from the current shell script will receive this variable.

echo $PATH
export PATH="$PATH:/home/user/bin"
#equivalent to
PATH="$PATH:/home/user/bin"
export PATH
