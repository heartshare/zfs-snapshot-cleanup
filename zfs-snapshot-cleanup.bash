#!/bin/bash

for arg in "$@"
do
case $arg in
    --dataset=*)
    DATASET="${arg#*=}"
    shift
    ;;
    --keepdays=*)
    KEEPDAYS="${arg#*=}"
    shift
    ;;
    --include=*)
    INCLUDE="${arg#*=}"
    shift
    ;;
    --exclude=*)
    EXCLUDE="${arg#*=}"
    shift
    ;;
    --force)
    FORCE="TRUE"
    shift
    ;;
    *)
    ;;
esac
done

if [[ $DATASET == '' ]]
then
    echo "--dataset parameter must be set"
        exit 1
fi

if [[ ! $KEEPDAYS =~ ^[0-9]+$ ]]
then
    echo "--keepdays parameter must be an integer"
        exit 1
fi

SKIPFILESYSTEMREGEX='.system|/sys/swap'
SNAPSHOTSTODELETE=()
TODATE=$(date -n -v -${KEEPDAYS}d +"%s")

FILESYSTEMS=$(zfs list -H -t filesystem,volume -o name $DATASET | egrep -v $SKIPFILESYSTEMREGEX | sort)

for FILESYSTEM in $FILESYSTEMS
do
    if [[ -z "$INCLUDE" && -z "$EXCLUDE" ]]
    then
        SNAPSHOTS=$(zfs list -H -r -t snapshot -o name -S creation $FILESYSTEM)
    elif [[ -z "$INCLUDE" && ! -z "$EXCLUDE" ]]
    then
        SNAPSHOTS=$(zfs list -H -r -t snapshot -o name -S creation $FILESYSTEM | egrep -v "$EXCLUDE")
    elif [[ ! -z "$INCLUDE" && -z "$EXCLUDE" ]]
    then
        SNAPSHOTS=$(zfs list -H -r -t snapshot -o name -S creation $FILESYSTEM | egrep "$INCLUDE")
    elif [[ ! -z "$INCLUDE" && ! -z "$EXCLUDE" ]]
    then
        SNAPSHOTS=$(zfs list -H -r -t snapshot -o name -S creation $FILESYSTEM | egrep "$INCLUDE" | egrep -v "$EXCLUDE")
    fi
    for SNAPSHOT in $SNAPSHOTS
    do
        SNAPSHOTDATE=$(date -j -f "%a %b %d %H:%M %Y" "$(zfs list -H -r -t snapshot -o creation $SNAPSHOT)" +"%s")
        if ((SNAPSHOTDATE <= $TODATE))
        then
            SNAPSHOTSTODELETE+=( $( echo $SNAPSHOT ) )
        fi
    done
done

if [[ ! $SNAPSHOTSTODELETE == '' && ! -z $SNAPSHOTSTODELETE ]]
then
    if [[ $FORCE == 'TRUE' ]]
    then
        for SNAPSHOT in ${SNAPSHOTSTODELETE[@]}
        do
            zfs destroy $SNAPSHOT
        done
    else
        for SNAPSHOT in ${SNAPSHOTSTODELETE[@]}
        do
            echo "$SNAPSHOT"
        done
        echo
        read -p "Are you sure you want to destroy the above ($(echo "${SNAPSHOTSTODELETE[@]}" | wc -w | tr -d '[:space:]')) snapshots? " -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]
        then
            for SNAPSHOT in ${SNAPSHOTSTODELETE[@]}
            do
                echo "zfs destroy $SNAPSHOT"
                zfs destroy $SNAPSHOT
            done
        fi
    fi
fi
