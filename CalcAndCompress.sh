#!/bin/bash
# SVN: $Id: CalcAndCompress.sh 617 2012-04-30 20:41:25Z rob $

EH=$1
WS=$2

INSTALL_DIR=/home/statspg1/rdonald
BDS_AREA=$INSTALL_DIR/PhDStuff/ThesisSoftware/BaseSetGenerator/output_$EH

if [ $# -eq 0 ]
then
    echo "usage: CalcAndCompress.sh <event horizon> <window size>"
    exit -1
else
    if [ $1 = "--help" ] 
    then
    	    echo "usage: CalcAndCompress.sh <event horizon> <window size>"
	    exit -1
    fi
fi

/maths/R/bin/Rscript BSG_TopLevelControl.R EH=$EH WS=$WS > BSG-TLC-$EH-$WS.log

cd $BDS_AREA
tar cvzf BDS_$EH\_$WS.tgz BDS_$EH\_$WS.csv
rm -f BDS_$EH\_$WS.csv


