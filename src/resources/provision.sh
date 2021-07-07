#!/bin/bash

LOG="/tmp/awspy.log"
###env >> ${LOG}
HOST="localhost"
PORT="9200"
#DT=`date '+%Y%m%d%H%M%S'`
DT=`date '+%Y-%m-%d-%H-%M-%S'`

echo "Provision ------------------------------------ Started ${DT}"  >> ${LOG}

if [[ "${VDB_NAME}" == "" ]]
then
   VDB_NAME="my_restore"
fi

#
if [[ "${SNAP}" == "" ]] 
then 
   SNAP="delphix-delphixdb2-2020-08-24-23-16-16" 		
   #SNAP="delphix-2019-09-20-00-58-49"
fi

if [[ "${SUBNET_GROUP}" == "" ]]
then
   DB_CLUSTER="aws rds restore-db-cluster-from-snapshot --db-cluster-identifier ${VDB_NAME} --snapshot-identifier ${SNAP}  --engine aurora-postgresql"
   DB_CREATE="aws rds create-db-instance --db-instance-identifier ${VDB_NAME} --db-instance-class ${DB_INSTANCE}  --engine aurora-postgresql --db-cluster-identifier ${VDB_NAME}"
else
   DB_CREATE="aws rds create-db-instance --db-instance-identifier ${VDB_NAME} --db-instance-class ${DB_INSTANCE}  --engine aurora-postgresql --db-subnet-group-name ${SUBNET_GROUP} --db-cluster-identifier ${VDB_NAME}"
   DB_CLUSTER="aws rds restore-db-cluster-from-snapshot --db-cluster-identifier ${VDB_NAME} --snapshot-identifier ${SNAP}  --engine aurora-postgresql --db-subnet-group-name ${SUBNET_GROUP}"
fi

#
# Verify Snapshot is Available ...
#
SNAP_DB=`echo "${SNAP}" | awk -F "-" {'print $2'}`
echo "Snapshot DB: ${SNAP_DB}" >> ${LOG}
echo "Verify Snapshot is Available: " >> ${LOG}
#if [[ "${CLUSTER}" == "True" ]]
#then
#   ###delphix-mypsql-2020-03-30-01-21-51
#   SNAP_DB=`echo "${SNAP}" | awk -F "-" {'print $2'}`
#   echo "aws rds describe-db-cluster-snapshots --db-cluster-identifier ${SNAP_DB} --db-cluster-snapshot-identifier ${SNAP}" >> ${LOG}
#   STATUS=`aws rds describe-db-cluster-snapshots --db-cluster-identifier ${SNAP_DB} --db-cluster-snapshot-identifier ${SNAP}`
#else
   echo "aws rds describe-db-snapshots --db-instance-identifier ${SNAP_DB} --db-snapshot-identifier ${SNAP}"
   STATUS=`aws rds describe-db-snapshots --db-instance-identifier ${SNAP_DB} --db-snapshot-identifier ${SNAP}`
#   ###| jq ".DBSnapshots[] | select (.DBSnapshotIdentifier==\"${SNAP}\")"
#fi
#sleep 2
echo "${STATUS}" >> ${LOG}

###echo "${STATUS}" | jq -r  ".DBClusterSnapshots[0].Status" >> ${LOG}
AVAIL=`echo "${STATUS}" | $DLPX_BIN_JQ -r  ".DBClusterSnapshots[0].Status"`
echo "AVAIL: ${AVAIL}" >> ${LOG}

#if [[ "${AVAIL}" != "available" ]]
#then
#   echo "Error: Snapshot $SNAP for Database $SNAP_DB is not currently available please check AWS, exiting ..." >> ${LOG}
#   die "Error: Snapshot $SNAP for Database $SNAP_DB is not currently available please check AWS, exiting ..."
#fi


#
# Provision Database by restoring from snapshot ...
# 
if [[ "${CLUSTER}" == "True" ]]
then
   echo "${DB_CLUSTER}" >> ${LOG}
   #STATUS=`aws rds restore-db-cluster-from-snapshot --db-cluster-identifier ${VDB_NAME} --snapshot-identifier ${SNAP} ${OPTIONS}`
   STATUS=`eval $DB_CLUSTER`
else
   echo "aws rds restore-db-instance-from-db-snapshot --db-instance-identifier ${VDB_NAME} --db-snapshot-identifier ${SNAP}" >> ${LOG}
   STATUS=`aws rds restore-db-instance-from-db-snapshot --db-instance-identifier ${VDB_NAME} --db-snapshot-identifier ${SNAP}`
fi
echo "${STATUS}" >> ${LOG}
	
echo "Cluster Created: " >> ${LOG}
if [[ "${CLUSTER}" == "True" ]]
then
   echo "aws rds describe-db-clusters --db-cluster-identifier ${VDB_NAME}"  >> ${LOG}
   STATUS=`aws rds describe-db-clusters --db-cluster-identifier ${VDB_NAME}`
else
   echo "aws rds describe-db-clusters --db-cluster-identifier ${VDB_NAME}"  >> ${LOG}
   STATUS=`aws rds describe-db-clusters --db-cluster-identifier ${VDB_NAME}`
fi
echo "${STATUS}" >> ${LOG}

PRVSTATUS=`echo "${STATUS}" | $DLPX_BIN_JQ -r ".DBClusters[0].Status"`
echo "Cluster Status: ${PRVSTATUS}" >> ${LOG}
# Loop through while snapshot Status=creating  to  Status=available ...
#
# add loop code ...
DELAYTIMESEC=20
while [ "${PRVSTATUS}" == "creating" ] || [ "${PRVSTATUS}" == "backing-up" ];
do
   sleep ${DELAYTIMESEC}
   if [[ "${CLUSTER}" == "True" ]]
   then
       echo "aws rds describe-db-clusters --db-cluster-identifier ${VDB_NAME}"  >> ${LOG}
       STATUS=`aws rds describe-db-clusters --db-cluster-identifier ${VDB_NAME}`
   else
       echo "aws rds describe-db-clusters --db-cluster-identifier ${VDB_NAME}"  >> ${LOG}
       STATUS=`aws rds describe-db-clusters --db-cluster-identifier ${VDB_NAME}`
   fi
   echo "${STATUS}" >> ${LOG}
   PRVSTATUS=`echo "${STATUS}" | $DLPX_BIN_JQ -r ".DBClusters[0].Status"`
   sleep 20 
   PRVSTATUS=`echo "${STATUS}" | $DLPX_BIN_JQ -r ".DBClusters[0].Status"`
   echo "Current status as of" $(date) ": ${PRVSTATUS}"  >> ${LOG}
done

if [[ "${PRVSTATUS}" != "available" ]]
then
   echo "Error: Cluster  is NOT available, please check ${VDB_NAME}" >> ${LOG}
   # exit 1
else
   echo "Cluster: ${PRVSTATUS} Completed ..." >> ${LOG}
fi

#
# Create DB Instance
#
echo "Hi" >> $LOG
DatabaseSTATUS=`eval $DB_CREATE`
echo "Database Status: ${DatabaseSTATUS}" >> ${LOG}
DBSTATUS=`echo "${DatabaseSTATUS}" | $DLPX_BIN_JQ -r ".DBInstances[].DBInstanceStatus"`
echo "Current status as of" $(date) ": ${DBSTATUS}"  >> ${LOG}
#
# Checking DB Status
#
echo "Checking Database Status"  >> ${LOG}

echo "aws rds describe-db-instances --db-instance-identifier ${VDB_NAME}"  >> ${LOG}
STATUS=`aws rds describe-db-instances --db-instance-identifier ${VDB_NAME}`

DBSTATUS=`echo "${STATUS}" | $DLPX_BIN_JQ -r ".DBInstances[].DBInstanceStatus"`
echo "Database Status: ${DBSTATUS}" >> ${LOG}

DELAYTIMESEC=20
while [[ "${DBSTATUS}" == "creating" ]];
do
   sleep ${DELAYTIMESEC}
   echo "aws rds describe-db-clusters --db-cluster-identifier ${VDB_NAME}"  >> ${LOG}
   STATUS=`aws rds describe-db-instances --db-instance-identifier ${VDB_NAME}`
   echo "${STATUS}" >> ${LOG}
   DBSTATUS=`echo "${STATUS}" | $DLPX_BIN_JQ -r ".DBInstances[].DBInstanceStatus"`
   echo "Current status as of" $(date) ": ${DBSTATUS}"  >> ${LOG}
done

#########################################################
##  Producing final status ...

if [[ "${DBSTATUS}" != "available" ]]
then
   echo "Error: Database is  NOT available, please check ${VDB_NAME}" >> ${LOG}
   # exit 1
else
   echo "Cluster: ${DBSTATUS} Completed ..." >> ${LOG}
fi


env | sort >> ${LOG}
echo "Provision ------------------------------------ Ended"  >> ${LOG}
echo "Done"
exit

