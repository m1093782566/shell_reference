#!/bin/bash
#let command can be used to perform basic operations directly
no1=4
no2=5
let result=no1+no2

let no1++
let no1--

let no2+=2

result=$[ no1 + no2 ]

result=$(( no1 + 50 ))

result=`expr 3 + 4`
result=$(expr $no1 + 5)
#All of the above methods do not support floating point numbers, and operate on integers only.
#bc the precision calculator is an advanced utility for mathematical operations.
echo "4 * 0.56" | bc
#2.24

no=54;
result=`echo "$no * 1.5" | bc`
echo $result
#81.0
