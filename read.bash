#/bin/bash
read -n 2 var #read 2 characters and store to var

read -s password #don't output password

read -p "Enter input:" var #with prompt

read -t 2 var #with 2 seconds timeout

read -d ":" var #delimiter_char :
