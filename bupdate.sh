#!/bin/bash

if [ ${EUID} -ne 0 ]
then
	exit 1
fi

yum update 1>/dev/null 2>>/root/logs/bupdate.log
