echo -n Count:
tput sc #store the position of cursor

count=0;
while true;
do
    if [ $count -lt 40 ];
    then
        let count++;
        sleep 1;
        tput rc #restore the position of cursor
        tput ed
        echo -n $count;
    else exit 0;
    fi
done
