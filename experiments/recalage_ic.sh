#!/bin/bash

if [ "$#" -lt "18" ]; then
    echo "usage:\n\t$0 NUMBER INPAT_NOISY TRUE_REGPAT REF GRAYMETHOD SAVE FIRST_SCALE EDGEPADDING ROBUST_GRADIENT ROBUST NANIFOUTSIDE SCALES PRECISION transform NTHREADS w h opt"
    exit 1
fi

NUMBER=$1
INPAT_NOISY=$2
TRUE_REGPAT=$3
REF=$4
GRAYMETHOD=$5
SAVE=$6
FIRST_SCALE=$7
EDGEPADDING=$8
ROBUST_GRADIENT=$9
ROBUST=${10}
NANIFOUTSIDE=${11}
SCALES=${12}
PRECISION=${13}
transform=${14}
NTHREADS=${15}
w=${16}
h=${17}
opt=${18}

TIMEFORMAT="%U"

echo "graymethod $GRAYMETHOD save $SAVE first_scale ${FIRST_SCALE} edge ${EDGEPADDING} gradient ${ROBUST_GRADIENT} robust ${ROBUST} nanifoutside ${NANIFOUTSIDE}"
basefile=graymethod${GRAYMETHOD}_save${SAVE}_scale${FIRST_SCALE}_edge${EDGEPADDING}_nan${NANIFOUTSIDE}_gradient${ROBUST_GRADIENT}_robust${ROBUST}
regpat_ica=ica_${basefile}_%i.hom
time_ica=time_ica_${basefile}.txt
field_ica=field_ica_${basefile}_%i.tiff
rmse_ica=rmse_ica_${basefile}.txt
max_ica=max_ica_${basefile}.txt

if [ ! -s $time_ica ]; then
    # ICA estimation
    { time for i in `seq 2 $NUMBER`; do
        INi=`printf $INPAT_NOISY $i`
        REGi=`printf $regpat_ica $i`
        cmd="GRAYMETHOD=$GRAYMETHOD SAVELONGER=$SAVE EDGEPADDING=$EDGEPADDING NANIFOUTSIDE=$NANIFOUTSIDE ROBUST_GRADIENT=$ROBUST_GRADIENT inverse_compositional_algorithm $REF $INi -f $REGi -n $SCALES -r $ROBUST -e $PRECISION -t $transform -s $FIRST_SCALE"
        echo "$cmd"
    done | parallel -j $NTHREADS &> /dev/null; } 2> $time_ica

    # field comparison
    for i in `seq 2 $NUMBER`; do
        REGICAi=`printf $regpat_ica $i`
        REGi=`printf $TRUE_REGPAT $i`
        FIELDi=`printf $field_ica $i`
        compare_homography $w $h "`cat $REGICAi`" "`cat $REGi`" $FIELDi $opt
        compute mean 0 $FIELDi >> $rmse_ica
        rm $FIELDi $REGICAi
    done
fi