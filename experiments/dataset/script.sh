#!/bin/bash
#crop 800 1712 -800 -1712 img32.jpg img32.png
#crop 800 1712 -800 -1712 img31.jpg img31.png

if [ -z "$NSCALES" ]; then
	NSCALES=0
fi

ref=img31.png
im=img32.png

bc=hsym
typeinterp=bicubic

# parameters for the matching
M_MATCH=290
M_RANGE=290

# parameters for ransac
RANSAC_N=10000
RANSAC_E=0.5
RANSAC_M=4

# ic parameter
ROBUST=3

# sift
out=sift.tiff
diff=sift_diff.tiff
w=`identify -format %w $ref`
h=`identify -format %h $ref`
PAIRS0i=file.pairs
SIFT1=ref.sift
rm -f $SIFT1
SIFT2=transformed.sift
rm -f $SIFT2
HOMO=sift.hom
MASK=mask.txt
INLIERS=inliers.txt
unisift2.sh ives $ref > $SIFT1
unisift2.sh ives $im > $SIFT2
siftu pairr $M_MATCH $SIFT1 $SIFT2 $M_RANGE $M_RANGE $PAIRS0i
ransac2 hom $RANSAC_N $RANSAC_E $RANSAC_M /dev/null $HOMO $MASK $INLIERS /dev/null "$w $h" 1 < $PAIRS0i

convert_homography "`cat $HOMO`" $HOMO
EDGEPADDING=0 generate_output $ref $im $HOMO
mv output_estimated.tiff $out
mv diff_image_rmse.tiff $diff

#ic standard
out=ic_standard.tiff
diff=ic_standard_diff.tiff
HOMO=ic_standard.hom
EDGEPADDING=0 NANIFOUTSIDE=0 ROBUST_GRADIENT=0 GRAYMETHOD=0 inverse_compositional_algorithm $ref $im -f $HOMO -r $ROBUST -n $NSCALES -v
EDGEPADDING=0 generate_output $ref $im $HOMO
mv output_estimated.tiff $out
mv diff_image_rmse.tiff $diff

#ic optimized
first=0
out=ic_optimized.tiff
diff=ic_optimized_diff.tiff
HOMO=ic_optimized.hom
EDGEPADDING=5 NANIFOUTSIDE=1 ROBUST_GRADIENT=3 GRAYMETHOD=1 inverse_compositional_algorithm $ref $im -f $HOMO -r $ROBUST -n $NSCALES -s $first -v
EDGEPADDING=0 generate_output $ref $im $HOMO
mv output_estimated.tiff $out
mv diff_image_rmse.tiff $diff

echo "Standard vs optimized"
EDGEPADDING=0 generate_output $ref $im ic_standard.hom ic_optimized.hom
mv epe.tiff epe_ic_vs_mic.tiff
echo "Sift vs optimized"
EDGEPADDING=0 generate_output $ref $im sift.hom ic_optimized.hom
mv epe.tiff epe_sift_vs_mic.tiff
echo "Sift vs standard"
EDGEPADDING=0 generate_output $ref $im sift.hom ic_standard.hom
mv epe.tiff epe_sift_vs_standard.tiff
