#!/bin/bash

function node-up()
{
    ssh -t $1 'source /etc/profile; source ~/node-mgmt.sh; node-up'
}

function node-down()
{
    ssh -t $1 'source /etc/profile; source ~/node-mgmt.sh; node-down'
}

