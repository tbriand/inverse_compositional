#!/bin/bash

if [ "$#" -lt "3" ]; then
    echo "usage:\n\t$0 in number displacement_max_corner [dir]"
    echo "example toto.tiff 10 5"
    exit 1
fi

in=$1
NUMBER=$2
L=$3

NTHREADS=1
if [ -z "$BUILD_IMAGES" ]; then
    BUILD_IMAGES=1
fi    

prog=../../recalage_ic.sh

# create directory
if [ -z "$4" ]; then
    dir=evaluation_modification
else
    dir=$4
fi

ref=ref.tiff

rm -rf $dir
mkdir $dir
cp $in $dir/$ref
cd $dir

# create burst
echo "Creating burst of $NUMBER images with displacement of $L"
interp=bicubic
boundary=hsym
base_out=burst
transform=8 #homography
if [ "$BUILD_IMAGES" -eq "1" ]; then
    create_burst $ref $base_out $NUMBER $interp $boundary $L $transform
fi


# TEST with inverse homography
for i in `seq 2 $NUMBER`; do
            REGi=${base_out}_$i.hom
            invert_homography_ica "`cat $REGi`" $REGi
done
# END TEST

# sift parameters
regpat=sift_%i.tiff #just used to set the name of the homography files ...
regpat_sift=sift_%i.hom # to this value (shitty script)
method=splineper #useless
boundary=hsym #useless
sr=sr
field_sift=field_sift_%i.tiff
rmse_sift=rmse_sift.txt
max_sift=max_sift.txt
time_sift=time_sift.txt
ref_number=1 # the reference image is assumed to be the first image

TIMEFORMAT="%U"

# ICA parameters
SAVE=1
SCALES=5
PRECISION=0.001

# comparison fields
centered=0
w=`imprintf %w $ref`
h=`imprintf %h $ref`
opt=1 # to determine if comparison has h1-h2 (1) or h2^-1 o h1 - id (0)

# image parameters
INPAT=../${base_out}_%i.tiff
INPAT_NOISY=noisy_%i.tiff
TRUE_REGPAT=../${base_out}_%i.hom
REF=`printf $INPAT_NOISY 1`

# loop over the noise level
for noise in 0 3 5 10 20 30 50; do
    echo "Noise level $noise"
    dir=noise$noise
    mkdir $dir
    cd $dir
    for i in `seq 1 $NUMBER`; do
            INi=`printf $INPAT $i`
            OUTi=`printf $INPAT_NOISY $i`
            add_noise $noise $INi $OUTi
    done

    # SIFT + RANSAC estimation
        echo "SIFT + RANSAC estimation"
        { time NTHREADS=$NTHREADS burst_registration_iteration.sh $INPAT_NOISY $regpat $ref_number $NUMBER $ref_number $method $boundary $sr 0 &> /dev/null; } 2> $time_sift 

        # field comparison
        for i in `seq 2 $NUMBER`; do
            REGSIFTi=`printf $regpat_sift $i`
            REGi=`printf $TRUE_REGPAT $i`
            FIELDi=`printf $field_sift $i`
# TEST with inverse homography
            invert_homography_ica "`cat $REGSIFTi`" $REGSIFTi
# END TEST
            compare_homography $w $h "`cat $REGSIFTi`" "`cat $REGi`" $FIELDi $opt
            compute mean $centered $FIELDi >> $rmse_sift
            rm $FIELDi $REGSIFTi
        done

    # ICA
        echo "ICA estimation"
            
            for ROBUST in 0 3; do
                # DBP table
                FIRST_SCALE=0
                ROBUST_GRADIENT=0
                GRAYMETHOD=0
                NANIFOUTSIDE=0
                EDGEPADDING=0
                $prog $NUMBER $INPAT_NOISY $TRUE_REGPAT $REF $GRAYMETHOD $SAVE $FIRST_SCALE $EDGEPADDING $ROBUST_GRADIENT $ROBUST $NANIFOUTSIDE $SCALES $PRECISION $transform $NTHREADS $w $h $opt
                            
                NANIFOUTSIDE=1
                for EDGEPADDING in 0 5; do
                        $prog $NUMBER $INPAT_NOISY $TRUE_REGPAT $REF $GRAYMETHOD $SAVE $FIRST_SCALE $EDGEPADDING $ROBUST_GRADIENT $ROBUST $NANIFOUTSIDE $SCALES $PRECISION $transform $NTHREADS $w $h $opt
                done
                
                #COLOR
                FIRST_SCALE=0
                ROBUST_GRADIENT=0
                EDGEPADDING=5
                NANIFOUTSIDE=1
                for GRAYMETHOD in 0 1; do
                    $prog $NUMBER $INPAT_NOISY $TRUE_REGPAT $REF $GRAYMETHOD $SAVE $FIRST_SCALE $EDGEPADDING $ROBUST_GRADIENT $ROBUST $NANIFOUTSIDE $SCALES $PRECISION $transform $NTHREADS $w $h $opt
                done
                
                #GRADIENT
                FIRST_SCALE=0
                GRAYMETHOD=1
                NANIFOUTSIDE=1
                EDGEPADDING=5
                for ROBUST_GRADIENT in 0 1 2 3 4 5; do
                    $prog $NUMBER $INPAT_NOISY $TRUE_REGPAT $REF $GRAYMETHOD $SAVE $FIRST_SCALE $EDGEPADDING $ROBUST_GRADIENT $ROBUST $NANIFOUTSIDE $SCALES $PRECISION $transform $NTHREADS $w $h $opt
                done
                
                #FIRST SCALE
                ROBUST_GRADIENT=3
                GRAYMETHOD=1
                NANIFOUTSIDE=1
                EDGEPADDING=5
                for FIRST_SCALE in 0 1 2 3; do
                    $prog $NUMBER $INPAT_NOISY $TRUE_REGPAT $REF $GRAYMETHOD $SAVE $FIRST_SCALE $EDGEPADDING $ROBUST_GRADIENT $ROBUST $NANIFOUTSIDE $SCALES $PRECISION $transform $NTHREADS $w $h $opt
                done
                
                #all method
                GRAYMETHOD=0
		EDGEPADDING=0
                NANIFOUTSIDE=0
                ROBUST_GRADIENT=0
                FIRST_SCALE=0
                $prog $NUMBER $INPAT_NOISY $TRUE_REGPAT $REF $GRAYMETHOD $SAVE $FIRST_SCALE $EDGEPADDING $ROBUST_GRADIENT $ROBUST $NANIFOUTSIDE $SCALES $PRECISION $transform $NTHREADS $w $h $opt
                
                GRAYMETHOD=1
                EDGEPADDING=5
                NANIFOUTSIDE=1
                ROBUST_GRADIENT=3
                FIRST_SCALE=0
                $prog $NUMBER $INPAT_NOISY $TRUE_REGPAT $REF $GRAYMETHOD $SAVE $FIRST_SCALE $EDGEPADDING $ROBUST_GRADIENT $ROBUST $NANIFOUTSIDE $SCALES $PRECISION $transform $NTHREADS $w $h $opt
                
                GRAYMETHOD=1
		EDGEPADDING=5
                NANIFOUTSIDE=1
                ROBUST_GRADIENT=3
                FIRST_SCALE=1
                $prog $NUMBER $INPAT_NOISY $TRUE_REGPAT $REF $GRAYMETHOD $SAVE $FIRST_SCALE $EDGEPADDING $ROBUST_GRADIENT $ROBUST $NANIFOUTSIDE $SCALES $PRECISION $transform $NTHREADS $w $h $opt
            done
            
    #clean
    for i in `seq 1 $NUMBER`; do
            OUTi=`printf $INPAT_NOISY $i`
            rm $OUTi
    done
    cd ..
done

cd ..