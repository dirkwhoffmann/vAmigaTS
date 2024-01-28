#!/bin/bash

# Searches for directories with missing test scripts (missing .ini files)
# Dirk W. Hoffmann, 2022
#
# Usage: missingini <list of test directories>

for dir in "$@"
do
	if [[ -d $dir ]]; then
		if ! find $dir -maxdepth 1  -name '*.ini' | grep . >& /dev/null; then
			echo $dir
		fi
	fi
done
