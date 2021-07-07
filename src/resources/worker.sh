#!/bin/bash

LOG="/tmp/awspy.log"
DT=`date '+%Y-%m-%d-%H-%M-%S'`

echo "Worker ------------------------------------ Started ${DT}"  >> ${LOG}

echo "Todo: " >> ${LOG}
echo "1. manage snapshots" >> ${LOG}
echo "2. _______________ " >> ${LOG}

env | sort >> ${LOG}
echo "Worker ------------------------------------ Ended"  >> ${LOG}
echo "Done"
exit

