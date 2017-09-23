#!/bin/bash
#set -x

currentDir=$(dirname $0)
resultDir="$currentDir/resultDir"
findList="$currentDir/find.lst"
catList="$currentDir/cat.lst"
lsList="$currentDir/ls.lst"

function isBlankOrComment {
	msg="$1"
	if  echo "$msg" | egrep '^ *#' > /dev/null 2>&1; then
		return 0
	elif echo "$msg" | egrep '^ *$' > /dev/null 2>&1; then
		return 0
	fi
	return 1
}

function getFindListFile {
	for file in $(cat $findList); do
		isBlankOrComment $file && continue 
		local resFile=find_$(echo $file|sed -e 's/^\///' -e 's/\//_/g')

		if [[ -e $file ]]; then
			sudo find $file -exec ls -ld {} \; | sort -k 10 > $resultDir/$resFile
		else
			echo "-- not such file or directory --" > $resultDir/$resFile
		fi
	done
}

function getCatListFile {
	for file in $(cat $catList); do
		isBlankOrComment $file && continue 
		local resFile=cat_$(echo $file|sed -e 's/^\///' -e 's/\//_/g')

		if [[ -e $file ]]; then
			sudo cat $file > $resultDir/$resFile
		else
			echo "-- not such file or directory --" > $resultDir/$resFile
		fi
	done
}

function getLsListFile {
	for file in $(cat $lsList); do
		isBlankOrComment $file && continue 
		local resFile=ls_$(echo $file|sed -e 's/^\///' -e 's/\//_/g')

		if [[ -e $file ]]; then
			sudo ls -ld $file > $resultDir/$resFile
		else
			echo "-- not such file or directory --" > $resultDir/$resFile
		fi
	done
}

function getKernelInfo {
	uname -a > $resultDir/cmd_uname_a
	sudo sysctl -a > $resultDir/cmd_sysctl_a
}

function getServiceStatus {
	sudo chkconfig --list > $resultDir/cmd_chkconfig_list
}

function getMountInfo {
	mount > $resultDir/cmd_mount
}

function getNetworkInfo {
	ifconfig -a > $resultDir/cmd_ifconfig_a
	netstat -nr > $resultDir/cmd_netstat_nr
}

function main {
	if [[ ! -d $resultDir ]];then
		mkdir -m 755 $resultDir
	else
		rm -rf $resultDir/*
	fi

	ORG_IFS=$IFS
	IFS=$'\n'
	if [[ -f $findList ]];then
		getFindListFile
	fi

	if [[ -f $catList ]];then
		getCatListFile
	fi

	if [[ -f $lsList ]];then
		getLsListFile
	fi
	IFS=$ORG_IFS

	getKernelInfo
	getServiceStatus
	getMountInfo
	getNetworkInfo

	grep "not such file or directory" $resultDir/*
}
main