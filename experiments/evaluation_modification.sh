#!/bin/bash

if [ "$#" -lt "3" ]; then
    echo "usage:\n\t$0 in number displacement_max_corner [dir]"
    echo "example toto.tiff 10 5"
    echo "image en chemin absolu"
    exit 1
fi

in=$1
NUMBER=$2
L=$3

if [ -z "$NTHREADS" ]; then
    NTHREADS=1
fi
if [ -z "$BUILD_IMAGES" ]; then
    BUILD_IMAGES=1
fi    

# create directory
if [ -z "$4" ]; then
    dir=evaluation_modification
else
    dir=$4
fi

rm -rf $dir
mkdir $dir
cd $dir

# create burst
echo "Creating burst of $NUMBER images with displacement of $L"
interp=bicubic
boundary=hsym
base_out=burst
transform=8 #homography
if [ "$BUILD_IMAGES" -eq "1" ]; then
    create_burst $in $base_out $NUMBER $interp $boundary $L $transform
fi

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
NORMALIZATION=0
SAVE=1
SCALES=5
PRECISION=0.001

# comparison fields
centered=0
w=`imprintf %w $in`
h=`imprintf %h $in`
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
            compare_homography $w $h "`cat $REGSIFTi`" "`cat $REGi`" $FIELDi $opt
            compute mean $centered $FIELDi >> $rmse_sift
            rm $FIELDi $REGSIFTi
        done

    # ICA
        c=`imprintf %c $REF`
        echo "ICA estimation"
        if [ "$c" -eq "3" ]; then
            for GRAYMETHOD in 0 1; do
                for FIRST_SCALE in 0 1 2 3; do
                    for NANIFOUTSIDE in 0 1; do
                        for EDGEPADDING in 0 5; do
                            if  [ "$NANIFOUTSIDE" -eq "1" -o "$EDGEPADDING" -eq "0" ]; then
                                for ROBUST_GRADIENT in 0 1 2 3 4 5; do
                                    for ROBUST in 0 3; do
                                        echo "graymethod $GRAYMETHOD save $SAVE first_scale ${FIRST_SCALE} edge ${EDGEPADDING} gradient ${ROBUST_GRADIENT} robust ${ROBUST} nanifoutside ${NANIFOUTSIDE}"
                                        basefile=graymethod${GRAYMETHOD}_save${SAVE}_scale${FIRST_SCALE}_edge${EDGEPADDING}_nan${NANIFOUTSIDE}_gradient${ROBUST_GRADIENT}_robust${ROBUST}
                                        regpat_ica=ica_${basefile}_%i.hom
                                        time_ica=time_ica_${basefile}.txt
                                        field_ica=field_ica_${basefile}_%i.tiff
                                        rmse_ica=rmse_ica_${basefile}.txt
                                        max_ica=max_ica_${basefile}.txt

                                        # ICA estimation
                                        { time for i in `seq 2 $NUMBER`; do
                                            INi=`printf $INPAT_NOISY $i`
                                            REGi=`printf $regpat_ica $i`
                                            cmd="GRAYMETHOD=$GRAYMETHOD SAVELONGER=$SAVE NORMALIZATION=$NORMALIZATION EDGEPADDING=$EDGEPADDING NANIFOUTSIDE=$NANIFOUTSIDE ROBUST_GRADIENT=$ROBUST_GRADIENT inverse_compositional_algorithm $REF $INi -f $REGi -n $SCALES -r $ROBUST -e $PRECISION -t $transform -s $FIRST_SCALE"
                                            echo "$cmd"
                                        done | parallel -j $NTHREADS &> /dev/null; } 2> $time_ica

                                        # field comparison
                                        for i in `seq 2 $NUMBER`; do
                                            REGICAi=`printf $regpat_ica $i`
                                            REGi=`printf $TRUE_REGPAT $i`
                                            FIELDi=`printf $field_ica $i`
                                            compare_homography $w $h "`cat $REGICAi`" "`cat $REGi`" $FIELDi $opt
                                            compute mean $centered $FIELDi >> $rmse_ica
                                            rm $FIELDi $REGICAi
                                        done
                                    done
                                done
                            fi
                        done
                    done
                done
            done
    else
        GRAYMETHOD=0
            for FIRST_SCALE in 0 1 2 3; do
                for EDGEPADDING in 0 5; do
                    for NANIFOUTSIDE in 0 1; do
                        if  [ "$NANIFOUTSIDE" -eq "1" -o "$EDGEPADDING" -eq "0" ]; then
                            for ROBUST_GRADIENT in 0 1 2 3 4 5; do
                                for ROBUST in 0 3; do
                                    echo "graymethod $GRAYMETHOD save $SAVE first_scale ${FIRST_SCALE} edge ${EDGEPADDING} gradient ${ROBUST_GRADIENT} robust ${ROBUST} nanifoutside ${NANIFOUTSIDE}"
                                    basefile=graymethod${GRAYMETHOD}_save${SAVE}_scale${FIRST_SCALE}_edge${EDGEPADDING}_nan${NANIFOUTSIDE}_gradient${ROBUST_GRADIENT}_robust${ROBUST}
                                    regpat_ica=ica_${basefile}_%i.hom
                                    time_ica=time_ica_${basefile}.txt
                                    field_ica=field_ica_${basefile}_%i.tiff
                                    rmse_ica=rmse_ica_${basefile}.txt
                                    max_ica=max_ica_${basefile}.txt

                                    # ICA estimation
                                    { time for i in `seq 2 $NUMBER`; do
                                        INi=`printf $INPAT_NOISY $i`
                                        REGi=`printf $regpat_ica $i`
                                        cmd="GRAYMETHOD=$GRAYMETHOD SAVELONGER=$SAVE NORMALIZATION=$NORMALIZATION EDGEPADDING=$EDGEPADDING NANIFOUTSIDE=$NANIFOUTSIDE ROBUST_GRADIENT=$ROBUST_GRADIENT inverse_compositional_algorithm $REF $INi -f $REGi -n $SCALES -r $ROBUST -e $PRECISION -t $transform -s $FIRST_SCALE"
                                        echo "$cmd"
                                    done | parallel -j $NTHREADS &> /dev/null; } 2> $time_ica

                                    # field comparison
                                    for i in `seq 2 $NUMBER`; do
                                        REGICAi=`printf $regpat_ica $i`
                                        REGi=`printf $TRUE_REGPAT $i`
                                        FIELDi=`printf $field_ica $i`
                                        compare_homography $w $h "`cat $REGICAi`" "`cat $REGi`" $FIELDi $opt
                                        compute mean $centered $FIELDi >> $rmse_ica
                                        rm $FIELDi $REGICAi
                                    done
                                done
                            done
                        fi
                    done
                done
            done
    fi
            
    #clean
    for i in `seq 1 $NUMBER`; do
            OUTi=`printf $INPAT_NOISY $i`
            rm $OUTi
    done
    cd ..
done

cd ..
