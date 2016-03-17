#!/bin/bash

#
# 
export HOME=/root/lars

set -o vi


#
# Ssh-agent stuff
# 
ME=`whoami`
SSH_AGENT_PID=`ps -elfwu $ME | fgrep ssh-agent | fgrep -v grep |awk '{print $4}'`
if [ -z "$SSH_AGENT_PID" ]; then
    eval $(ssh-agent -s) > /dev/null
else
    SSH_AUTH_SOCK=`lsof -p $SSH_AGENT_PID | grep '/tmp/ssh-'| awk '{print $9}'`
fi
export SSH_AUTH_SOCK
export SSH_AGENT_PID


ssh-add -l > /dev/null                        # check for keys
if [ $? -ne 0 ] ; then
    ssh-add ~/.ssh/github_rsa
    ssh-add ~/.ssh/id_rsa
fi

#
# setup ssh-agent
#


# set environment variables if user's agent already exists
#[ -z "$SSH_AUTH_SOCK" ] && SSH_AUTH_SOCK=$(ls -l /tmp/ssh-*/agent.* 2> /dev/null | grep $(whoami) | awk '{print $9}')
#[ -z "$SSH_AGENT_PID" -a -z `echo $SSH_AUTH_SOCK | cut -d. -f2` ] && SSH_AGENT_PID=$((`echo $SSH_AUTH_SOCK | cut -d. -f2` + 1))
#[ -n "$SSH_AUTH_SOCK" ] && export SSH_AUTH_SOCK
#[ -n "$SSH_AGENT_PID" ] && export SSH_AGENT_PID

# start agent if necessary
#if [ -z $SSH_AGENT_PID ] && [ -z $SSH_TTY ]; then  # if no agent & not in ssh
#  eval $(ssh-agent -s) > /dev/null
#fi

#
# test using
# ssh -T git@github.com
