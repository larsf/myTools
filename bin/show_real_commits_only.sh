#!/bin/bash

#
# Takes a file of hashesh and filters out the merges
# Stops when the sha give is found
#

# $1 is the file with the git shas'
# $2 is the stop sha


if [ $# -ne 2 ] ; then
    echo "USAGE: $0: <git sha file> <stop sha>"
    exit 1
fi

if ! [ -d .git ] ; then 
    echo "Not it a git repo ..."
fi

myfile=$1
stopsha=$2

for s in `cat $myfile` ; do 
    if [ "$s" = "$stopsha" ] ; then
	exit 0
    fi
    # this git show command doesn't just show parents ....
    parents=`git show --summary --format="%P" $s | head -n1`
    if [ -z "$parents" ] ; then
	echo "no parents - exiting "
        exit 2
    fi
    p2=`echo $parents | awk '{print $2}'`
    if [ -z "$p2" ] ; then
        echo $s
    fi
done

