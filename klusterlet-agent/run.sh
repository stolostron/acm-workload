#!/bin/bash
for((i=1;i<=$3;i++))
do
        kubectl apply -f $2 --dry-run=client -o yaml | sed "s|NUM|${i}|g" | kubectl $1 -f -
done
