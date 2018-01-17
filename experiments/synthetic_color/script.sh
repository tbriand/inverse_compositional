#!/bin/bash

ref=~/these/inverse_compositional/input/reverse/affinity1.png
base_in=synthetic

bc=hsym
typeinterp=bicubic
opt=1

n=2
L=20
create_burst $ref $base_in $n $typeinterp $bc $L

ref=${base_in}_2.tiff
im=${base_in}_1.tiff
homoGt=${base_in}_2.hom
invert_homography_ica "`cat $homoGt`" $homoGt
#convert_homography "`cat $homoGt`" $homoGt

w=`identify -format %w $ref`
h=`identify -format %h $ref`

# sift
out=sift.tiff
# parameters for the matching
M_MATCH=290
M_RANGE=20

# parameters for ransac
RANSAC_N=10000
RANSAC_E=0.5
RANSAC_M=4

PAIRS0i=file.pairs
SIFT1=ref.sift
SIFT2=transformed.sift
HOMO=sift.hom
MASK=mask.txt
INLIERS=inliers.txt
unisift2.sh ives $ref > $SIFT1
unisift2.sh ives $im > $SIFT2
siftu pairr $M_MATCH $SIFT1 $SIFT2 $M_RANGE $M_RANGE $PAIRS0i
ransac2 hom $RANSAC_N $RANSAC_E $RANSAC_M /dev/null $HOMO $MASK $INLIERS /dev/null "$w $h" 1 < $PAIRS0i

# compare_homography $w $h "`cat $HOMO`" "`cat $homoGt`" $out $opt
# echo "Sift" > rmse_field.txt
# compute rmse 0 $out >> rmse_field.txt
# interpolation homi "`cat $HOMO`" $typeinterp $bc $im interp_$out
# diff2 $ref interp_$out diff_$out

convert_homography "`cat $HOMO`" $HOMO
EDGEPADDING=0 generate_output $ref $im $HOMO $homoGt
mv diff_image_rmse.tiff diff_image_sift.tiff
mv epe.tiff epe_sift.tiff

# # ic standard
out=ic_standard.tiff
HOMO=ic_standard.hom
ROBUST=3
GRAYMETHOD=0 EDGEPADDING=0 NANIFOUTSIDE=0 ROBUST_GRADIENT=0 inverse_compositional_algorithm $ref $im -f $HOMO -r $ROBUST -v

EDGEPADDING=0 generate_output $ref $im $HOMO $homoGt
mv diff_image_rmse.tiff diff_image_ic_standard.tiff
mv epe.tiff epe_ic_standard.tiff

# compare_homography $w $h "`cat $HOMO`" "`cat $homoGt`" $out $opt
# echo "IC standard" >> rmse_field.txt
# compute rmse 0 $out >> rmse_field.txt
# interpolation homi "`cat $HOMO`" $typeinterp $bc $im interp_$out
# diff2 $ref interp_$out diff_$out

# ic optimized
# out=ic_optimized.tiff
# HOMO=ic_optimized.hom
# ROBUST=3
# EDGEPADDING=5 NANIFOUTSIDE=1 ROBUST_GRADIENT=3 inverse_compositional_algorithm $ref $im -f $HOMO -r $ROBUST -v
# 
# 
# compare_homography $w $h "`cat $HOMO`" "`cat $homoGt`" $out $opt
# echo "IC optimized" >> rmse_field.txt
# compute rmse 0 $out >> rmse_field.txt
# interpolation homi "`cat $HOMO`" $typeinterp $bc $im interp_$out
# diff2 $ref interp_$out diff_$out

# ic optimized gray
out=ic_optimized.tiff
HOMO=ic_optimized.hom
ROBUST=3
GRAYMETHOD=1 EDGEPADDING=5 NANIFOUTSIDE=1 ROBUST_GRADIENT=3 inverse_compositional_algorithm $ref $im -f $HOMO -r $ROBUST -v

EDGEPADDING=0 generate_output $ref $im $HOMO $homoGt
mv diff_image_rmse.tiff diff_image_ic_optimized.tiff
mv epe.tiff epe_ic_optimized.tiff

# compare_homography $w $h "`cat $HOMO`" "`cat $homoGt`" $out $opt
# echo "IC optimized" >> rmse_field.txt
# compute rmse 0 $out >> rmse_field.txt
# interpolation homi "`cat $HOMO`" $typeinterp $bc $im interp_$out
# diff2 $ref interp_$out diff_$out

# to save images
iion synthetic_1.tiff synthetic_1.png
iion synthetic_2.tiff synthetic_2.png
#affine0255 ic_optimized.tiff field_example.png
