#!/bin/bash
#
# $1 is the branch you want to find the parent branch point off
# $2 is the parent branch

if [ $# -ne 2 ]; then 
    echo "Usage <branch-name> <parent-name>"
    exit 1
fi

diff -u <(git rev-list --first-parent $1) \
             <(git rev-list --first-parent $2) | \
     sed -ne 's/^ //p' | head -1
