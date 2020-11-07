#!/bin/bash
# CJL; (cjl2007@med.cornell.edu)

Subject=$1
StudyFolder=$2
Subdir="$StudyFolder"/"$Subject"
RESOURCES=$3
FS="$RESOURCES/FS" # dir. with FreeSurfer (FS) atlases 
FSL="$RESOURCES/FSL" # dir. with FSL (FSL) atlases 

# sweep through sessions;
for s in $sessions ; do

	# count number of runs for this session;
	runs=("$Subdir"/func/rest/session_"$s"/run_*)
	runs=$(seq 1 1 "${#runs[@]}" )

	for r in $runs ; do

		# sweep all of the denoising stages;
		for i in OCME OCME+MEICA OCME+MEICA+MGTR ; do

			# calculate temporal mean and standard deviation; demean and normalize dense time-series 
			wb_command -cifti-reduce "$Subdir"/func/rest/session_"$s"/run_"$r"/Ciftis/Rest_"$i".dtseries.nii MEAN "$Subdir"/func/rest/session_"$s"/run_"$r"/Ciftis/MEAN.dscalar.nii > /dev/null 2>&1
			wb_command -cifti-reduce "$Subdir"/func/rest/session_"$s"/run_"$r"/Ciftis/Rest_"$i".dtseries.nii STDEV "$Subdir"/func/rest/session_"$s"/run_"$r"/Ciftis/STDEV.dscalar.nii > /dev/null 2>&1
			wb_command -cifti-math '(x - mean) / stdev' "$Subdir"/func/rest/session_"$s"/run_"$r"/Ciftis/Rest_"$i".dtseries.nii -fixnan 0 -var x "$Subdir"/func/rest/session_"$s"/run_"$r"/Ciftis/Rest_"$i".dtseries.nii \
			-var mean "$Subdir"/func/rest/session_"$s"/run_"$r"/Ciftis/MEAN.dscalar.nii -select 1 1 -repeat -var stdev "$Subdir"/func/rest/session_"$s"/run_"$r"/Ciftis/STDEV.dscalar.nii -select 1 1 -repeat > /dev/null 2>&1 

			# smooth with geodesic (for surface data) and Euclidean (for volumetric data) Gaussian kernels; 
			wb_command -cifti-smoothing "$Subdir"/func/rest/session_"$s"/run_"$r"/Ciftis/Rest_"$i".dtseries.nii 2.55 2.55 COLUMN "$Subdir"/func/rest/session_"$s"/run_"$r"/Ciftis/Rest_"$i"_s2.55.dtseries.nii \
			-left-surface "$Subdir"/anat/MNINonLinear/fsaverage_LR32k/"$Subject".L.midthickness.32k_fs_LR.surf.gii -right-surface "$Subdir"/anat/MNINonLinear/fsaverage_LR32k/"$Subject".R.midthickness.32k_fs_LR.surf.gii > /dev/null 2>&1

			# remove some intermediate files
			rm "$Subdir"/func/rest/session_"$s"/run_"$r"/Ciftis/MEAN.dscalar.nii 
			rm "$Subdir"/func/rest/session_"$s"/run_"$r"/Ciftis/STDEV.dscalar.nii

		done

	done
	
done

# delete workspace dir.
rm -rf "$Subdir"/workspace/ > /dev/null 2>&1 