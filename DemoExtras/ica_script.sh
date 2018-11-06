#!/bin/bash

if [ "$#" -lt "13" ]; then
    echo "usage:\n\t$0 nscales zoom eps transform robust lambda dbp edgepadding color gradient first_scale std eq"
    exit 1
fi

nscales=$1
zoom=$2
eps=$3
transform=$4
robust=$5
lambda=$6
dbp=$7
edgepadding=$8
color=$9
gradient=${10}
first_scale=${11}
std=${12}
eq=${13}

if [ "$color" = "True" ]; then
    GRAYMETHOD=1
else
    GRAYMETHOD=0
fi

if [ "$dbp" = "True" ]; then
    NANIFOUTSIDE=1
else
    NANIFOUTSIDE=0
    edgepadding=0
fi

ref=input_0.png
ref_noisy=input_noisy_0.png
warped=input_1.png
warped_noisy=input_noisy_1.png
file=transformation.txt
filewithout=transformation_without.txt
if [ -f input_2.txt ]; then
    file2=input_2.txt
else
    file2=""
fi

if [ "$eq" = "none" ]; then
    cp $warped $warped_noisy
else
    echo "Contrasts of the images are equalized"
    equalization $ref $warped $warped_noisy $eq
fi

echo "Standard deviation of the noise added: $std"
add_noise $ref $ref_noisy $std
add_noise $warped_noisy $warped_noisy $std

echo ""
inverse_compositional_algorithm $ref_noisy $warped_noisy -f $filewithout -z $zoom -n $nscales -r $robust -e $eps -t $transform -s 0 -c 0 -d 0 -p 0 -g 0 > /dev/null
inverse_compositional_algorithm $ref_noisy $warped_noisy -f $file -z $zoom -n $nscales -r $robust -e $eps -t $transform -s $first_scale -c $GRAYMETHOD -d $edgepadding -p $NANIFOUTSIDE -g $gradient -v

echo ""
echo "Without modification:"
generate_output $ref_noisy $warped_noisy $filewithout $file2
mv output_estimated.png output_estimated2.png
if [ -f epe.png ]; then
    mv epe.png epe2.png
    echo "vis=1" > algo_info.txt
fi
mv diff_image.png diff_image2.png

echo ""
echo "With modifications:"
generate_output $ref_noisy $warped_noisy $file $file2
