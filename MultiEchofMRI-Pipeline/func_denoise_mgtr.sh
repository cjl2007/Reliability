#!/bin/bash
# CJL; (cjl2007@med.cornell.edu)

Subject=$1
StudyFolder=$2
Subdir="$StudyFolder"/"$Subject"
RESOURCES=$3

# fresh workspace dir.
rm -rf "$Subdir"/workspace/ > /dev/null 2>&1 
mkdir "$Subdir"/workspace/ > /dev/null 2>&1 

# count the number of sessions
sessions=("$Subdir"/func/rest/session_*)
sessions=$(seq 1 1 "${#sessions[@]}")

# sweep through sessions;
for s in $sessions ; do

	# count number of runs for this session;
	runs=("$Subdir"/func/rest/session_"$s"/run_*)
	runs=$(seq 1 1 "${#runs[@]}" )

	for r in $runs ; do

		# create temporary mgtr.m 
		cp -rf "$RESOURCES"/mgtr.m \
		"$Subdir"/workspace/temp.m

		# define some Matlab variables
		echo input=["'$Subdir/func/rest/session_$s/run_$r/Rest_OCME+MEICA.dtseries.nii'"] | cat - "$Subdir"/workspace/temp.m > temp && mv temp "$Subdir"/workspace/temp.m
		echo Subdir=["'$Subdir'"]  | cat - "$Subdir"/workspace/temp.m >> temp && mv temp "$Subdir"/workspace/temp.m
		echo output=["'$Subdir/func/rest/session_$s/run_$r/Rest_OCME+MEICA+MGTR.dtseries.nii'"] | cat - "$Subdir"/workspace/temp.m >> temp && mv temp "$Subdir"/workspace/temp.m
		echo "addpath(genpath('${RESOURCES}'))" | cat - "$Subdir"/workspace/temp.m >> temp && mv temp "$Subdir"/workspace/temp.m

		cd "$Subdir"/workspace/ # perform mgtr using Matlab
		matlab -nodesktop -nosplash -r "temp; exit" > /dev/null 2>&1	 
		rm "$Subdir"/workspace/temp.m # 

	done
	
done

# delete workspace dir.
rm -rf "$Subdir"/workspace/ \
> /dev/null 2>&1 