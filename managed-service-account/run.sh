#!/bin/bash
cluster_name=$3
if [ -z "$cluster_name" ]
then
      echo "Cluster name is empty"
      exit 1
fi

for((i=1;i<=$2;i++))
do
        kubectl apply -f $1 --dry-run=client -o yaml | sed "s|NUM|${i}|g" \
        | sed "s|MANAGED-CLUSTER-NAME|${cluster_name}|g" | kubectl apply -f -
done
