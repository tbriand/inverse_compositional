#!/bin/bash

if [ "$#" -lt "12" ]; then
    echo "usage:\n\t$0 nscales zoom eps transform robust lambda dbp edgepadding color gradient first_scale std"
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

echo "Standard deviation of the noise added: $std"
add_noise $ref $ref_noisy $std
add_noise $warped $warped_noisy $std

echo ""
GRAYMETHOD=0 EDGEPADDING=0 NANIFOUTSIDE=0 ROBUST_GRADIENT=0 inverse_compositional_algorithm $ref_noisy $warped_noisy -f $filewithout -z $zoom -n $nscales -r $robust -e $eps -t $transform -s 0 > /dev/null
GRAYMETHOD=$GRAYMETHOD EDGEPADDING=$edgepadding NANIFOUTSIDE=$NANIFOUTSIDE ROBUST_GRADIENT=$gradient inverse_compositional_algorithm $ref_noisy $warped_noisy -f $file -z $zoom -n $nscales -r $robust -e $eps -t $transform -s $first_scale -v

echo ""
echo "Without modification:"
NANIFOUTSIDE=1 EDGEPADDING=0 generate_output $ref_noisy $warped_noisy $filewithout $file2
mv output_estimated.png output_estimated2.png
if [ -f epe.png ]; then
    mv epe.png epe2.png
fi
mv diff_image.png diff_image2.png

echo ""
echo "With modifications:"
NANIFOUTSIDE=1 EDGEPADDING=0 generate_output $ref_noisy $warped_noisy $file $file2
