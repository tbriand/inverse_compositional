#!/bin/bash

# fixed parameters
# NUMBER=1001
# L=20
# ref=ref.png
# TIMEFORMAT="%U"
# FIRST_SCALE=0
# ROBUST_GRADIENT=0
# EDGEPADDING=5
# NANIFOUTSIDE=1
# SAVE=1
# SCALES=5
# PRECISION=0.001
# NTHREADS=1
# 
# prog=../../../recalage_ic.sh
# 
# # for the interpolation
# interp=bicubic
# boundary=hsym
# base_out=burst
# transform=8 #homography
# 
# # comparison fields
# centered=0
# opt=1 # to determine if comparison has h1-h2 (1) or h2^-1 o h1 - id (0)
# 
# # image parameters
# INPAT=../${base_out}_%i.tiff
# INPAT_NOISY=noisy_%i.tiff
# TRUE_REGPAT=../${base_out}_%i.hom
# REF=`printf $INPAT_NOISY 1`

# create output directory
dir=color_evaluation
# mkdir $dir
cd $dir

# loop over the images
# for image in "Beanbags" "DogDance" "Grove3" "MiniCooper" "Urban2" "Venus" "Dimetrodon" "Grove2" "Hydrangea" "RubberWhale" "Urban3" "Walking"; do
#     mkdir $image
#     cd $image
#     cp ../../other-data/$image/frame10.png $ref
#     
#     # size of the image
#     w=`imprintf %w $ref`
#     h=`imprintf %h $ref`
#     
#     # create burst
#     echo "Creating burst for the image $image"
#     create_burst $ref $base_out $NUMBER $interp $boundary $L $transform   
#     
#     # invert the homography
#     for i in `seq 2 $NUMBER`; do
#             REGi=${base_out}_$i.hom
#             invert_homography_ica "`cat $REGi`" $REGi
#     done
#     
#     # loop over the noise level
#     for noise in 0 3 5 10 20 30 50; do
#         echo "Noise level $noise"
#         dir=noise$noise
#         mkdir $dir
#         cd $dir
#         for i in `seq 1 $NUMBER`; do
#                 INi=`printf $INPAT $i`
#                 OUTi=`printf $INPAT_NOISY $i`
#                 add_noise $noise $INi $OUTi
#         done
#         
#         # L2 or lorentzian function
#         for ROBUST in 0 3; do
#             # use graymethod or not
#             for GRAYMETHOD in 0 1; do
#                 # estimation of the transformation for all images
#                 $prog $NUMBER $INPAT_NOISY $TRUE_REGPAT $REF $GRAYMETHOD $SAVE $FIRST_SCALE $EDGEPADDING $ROBUST_GRADIENT $ROBUST $NANIFOUTSIDE $SCALES $PRECISION $transform $NTHREADS $w $h $opt
#                 basefile=graymethod${GRAYMETHOD}_save${SAVE}_scale${FIRST_SCALE}_edge${EDGEPADDING}_nan${NANIFOUTSIDE}_gradient${ROBUST_GRADIENT}_robust${ROBUST}
#                 time_ica=time_ica_${basefile}.txt
#                 rmse_ica=rmse_ica_${basefile}.txt
#                 mean_and_std $time_ica 0 >> ../../time_robust${ROBUST}_graymethod${GRAYMETHOD}_noise${noise}.txt
#                 mean_and_std $rmse_ica 0 >> ../../rmse_robust${ROBUST}_graymethod${GRAYMETHOD}_noise${noise}.txt
#             done
#         done
#         
#         #clean noisy images
#         out=""
#         for i in `seq 1 $NUMBER`; do
#                 OUTi=`printf $INPAT_NOISY $i`
#                 out="$out $OUTi"
#         done
#         rm $out
#         
#         cd ..
#     done
#     
#     rm ${base_out}_*
#     
#     cd ..
# done


echo "\\begin{table}"
echo "\\begin{center}"
echo "\\begin{tabular}{l|l|l|l|l|l}"
echo "\\multicolumn{2}{l}{} &\\multicolumn{2}{|c|}{L2} & \\multicolumn{2}{c}{Lorentzian} \\\\"
echo "\\hline"
echo "\\multicolumn{2}{l|}{} & & Grayscale & & Grayscale\\\\"
for noise in 0 3 5 10 20 30 50; do
        echo "\\hline"

        #RMSE
        line2echo="\\multirow{2}{0.1\\linewidth}{$\sigma = $noise$} & EPE"
        for ROBUST in 0 3; do
                for GRAYMETHOD in 0 1; do
                    basefile=robust${ROBUST}_graymethod${GRAYMETHOD}_noise${noise}
                    # field comparison
                    rmse_ica=rmse_${basefile}.txt
                    line2echo="$line2echo & `mean_and_std $rmse_ica 0`"
                done
        done
        line2echo="$line2echo \\\\"
        echo "$line2echo"

        #TIME
        line2echo=" & Time"
        for ROBUST in 0 3; do
                for GRAYMETHOD in 0 1; do
                    basefile=robust${ROBUST}_graymethod${GRAYMETHOD}_noise${noise}
                    # field comparison
                    time_ica=time_${basefile}.txt
                    vartime=`mean_and_std $time_ica 0`
                    line2echo="$line2echo & `echo \"$vartime\" | cut -f1 -d\.`"
                done
        done
        if [ ! "$noise" -eq "50" ]; then
            line2echo="$line2echo \\\\"
        fi
        echo "$line2echo"
done
echo "\\end{tabular}"
echo "\\caption{Influence of the color handling}"
echo "\\label{fig::ic_color_handling}"
echo "\\end{center}"
echo "\\end{table}"

cd ..
