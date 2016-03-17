#!/bin/bash
#
# $1 is the file with git hashes that needs reversed and to 7 char eqivalent
#

typeset -a hashes
i=0
for h in $( cat $1 | awk '{print substr($0,1,7)}' ) ; do
   hashes[$i]=$h
   let i=i+1
done

let i=i-1

while [ $i -ge 0 ] ; do
   echo ${hashes[$i]}
   let i=i-1
done
