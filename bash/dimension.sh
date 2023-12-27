#!/bin/bash

##### Must install "imageMagick"
# pacman -S mingw-w64-ucrt-x86_64-imagemagick
# identify -format "%wx%h" image.jpg
# 1920x1080

shopt -s nullglob

if [[ ! -d ./image_o ]]
then
    mkdir ./image_o
    echo "The image_o folder has been created."
fi

if [[ ! -d ./image_n ]]
then
    mkdir ./image_n
    echo "The image_n folder has been created."
fi

for f in *.{jpg,jpeg,png}
do
    if [[ $(identify -format "%h" $f) -gt 1080 ]]
    then
        mv $f ./image_o
        echo "$f : move to image_o"
    else
        mv $f ./image_n
        echo "$f : move to image_n"
    fi
done
