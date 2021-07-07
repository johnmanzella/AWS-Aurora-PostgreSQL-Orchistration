#!/bin/bash

LOG="/tmp/awspy.log"

echo "Snapshot Sync ------------------------------------ Started ${DT}"  >> ${LOG}


#
# Snapshot Name ...
#
DT=`date '+%Y-%m-%d-%H-%M-%S'`
if [[ "${SNAP_NAME}" == "" ]]
then
   SNAP="delphix-${DT}"
else
   SNAP=${SNAP_NAME}
fi
echo "Snapshot Name: ${SNAP_NAME}" >> ${LOG}
echo "Is Cluster Database: ${CLUSTER}" >> ${LOG}

#
# Create Snapshot ...
# 
if [[ "${CLUSTER}" == "True" ]]
then
   echo "aws rds create-db-cluster-snapshot --db-cluster-identifier ${SNAP_DB} --db-cluster-snapshot-identifier ${SNAP}" >> ${LOG}
   STATUS=`aws rds create-db-cluster-snapshot --db-cluster-identifier ${SNAP_DB} --db-cluster-snapshot-identifier ${SNAP}`
else
   echo "aws rds create-db-snapshot --db-cluster-identifier ${SNAP_DB} --db-cluster-snapshot-identifier ${SNAP}" >> ${LOG}
   STATUS=`aws rds create-db-snapshot --db-cluster-identifier ${SNAP_DB} --db-cluster-snapshot-identifier ${SNAP}`
fi
echo "${STATUS}" >> ${LOG}


#
# List Created Snapshot ...
#
echo "Snapshot Created: " >> ${LOG}
if [[ "${CLUSTER}" == "True" ]]
then
   echo "aws rds describe-db-cluster-snapshots --db-cluster-identifier ${SNAP_DB} --db-cluster-snapshot-identifier ${SNAP}" >> ${LOG}
   STATUS=`aws rds describe-db-cluster-snapshots --db-cluster-identifier ${SNAP_DB} --db-cluster-snapshot-identifier ${SNAP}`
else
   echo "aws rds describe-db-cluster-snapshots --db-cluster-identifier ${SNAP_DB} --db-cluster-snapshot-identifier ${SNAP}" >> ${LOG}
   STATUS=`aws rds describe-db-cluster-snapshots --db-cluster-identifier ${SNAP_DB} --db-cluster-snapshot-identifier ${SNAP}`
fi
echo "${STATUS}" >> ${LOG}

SNPSTATUS=`echo "${STATUS}" | $DLPX_BIN_JQ -r ".DBClusterSnapshots[0].Status"`
echo "Snapshot Status: ${SNPSTATUS}" >> ${LOG}
# Loop through while snapshot Status=creating  to  Status=available ...
#
# add loop code ...
DELAYTIMESEC=20
while [[ "${SNPSTATUS}" == "creating" ]];
do
   sleep ${DELAYTIMESEC}
   if [[ "${CLUSTER}" == "True" ]]
   then
      echo "aws rds describe-db-cluster-snapshots --db-cluster-identifier ${SNAP_DB} --db-cluster-snapshot-identifier ${SNAP}" >> ${LOG}
      STATUS=`aws rds describe-db-cluster-snapshots --db-cluster-identifier ${SNAP_DB} --db-cluster-snapshot-identifier ${SNAP}`
   else
      echo "aws rds describe-db-cluster-snapshots --db-cluster-identifier ${SNAP_DB} --db-cluster-snapshot-identifier ${SNAP}" >> ${LOG}
      STATUS=`aws rds describe-db-cluster-snapshots --db-cluster-identifier ${SNAP_DB} --db-cluster-snapshot-identifier ${SNAP}`
   fi
   echo "${STATUS}" >> ${LOG}
   SNPSTATUS=`echo "${STATUS}" | $DLPX_BIN_JQ -r ".DBClusterSnapshots[0].Status"`
   echo "Current status as of" $(date) ": ${SNPSTATUS}"  >> ${LOG}
done


#########################################################
##  Producing final status ...

if [[ "${SNPSTATUS}" != "available" ]]
then
   echo "Error: Snapshot is NOT available, please check ${SNAP}" >> ${LOG}
   # exit 1
else
   echo "Snapshot: ${SNPSTATUS} Completed ..." >> ${LOG}
fi

#echo "Snapshot ${SNAP} Status ... " >> ${LOG}

#STATUS=`aws rds describe-db-cluster-snapshots --db-cluster-identifier ${SNAP_DB} | jq ".DBClusterSnapshots[] | select (.DBSnapshotIdentifier==\"${SNAP}\") | .Status"`
#echo "Status: ${STATUS}" >> ${LOG}

##env | sort >> ${LOG}
env >> ${LOG}
echo "Snapshot Sync ------------------------------------ Ended"  >> ${LOG}
exit

