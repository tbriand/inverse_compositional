#!/bin/bash

if [ "$#" -lt "3" ]; then
    echo "usage:\n\t$0 noise n L"
    exit 1
fi

noise=$1
NUMBER=$2
L=$3

if [ -z "$BUILD_IMAGES" ]; then
    BUILD_IMAGES=0;
fi
if [ -z "$NOISE" ]; then
    NOISE=0;
fi
if [ -z "$NTHREADS" ]; then
    NTHREADS=1
fi
if [ -z "$GRAYMETHOD" ]; then
    GRAYMETHOD=0
fi
if [ -z "$SAVELONGER" ]; then
    SAVELONGER=1
fi
if [ -z "$NANIFOUTSIDE" ]; then
    NANIFOUTSIDE=1
fi
if [ -z "$EDGEPADDING" ]; then
    EDGEPADDING=5
fi
if [ -z "$ROBUST_GRADIENT" ]; then
    ROBUST_GRADIENT=3
fi
if [ -z "$NSCALES" ]; then
    NSCALES=5
fi
if [ -z "$ROBUST" ]; then
    ROBUST=3
fi
if [ -z "$PRECISION" ]; then
    PRECISION=0.001
fi
if [ -z "$FIRST_SCALE" ]; then
    FIRST_SCALE=0
fi

in=~/images/lena_nb.png
in=~/images/traffic.png
#in=~/images/homography2.png

echo "Experiments with GRAYMETHOD=$GRAYMETHOD SAVELONGER=$SAVELONGER EDGEPADDING=$EDGEPADDING NANIFOUTSIDE=$NANIFOUTSIDE ROBUST_GRADIENT=$ROBUST_GRADIENT NSCALES=$NSCALES PRECISION=$PRECISION FIRST_SCALE=$FIRST_SCALE ROBUST=$ROBUST"
echo "images $in"

TIMEFORMAT=%U

dir=comparison_javier_optimized
mkdir $dir
cd $dir

interp=bicubic
#interp=splineper
boundary=hsym
base_out=burst
transform=8 #homography
if [ "$BUILD_IMAGES" -eq "1" ]; then
   create_burst $in $base_out $NUMBER $interp $boundary $L $transform
fi

# comparison fields
centered=0
w=`imprintf %w $in`
h=`imprintf %h $in`
opt=1 # to determine if comparison has h1-h2 (1) or h2^-1 o h1 - id (0)

if [ "$NOISE" -eq "1" ]; then
    for i in `seq 1 $NUMBER`; do
        add_noise $noise ${base_out}_$i.tiff ${base_out}_noisy_$i.tiff
    done
fi

REF=${base_out}_noisy_1.tiff
{ time for i in `seq 2 $NUMBER`; do
    INi=${base_out}_noisy_$i.tiff
    REGi=${base_out}_estimated_$i.hom
    REG2i=${base_out}_estimated_javier_$i.hom
    cmd="GRAYMETHOD=$GRAYMETHOD SAVELONGER=$SAVELONGER EDGEPADDING=$EDGEPADDING NANIFOUTSIDE=$NANIFOUTSIDE ROBUST_GRADIENT=$ROBUST_GRADIENT inverse_compositional_algorithm $REF $INi -f $REGi -n $NSCALES -r $ROBUST -e $PRECISION -t $transform -s $FIRST_SCALE"
    cmd="$cmd; ica_javier $REF $INi -f $REG2i -n $NSCALES -r $ROBUST -e $PRECISION -t $transform;"
    echo $cmd
done | parallel -j $NTHREADS &> /dev/null; }

# image parameters
rmse_ica=rmse.txt
rmse_ica_javier=rmse_javier.txt
rm $rmse_ica $rmse_ica_javier -f
for i in `seq 2 $NUMBER`; do
    #optimized
    REGICAi=${base_out}_estimated_$i.hom
    REGi=${base_out}_$i.hom
    FIELDi=${base_out}_estimated_$i.tiff
    compare_homography $w $h "`cat $REGICAi`" "`cat $REGi`" $FIELDi $opt
    compute rmse $centered $FIELDi >> $rmse_ica
    #rm $FIELDi #$REGICAi
    #javier
    REGICAi=${base_out}_estimated_javier_$i.hom
    FIELDi=${base_out}_estimated_javier_$i.tiff
    compare_homography $w $h "`cat $REGICAi`" "`cat $REGi`" $FIELDi $opt
    compute rmse $centered $FIELDi >> $rmse_ica_javier
done
echo "optimized"
mean_and_std $rmse_ica 0
echo "javier"
mean_and_std $rmse_ica_javier 0

cd ..
