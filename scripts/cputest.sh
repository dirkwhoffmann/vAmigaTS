#!/bin/bash

# Creates two script file for a standard CPU test
# Dirk W. Hoffmann, 2022
#
# Usage: cputest <list of test directories>

function createScript () {

	NAME=$(basename $1)_$2
	FILE=${NAME}.ini
	ADF=/tmp/${NAME}.adf

	echo "# Regression testing script for vAmiga" > $FILE
	echo "# Dirk W. Hoffmann, $(date +'%Y')" >> $FILE
	echo "" >> $FILE
	echo "# Setup the test environment" >> $FILE
	echo "regression setup A500_ECS_1MB /tmp/kick13.rom" >> $FILE
	if [[ "$2" != "68000" ]]; then
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
		createScript $dir 68000
		createScript $dir 68010
		cd - &> /dev/null
	fi
done

