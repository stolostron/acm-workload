### Usage

Generate 10 manifestworks on cluster1.

```bash
$ ./run.sh apply resource.yaml 10 cluster1
manifestwork.work.open-cluster-management.io/my-work-1 created
manifestwork.work.open-cluster-management.io/my-work-2 created
manifestwork.work.open-cluster-management.io/my-work-3 created
manifestwork.work.open-cluster-management.io/my-work-4 created
manifestwork.work.open-cluster-management.io/my-work-5 created
manifestwork.work.open-cluster-management.io/my-work-6 created
manifestwork.work.open-cluster-management.io/my-work-7 created
manifestwork.work.open-cluster-management.io/my-work-8 created
manifestwork.work.open-cluster-management.io/my-work-9 created
manifestwork.work.open-cluster-management.io/my-work-10 created
```

Delete 10 manifestworks on cluster1.
```bash
$ ./run.sh delete resource.yaml 10 cluster1
manifestwork.work.open-cluster-management.io "my-work-1" deleted
manifestwork.work.open-cluster-management.io "my-work-2" deleted
manifestwork.work.open-cluster-management.io "my-work-3" deleted
manifestwork.work.open-cluster-management.io "my-work-4" deleted
manifestwork.work.open-cluster-management.io "my-work-5" deleted
manifestwork.work.open-cluster-management.io "my-work-6" deleted
manifestwork.work.open-cluster-management.io "my-work-7" deleted
manifestwork.work.open-cluster-management.io "my-work-8" deleted
manifestwork.work.open-cluster-management.io "my-work-9" deleted
manifestwork.work.open-cluster-management.io "my-work-10" deleted
```

Generate 10 failed manifestworks on cluster1.

```bash
$ ./run.sh apply resource-failure.yaml 10 cluster1
manifestwork.work.open-cluster-management.io/my-fake-work-1 created
manifestwork.work.open-cluster-management.io/my-fake-work-2 created
manifestwork.work.open-cluster-management.io/my-fake-work-3 created
manifestwork.work.open-cluster-management.io/my-fake-work-4 created
manifestwork.work.open-cluster-management.io/my-fake-work-5 created
manifestwork.work.open-cluster-management.io/my-fake-work-6 created
manifestwork.work.open-cluster-management.io/my-fake-work-7 created
manifestwork.work.open-cluster-management.io/my-fake-work-8 created
manifestwork.work.open-cluster-management.io/my-fake-work-9 created
manifestwork.work.open-cluster-management.io/my-fake-work-10 created
```
