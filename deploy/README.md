## Usage

1. Import a managed cluster and use the make command to enable all the needed addons for the managed cluster, run the command on the **hub** cluster:

```
AWS_BUCKET_NAME=<bucket_name> AWS_ACCESS_KEY=<access_key> AWS_SECRET_KEY=<secret_key> MANAGED_CLUSTER_NAME=<cluster1> make enable-all
```

2. Check only below agents are running on the **managed** cluster.

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

3. On the **hub** cluster, generate cron job YAML based on the `ManagedCluster` `.metadata.creationTimestamp`. Note: please make sure you have installed the `bc`(dnf install bc) command in your env:

```bash
$ ./generate.sh cluster1
managed cluster creationTimestamp: 2024-01-17T09:11:16Z
job_app create schedule: 11 15 17 01 3
job_app delete schedule: 41 16 17 01 3
job_policy create schedule: 41 16 17 01 3
job_policy delete schedule: 11 18 17 01 3
job_obs create schedule: 11 18 17 01 3
job_obs delete schedule: 41 19 17 01 3
job_enable_app create schedule: 41 19 17 01 3
job_enable_app delete schedule: 11 21 17 01 3
job_enable_policy_proxy create schedule: 11 21 17 01 3
job_enable_policy_proxy delete schedule: 41 22 17 01 3
job_enable_policy_search create schedule: 41 22 17 01 3
job_enable_policy_search delete schedule: 11 00 18 01 4
job_enable_all create schedule: 11 00 18 01 4
job_enable_all delete schedule: 41 01 18 01 4


$ ls output 
job_app_create.yaml  job_enable_all_create.yaml  job_enable_policy_proxy_create.yaml   job_obs_create.yaml  job_policy_create.yaml
job_app_delete.yaml  job_enable_app_create.yaml  job_enable_policy_search_create.yaml  job_obs_delete.yaml  job_policy_delete.yaml
```

4. On the **hub** cluster, create cron job.

```bash
$ kubectl apply -k ./ 
cronjob.batch/app-create-cluster1 created
cronjob.batch/app-delete-cluster1 created
cronjob.batch/enable-all-cluster1 created
cronjob.batch/enable-app-cluster1 created
cronjob.batch/enable-policy-proxy-cluster1 created
cronjob.batch/enable-policy-search-cluster1 created
cronjob.batch/obs-create-cluster1 created
cronjob.batch/obs-delete-cluster1 created
cronjob.batch/policy-create-cluster1 created
cronjob.batch/policy-delete-cluster1 created
```

5. On the **managed** cluster, gather metrics after about 11 hours.

```bash
$ mkdir cluster1
$ export OC_CLUSTER_URL="https://api.fake.test.red-chesterfield.com:6443"
$ export OC_TOKEN="sha256~xxx"
$ docker run -e OC_CLUSTER_URL=$OC_CLUSTER_URL -e OC_TOKEN=$OC_TOKEN -e DURATION=12h -e CLUSTER=spoke -v $PWD/cluster1:/acm-inspector/output quay.io/haoqing/acm-inspector:latest
```

6. On the **hub** cluster, analysis metrics based on the cronjob time.

```bash
./analysis.sh cluster1 $PWD/cluster1
```