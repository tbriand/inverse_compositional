#!/bin/bash

if [ "$#" -lt "11" ]; then
    echo "usage:\n\t$0 nscales zoom eps transform robust lambda dbp edgepadding color gradient first_scale"
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

if [ "$color" = "True" ]; then
    GRAYMETHOD=1
else
    GRAYMETHOD=0
fi
if [ "$dbp" = "True" ]; then
    NANIFOUTSIDE=1
else
    NANIFOUTSIDE=0
    EDGEPADDING=0
fi

ref=input_0.png
warped=input_1.png
file=transformation.txt

GRAYMETHOD=$GRAYMETHOD EDGEPADDING=$dbp NANIFOUTSIDE=$NANIFOUTSIDE ROBUST_GRADIENT=$gradient inverse_compositional_algorithm $ref $warped -f $file -z $zoom -n $nscales -r $robust -e $eps -t $transform -s $first_scale -v

# créer l'image recalee
# faire la différence avec l'image de référence
# ajouter bruit
# Si vérité terrain calculer the EPE image, afficher vérité terrain