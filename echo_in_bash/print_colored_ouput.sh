#!/bin/sh
#Color codes are used to represent each color. For example, reset=0, black=30, red=31, green=32, yellow=33, blue=34, magenta=35, cyan=36, and white=37.
#In order to print colored text, enter the following:
echo -e "\e[1;31m This is red text \e[0m"

#Here \e[1;31 is the escape string that sets the color to red and \e[0m resets the color back.
#Replace 31 with the required color code.
#For a colored background, reset = 0, black = 40, red = 41, green = 42, yellow = 43, blue = 44, magenta = 45, cyan = 46, and white=47, are the color code that are commonly used.
#In order to print a colored background, enter the following:
echo -e "\e[1;42m Green Background \e[0m"]]]]"
