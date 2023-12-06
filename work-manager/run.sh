#!/bin/bash
for((i=1;i<=$2;i++))
do
        kubectl apply -f $1 --dry-run=client -o yaml | sed "s|NUM|${i}|g" | kubectl apply -f -
done
