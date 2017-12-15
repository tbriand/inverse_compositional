dirimage=../input
number=101
L=20
for image in affinity2 homography22 homography2 identity2 rotation_translation2 translation2 zoom2 zoom_rotation2 zoom_rotation_translation2 lena; do
    im=$dirimage/$image.png
    ./evaluation_modification.sh $im $number $L $image
    ./evaluation_modification_latex.sh $image > ${image}_L20_avocat.txt
    rm -rf $image
done
