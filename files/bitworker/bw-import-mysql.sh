#!/bin/bash

pfad="/home/mysql/2021-06-22"



find $pfad | while read line; do
    echo $line;
done


