## Usage

### Deploy the workload

1. Import a managed cluster and use the make command to enable all the needed addons for the managed cluster, run the command on the **hub** cluster:

```
AWS_BUCKET_NAME=<bucket_name> AWS_ACCESS_KEY=<access_key> AWS_SECRET_KEY=<secret_key> MANAGED_CLUSTER_NAME=<cluster1> make enable-all
```

Ensure only below `ManagedClusterAddon` are created and "AVAILABLE" status is true on the hub.

```bash
$ kubectl get mca -n cluster1
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

   **_Note_**: please make sure you have installed the `bc`(dnf install bc) command in your env:

```bash
MANAGED_CLUSTER_NAME=<cluster1> make cronjob
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

### Analysis the usage

Gather metrics and analysis after ahout 16 hours.

Export the **managed** cluster URL and token to the `OC_CLUSTER_URL` and `OC_TOKEN`.

```bash
$ export OC_CLUSTER_URL="https://api.fake.test.red-chesterfield.com:6443"
$ export OC_TOKEN="sha256~xxx"
```

On the **hub** cluster, analysis metrics based on the cronjob time.

```bash
./deploy/analysis.sh <cluster1>
```

The output would be like

```bash
+ CLUSTER=spoke
+ DURATION=17h
+ oc login https://api.fake.test.red-chesterfield.com:6443 --token sha256~xxx --insecure-skip-tls-verify=true
+ cd /acm-inspector/src/supervisor
+ python3 entry.py prom spoke 17h
The metrics has been collected and placed in /root/go/src/github.com/haoqing/acm-workload/cluster1, details see /root/go/src/github.com/haoqing/acm-workload/cluster1/logs
The analysis is complete, details see /root/go/src/github.com/haoqing/acm-workload/cluster1/acm_analysis
```
