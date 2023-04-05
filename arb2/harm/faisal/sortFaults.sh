#!/bin/bash 
if [ -z "$1" ]
  then
    echo "No input file"
    exit 1
fi

if [ -z "$2" ]
then
    max="64"
else
    max="$2"
fi

if [ -z "$3" ]
then
    cut="64"
else
    cut="$3"
fi

count=1

while grep -m1 "_inj[0-9]*([][A-Za-z0-9_{}' ,:\*\+\-]*,%L,%R)" $1  > /dev/null;
do

str=$(grep -m1 "_inj[0-9]*([][A-Za-z0-9_{}' ,:\*\+\-]*,%L,%R)" $1)


echo "${size}"
size="${str%%,%L,%R)*}"
size="${size##*_inj}"
size="${size%%(*}"
echo "size: ${size}"

if [ $size -gt $max ]; then
    size=$cut
fi

#echo "$size"

l=$count
let "r=$count + $size - 1"

sed -i "0,/%L/{s/%L/$l/}" $1
sed -i "0,/%R/{s/%R/$r/}" $1

echo "left-->$l"
echo "rigth-->$r"

let "count=$r + 1"

done
