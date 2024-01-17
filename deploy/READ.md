## Usage

Import managed cluster and ensure only below agents are running on the managed cluster.

```bash
$ kubectl get pods -n open-cluster-management-agent
NAME                                READY   STATUS    RESTARTS   AGE
klusterlet-74f78b8bd8-zwhdv         1/1     Running   0          2d18h
klusterlet-agent-595b65d577-2wq9w   1/1     Running   0          2d18h

$ kubectl get pods -n open-cluster-management-agent-addon
NAME                                           READY   STATUS    RESTARTS   AGE
application-manager-5d4f9c4cb-r7s9f            1/1     Running   0          2d18h
cluster-proxy-proxy-agent-5dcdc877bc-5phrx     2/2     Running   0          2d18h
cluster-proxy-service-proxy-76c58f848c-pjnb7   1/1     Running   0          2d18h
config-policy-controller-6f97789877-jghrb      2/2     Running   0          2d18h
governance-policy-framework-7564847778-w78bw   2/2     Running   0          2d18h
klusterlet-addon-search-5b54f7fcd7-fppt2       1/1     Running   0          2d18h
klusterlet-addon-workmgr-f6978cddb-xpj5x       1/1     Running   0          2d18h

$ kubectl get pods -n open-cluster-management-addon-observability
NAME                                               READY   STATUS    RESTARTS   AGE
endpoint-observability-operator-79456bc79d-vrg5b   1/1     Running   0          2d18h
metrics-collector-deployment-7cbb69d9b-trqk6       1/1     Running   0          2d18h
```

On the hub cluster, generate cron job YAML based on the `ManagedCluster` `.metadata.creationTimestamp`.

```bash
$ ./generate.sh cluster1        
managed cluster creationTimestamp: 2024-01-12T14:35:55Z
job_app create schedule: 35 20 12 01 5
job_app delete schedule: 05 22 12 01 5
job_policy create schedule: 05 22 12 01 5
job_policy delete schedule: 35 23 12 01 5
job_obs create schedule: 35 23 12 01 5
job_obs delete schedule: 05 01 13 01 6  

$ ls output 
job_app_create.yaml  job_obs_create.yaml  job_policy_create.yaml
job_app_delete.yaml  job_obs_delete.yaml  job_policy_delete.yaml
```

On the hub cluster, create cron job.

```bash
$ kubectl apply -k ./ 
serviceaccount/my-cronjob created
clusterrolebinding.rbac.authorization.k8s.io/my-cronjob created
cronjob.batch/app-create-cluster1 created
cronjob.batch/app-delete-cluster1 created
cronjob.batch/obs-create-cluster1 created
cronjob.batch/obs-delete-cluster1 created
cronjob.batch/policy-create-cluster1 created
cronjob.batch/policy-delete-cluster1 created
```

On the managed cluster, gather metrics after about 11 hours.

```bash
$ mkdir cluster1
$ export OC_CLUSTER_URL="https://api.server-foundation-sno-p8fbq.dev04.red-chesterfield.com:6443"
$ export OC_TOKEN="sha256~xxx"
$ docker run -e OC_CLUSTER_URL=$OC_CLUSTER_URL -e OC_TOKEN=$OC_TOKEN -e DURATION=12h -e CLUSTER=spoke -v $PWD/cluster1:/acm-inspector/output quay.io/haoqing/acm-inspector:latest
```

On the hub cluster, analysis metrics based on the cronjob time.

```bash
./analysis.sh cluster1 $PWD/cluster1
```