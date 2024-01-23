## Usage

### Deploy the workload

1. Import a managed cluster and use the make command to enable all the needed addons for the managed cluster. 

Login to the **hub** cluster and run the below command:

```bash
export AWS_BUCKET_NAME=<bucket_name> 
export AWS_ACCESS_KEY=<access_key>
export AWS_SECRET_KEY=<secret_key> 
export MANAGED_CLUSTER_NAME=<cluster1>

docker run -it -e AWS_BUCKET_NAME=$AWS_BUCKET_NAME -e AWS_ACCESS_KEY=$AWS_ACCESS_KEY -e AWS_SECRET_KEY=$AWS_SECRET_KEY -e MANAGED_CLUSTER_NAME=$MANAGED_CLUSTER_NAME -v /root/.kube:/root/.kube quay.io/haoqing/acm-workload:latest make enable-all
```

Ensure only below `ManagedClusterAddon` are created and "AVAILABLE" status is true on the hub.

```bash
$ kubectl get mca -n $MANAGED_CLUSTER_NAME
NAME                          AVAILABLE   DEGRADED   PROGRESSING
application-manager           True
cluster-proxy                 True
config-policy-controller      True
governance-policy-framework   True
observability-controller      True                   False
search-collector              True
work-manager                  True
```

2. On the **hub** cluster, generate and create cron job based on the `ManagedCluster` `.metadata.creationTimestamp`. 

```bash
docker run -it -e MANAGED_CLUSTER_NAME=$MANAGED_CLUSTER_NAME -v /root/.kube:/root/.kube quay.io/haoqing/acm-workload:latest make cronjob
```

Ensure the below resources are created on the hub.

```bash
$ kubectl get cronjob
NAME                            SCHEDULE        SUSPEND   ACTIVE   LAST SCHEDULE   AGE
app-create-cluster1             40 14 08 01 1   False     0        <none>          65s
app-delete-cluster1             10 16 08 01 1   False     0        <none>          65s
enable-all-cluster1             40 23 08 01 1   False     0        <none>          65s
enable-app-cluster1             10 19 08 01 1   False     0        <none>          65s
enable-policy-proxy-cluster1    40 20 08 01 1   False     0        <none>          65s
enable-policy-search-cluster1   10 22 08 01 1   False     0        <none>          65s
obs-create-cluster1             40 17 08 01 1   False     0        <none>          65s
obs-delete-cluster1             10 19 08 01 1   False     0        <none>          65s
policy-create-cluster1          10 16 08 01 1   False     0        <none>          65s
policy-delete-cluster1          40 17 08 01 1   False     0        <none>          65s

$ kubectl get serviceaccount/my-cronjob
NAME         SECRETS   AGE
my-cronjob   0         2m49s

$ kubectl get clusterrolebinding.rbac.authorization.k8s.io/my-cronjob
NAME         ROLE                        AGE
my-cronjob   ClusterRole/cluster-admin   2m58s
```

### Analysis the resource usage

Gather metrics and analysis after ahout 16 hours.

Export the **managed** cluster URL and token to the `OC_CLUSTER_URL` and `OC_TOKEN`.

```bash
export MANAGED_CLUSTER_NAME=<cluster1>
export OC_CLUSTER_URL="https://api.fake.test.red-chesterfield.com:6443"
export OC_TOKEN="sha256~xxx"
```

Login to the **hub** cluster, gather the metrics to folder `$PWD/$MANAGED_CLUSTER_NAME`.

```bash
export DURATION=$(oc get managedclusters $MANAGED_CLUSTER_NAME --no-headers | awk '{gsub(/h/,"",$6); $6+=1; print $6"h"}')
mkdir $MANAGED_CLUSTER_NAME
docker run -e OC_CLUSTER_URL=$OC_CLUSTER_URL -e OC_TOKEN=$OC_TOKEN -e DURATION=$DURATION -e CLUSTER=spoke -v $PWD/$MANAGED_CLUSTER_NAME:/acm-inspector/output quay.io/haoqing/acm-inspector:latest > $PWD/$MANAGED_CLUSTER_NAME/logs
```

On the **hub** cluster, analysis the metrics based on the cronjob created time, the result is output to `$PWD/$MANAGED_CLUSTER_NAME/acm_analysis`.

```bash
docker run -it -e MANAGED_CLUSTER_NAME=$MANAGED_CLUSTER_NAME -v /root/.kube:/root/.kube -v $PWD/$MANAGED_CLUSTER_NAME/:/acm-workload/$MANAGED_CLUSTER_NAME quay.io/haoqing/acm-workload:latest make analysis
```