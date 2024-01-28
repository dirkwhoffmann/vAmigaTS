#!/bin/bash

# This is a personal script which I use for creating .ini files. 
# Dirk W. Hoffmann, 2022 - 2024
#
# Usage: createini <list of test directories>

function createScript () {

	NAME=$(basename $1)_$2
	FILE=${NAME}.ini
	ADF=/tmp/${NAME}.adf

	echo "# Regression testing script for vAmiga" > $FILE
	echo "# Dirk W. Hoffmann, $(date +'%Y')" >> $FILE
	echo "" >> $FILE
	echo "# Setup the test environment" >> $FILE
	if [[ "$2" == "OCS" ]]; then
		echo "regression setup A500_OCS_1MB /tmp/kick13.rom" >> $FILE
	elif [[ "$2" == "ECS" ]]; then
		echo "regression setup A500_ECS_1MB /tmp/kick13.rom" >> $FILE
	elif [[ "$2" == "PLUS" ]]; then
		echo "regression setup A500_PLUS_1MB /tmp/kick13.rom" >> $FILE
	elif [[ "$2" == "68010" ]]; then
		echo "regression setup A500_ECS_1MB /tmp/kick13.rom" >> $FILE
		echo "cpu set revision $2" >> $FILE
	fi
	echo "" >> $FILE
	echo "# Run the test" >> $FILE
	echo "regression run $ADF" >> $FILE
	echo "wait 9 seconds" >> $FILE
	echo "" >> $FILE
	echo "# Exit with a screenshot" >> $FILE
	echo "screenshot save $NAME" >> $FILE
}

for dir in "$@"
do
	if [[ -d $dir ]]; then
		echo "Creating scripts for $dir"
		cd $dir
		createScript $dir ECS
		createScript $dir OCS
		# createScript $dir PLUS
		cd - &> /dev/null
	fi
done

