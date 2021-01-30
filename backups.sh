#!/usr/bin/env bash

user="${1}"

basePath="/home/bu/${user}"

action="${2}"

mkdir -p ${basePath}

maxUsePerUser=1000000000000

function checkMonth ()
{
        now=$(date +"%Y-%m")
        last=$(<checkMonth.txt)
        if [[ ${now} != ${last} ]]
        then
                # New Month
                mkdir -p "${basePath}/current/"
                rm -Rf "${basePath}/current/"*
                echo "${now}" > "checkMonth.txt"
        fi
}



function makeHardlink ()
{
	echo "Making hardlink copy"
        # Make hardlink copy
        now=$(date +"%Y-%m-%d_%H-%M")
        mkdir -p "${basePath}/old/${now}"
        cp -al "${basePath}/current"* "${basePath}/old/${now}"
}



function checkFree ()
{
        # Check if old files need to be deleted
        freeSpace=$( df -P | grep "${basePath}" | awk '{print $4}' )
        curUse=$( cd "${basePath}/current" | du -s | awk '{print $1}' )
	freeSpace=$(( maxUsePerUser - curUse ))
        estUse=$(( curUse * 2 ))

        echo "Freespace:${freeSpace} - Current Use:${curUse} - Estimated next:${estUse}"

        while [[ ${freeSpace} -le ${estUse} ]]
        do
                echo "Not enough space... removing old backups..."
                IFS= read -r -d $'\0' line < <(find "${basePath}/old" -type d -maxdepth 1 -printf '%T@ %p\0' 2>/dev/null | sort -z -n)
                oldDir="${line#* }"
                rm -Rf "${oldDir}"
                freeSpace=$( df -P | grep "${basePath}" | awk '{print $4}' )
                echo "${freeSpace} - ${curUse} - ${estUse}"
        done
}



case ${action} in

        newMonth)
                        checkMonth
                        ;;
        hardLink)
                        makeHardlink
                        checkFree
                        ;;
esac
