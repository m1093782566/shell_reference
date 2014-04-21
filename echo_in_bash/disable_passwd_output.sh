echo -e "Enter password: "
stty -echo #disable output to terminal
read password
stty echo #enable
echo #new line
echo "Password readed." #done
