#!/bin/bash

if [ "$#" -lt "5" ]; then

    echo "usage:\n\t$0 in number displacement_max_corner noise_level robust"
    echo "example toto.tiff 2 5 1 3" 
    exit 1
fi

in=$1
n=$2
L=$3
noise=$4
ROBUST=$5

base_out=burst
interp=bicubic
boundary=hsym
type=2
create_burst $in $base_out $n $interp $boundary $L $type

SCALES=5
#ROBUST=3
PRECISION=0.001
FIRST_SCALE=0
NUMBER=$n

regpat_ica=ica_%i.hom
regpat_ica_edge=ica_edge_%i.hom
transform=$type
INPAT=${base_out}_%i.tiff
INPAT_NOISY=noisy_%i.tiff
TRUE_REGPAT=${base_out}_%i.hom
for i in `seq 1 $NUMBER`; do
        INi=`printf $INPAT $i`
        OUTi=`printf $INPAT_NOISY $i`
        add_noise $noise $INi $OUTi
done

REF=`printf $INPAT_NOISY 1`
for i in `seq 2 $NUMBER`; do
        INi=`printf $INPAT_NOISY $i`
        REGi=`printf $regpat_ica $i`
        REGEDGEi=`printf $regpat_ica_edge $i`
        EDGEPADDING=0 NANIFOUTSIDE=0 inverse_compositional_algorithm $REF $INi -f $REGi -n $SCALES -r $ROBUST -e $PRECISION -t $transform -s $FIRST_SCALE
        inverse_compositional_algorithm $REF $INi -f $REGEDGEi -n $SCALES -r $ROBUST -e $PRECISION -t $transform -s $FIRST_SCALE
done

ref_number=1
ref_image=`printf $INPAT 1`

# registration using SIFT + RANSAC method
regpat=sift_%i.tiff #just used to set the name of the homography files
regpat_sift=sift_%i.hom
method=splineper #useless
boundary=hsym #useless
sr=sr
burst_registration_iteration.sh $INPAT_NOISY $regpat $ref_number $NUMBER $ref_number $method $boundary $sr 0 > /dev/null

# comparison fields
w=`imprintf %w $in`
h=`imprintf %h $in` 
opt=1 # to determine if comparison has h1-h2 (1) or h2^-1 o h1 - id (0)
field_ica=field_ica_%i.tiff
rmse_ica=rmse_ica.txt
field_ica_edge=field_ica_edge_%i.tiff
rmse_ica_edge=rmse_ica_edge.txt
field_sift=field_sift_%i.tiff
rmse_sift=rmse_sift.txt
rm -f $rmse_ica $rmse_ica_edge $rmse_sift

centered=0

for i in `seq 2 $NUMBER`; do
    echo "image $i"
    REGICAi=`printf $regpat_ica $i`
    REGICAEDGEi=`printf $regpat_ica_edge $i`
    REGSIFTi=`printf $regpat_sift $i`
    REGi=`printf $TRUE_REGPAT $i`
    # truth vs ICA
    echo "ICA"
    FIELDi=`printf $field_ica $i`
    compare_homography $w $h "`cat $REGICAi`" "`cat $REGi`" $FIELDi $opt
    compute rmse $centered $FIELDi >> $rmse_ica
    compute max $centered $FIELDi >> $rmse_ica
    echo "`compute rmse $centered $FIELDi`"
    echo "`compute max $centered $FIELDi` "
    # truth vs ICA EDGE
    echo "ICA EDGE"
    FIELDi=`printf $field_ica_edge $i`
    compare_homography $w $h "`cat $REGICAEDGEi`" "`cat $REGi`" $FIELDi $opt
    compute rmse $centered $FIELDi >> $rmse_ica_edge
    compute max $centered $FIELDi >> $rmse_ica_edge
    echo "`compute rmse $centered $FIELDi`"
    echo "`compute max $centered $FIELDi` "
    # truth vs SIFT
    echo "SIFT"
    FIELDi=`printf $field_sift $i`
    compare_homography $w $h "`cat $REGSIFTi`" "`cat $REGi`" $FIELDi $opt
    compute rmse $centered $FIELDi >> $rmse_sift
    compute max $centered $FIELDi >> $rmse_sift
    echo "`compute rmse $centered $FIELDi` "
    echo "`compute max $centered $FIELDi` "
done

outpat_ica=ica_%i.tiff
outpat_ica_edge=ica_edge_%i.tiff
outpat_ica_noisy=ica_noisy_%i.tiff
outpat_ica_edge_noisy=ica_edge_noisy_%i.tiff
outpat_sift=sift_%i.tiff
outpat_sift_noisy=sift_noisy_%i.tiff
zoom=1
interp=bicubic
boundary=hsym
# image resampling
for i in `seq 2 $NUMBER`; do
    INi=`printf $INPAT $i`
    INNOISYi=`printf $INPAT_NOISY $i`
    REGi=`printf $TRUE_REGPAT $i`
    # ica
        REGICAi=`printf $regpat_ica $i`
        OUTi=`printf $outpat_ica $i`
        synflow_global hom "`cat $REGICAi`" $in $OUTi /dev/null $zoom $interp /dev/null $boundary
        diff2 $OUTi $INi $OUTi
        crop 10 10 -10 -10 $OUTi $OUTi
    # ica noisy
        REGICAi=`printf $regpat_ica $i`
        OUTi=`printf $outpat_ica_noisy $i`
        synflow_global hom "`cat $REGICAi`" $REF $OUTi /dev/null $zoom $interp /dev/null $boundary
        diff2 $OUTi $INNOISYi $OUTi
        crop 10 10 -10 -10 $OUTi $OUTi
    # ica edge
        REGICAi=`printf $regpat_ica_edge $i`
        OUTi=`printf $outpat_ica_edge $i`
        synflow_global hom "`cat $REGICAi`" $in $OUTi /dev/null $zoom $interp /dev/null $boundary
        diff2 $OUTi $INi $OUTi
        crop 10 10 -10 -10 $OUTi $OUTi
    # ica edge noisy    
        REGICAi=`printf $regpat_ica_edge $i`
        OUTi=`printf $outpat_ica_edge_noisy $i`
        synflow_global hom "`cat $REGICAi`" $REF $OUTi /dev/null $zoom $interp /dev/null $boundary
        diff2 $OUTi $INNOISYi $OUTi
        crop 10 10 -10 -10 $OUTi $OUTi
    # sift
        REGSIFTi=`printf $regpat_sift $i`
        OUTi=`printf $outpat_sift $i`
        synflow_global hom "`cat $REGSIFTi`" $in $OUTi /dev/null $zoom $interp /dev/null $boundary
        diff2 $OUTi $INi $OUTi
        crop 10 10 -10 -10 $OUTi $OUTi
    # sift noisy    
        REGSIFTi=`printf $regpat_sift $i`
        OUTi=`printf $outpat_sift_noisy $i`
        synflow_global hom "`cat $REGSIFTi`" $REF $OUTi /dev/null $zoom $interp /dev/null $boundary
        diff2 $OUTi $INNOISYi $OUTi
        crop 10 10 -10 -10 $OUTi $OUTi
done
