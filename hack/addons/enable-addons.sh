#!/bin/bash
# set -x
set -o errexit
set -o nounset
set -o pipefail

KUBECTL=${KUBECTL:-oc}

# Black        0;30     Dark Gray     1;30
# Red          0;31     Light Red     1;31
# Green        0;32     Light Green   1;32
# Brown/Orange 0;33     Yellow        1;33
# Blue         0;34     Light Blue    1;34
# Purple       0;35     Light Purple  1;35
# Cyan         0;36     Light Cyan    1;36
# Light Gray   0;37     White         1;37



RED='\033[0;31m'
Green='\033[0;32m'
NC='\033[0m' # No Color


# Function to display script usage
display_usage() {
    #echo "Usage: $0 <cluster_url> <username> <password>"
    echo "Usage: $0 <managed_cluster_name>"
    exit 1
}

CLUSTER_NAME="$1"
if [ -z "$CLUSTER_NAME" ]; then
  display_usage
fi

function wait_deployment() {
  set +e
  for((i=0;i<30;i++));
  do
    ${KUBECTL} -n $1 get deploy $2
    if [ 0 -eq $? ]; then
      break
    fi
    echo "sleep 1 second to wait deployment $1/$2 to exist: $i"
    sleep 1
  done
  set -e
}


${KUBECTL} create namespace open-cluster-management-observability --dry-run=client -o yaml | oc apply -f - # kubectl >= 1.19

set +o errexit
DOCKER_CONFIG_JSON=`${KUBECTL} extract secret/multiclusterhub-operator-pull-secret -n open-cluster-management --to=-`
set -o errexit

if [ -z "$DOCKER_CONFIG_JSON" ]; then
  DOCKER_CONFIG_JSON=`${KUBECTL} extract secret/pull-secret -n openshift-config --to=-`
fi

if [ -z "$DOCKER_CONFIG_JSON" ]; then
  echo "ERROR: Failed to extract pull secret"
  exit 1
fi

set +o errexit
# get the multiclusterhub-operator-pull-secret from the hub cluster, if not found, create one
found=`${KUBECTL} get secret multiclusterhub-operator-pull-secret -n open-cluster-management-observability`
set -o errexit


if [ -n "$found" ]; then
  echo "INFO: multiclusterhub-operator-pull-secret already exists"
else
  echo "INFO: creating multiclusterhub-operator-pull-secret"
  ${KUBECTL} create secret generic multiclusterhub-operator-pull-secret \
    -n open-cluster-management-observability \
    --from-literal=.dockerconfigjson="$DOCKER_CONFIG_JSON" \
    --type=kubernetes.io/dockerconfigjson
fi

${KUBECTL} apply -f thanos-object-storage.yaml -n open-cluster-management-observability
${KUBECTL} apply -f multiclusterobservability_cr.yaml

# wait_deployment open-cluster-management-observability observability-grafana
# ${KUBECTL} -n open-cluster-management-observability rollout status deploy observability-grafana --timeout=120s

${KUBECTL} wait --for=condition=Available=true managedclusteraddon/observability-controller -n ${CLUSTER_NAME} --timeout=600s
TIME_NOW=`date`
printf "${Green}Add-on observability-controller is enabled at:${NC} %s\n" "${TIME_NOW}"

# enable search addon
${KUBECTL} patch klusterletaddonconfig -n ${CLUSTER_NAME} ${CLUSTER_NAME} -p='{"spec":{"searchCollector":{"enabled": true}}}' --type=merge
${KUBECTL} wait --for=condition=Available=true managedclusteraddon/search-collector -n ${CLUSTER_NAME} --timeout=600s
TIME_NOW=`date`
printf "${Green}Add-on search-collector is enabled at:${NC} %s\n" "${TIME_NOW}"