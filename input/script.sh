#!/bin/bash

for im in homography rotation rotation_translation translation zoom zoom_rotation_translation zoom_rotation homography2 identity; do
	cp ${im}1.png reverse/${im}2.png
	cp ${im}2.png reverse/${im}1.png
	invert_homography_ica "`cat ${im}.mat`" reverse/${im}.mat
done
