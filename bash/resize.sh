#!/bin/bash

mkdir ./resize

for i in *.{jpg,jpeg,png}
do
  if [ -f $i ]; then
    magick $i -resize 2560x1440 ./resize/$i && echo "$i : resized!"
  fi
done
