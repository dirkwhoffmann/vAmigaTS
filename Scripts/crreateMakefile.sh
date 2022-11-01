#!/bin/bash

for dir in "$@"
do
	if [[ -d $dir ]]; then
		echo "Creating Makefile in $dir"
		cd $dir
		rm Makefile 
		ln -s ../../../Scripts/Makefile3 Makefile
		cd - &> /dev/null
	fi
done

