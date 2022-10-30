#!/bin/bash

# Creates two script file for a standard ECS / OCS test
# Dirk W. Hoffmann, 2022
#
# Usage: ecsocstest <list of test directories>

function createScript () {

	NAME=$(basename $1)_$2
	FILE=${NAME}.ini
	ADF=/tmp/${NAME}.adf

	echo "# Regression testing script for vAmiga" > $FILE
	echo "# Dirk W. Hoffmann, $(date +'%Y')" >> $FILE
	echo "" >> $FILE
	echo "# Setup the test environment" >> $FILE
	if [[ "$2" == "ocs" ]]; then
		echo "regression setup A500_ECS_1MB /tmp/kick13.rom" >> $FILE
	else
		echo "regression setup A500_OCS_1MB /tmp/kick13.rom" >> $FILE
	fi
	echo "amiga set ntsc" >> $FILE   # REMOVE ME
	echo "" >> $FILE
	echo "# Run the test" >> $FILE
	echo "regression run $ADF" >> $FILE
	echo "wait 11 seconds" >> $FILE
	echo "" >> $FILE
	echo "# Exit with a screenshot" >> $FILE
	echo "screenshot save $NAME" >> $FILE
}

for dir in "$@"
do
	if [[ -d $dir ]]; then
		echo "Creating scripts for $dir"
		cd $dir
		createScript $dir ecs
		createScript $dir ocs
		cd - &> /dev/null
	fi
done

