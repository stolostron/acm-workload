### Usage

Generate 10 manifestworks on cluster1.

```bash
➜  klusterlet-agent git:(main) ✗ ./run.sh resource.yaml 10
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

Generate 10 failed manifestworks on cluster1.

```bash
$./run.sh resource-failure.yaml 10
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
