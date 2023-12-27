#!/bin/bash

var=$(cmake -version | head -n 1 | awk '{print $3}')
echo $var
