## Testing environment

1 hub + 2 managed cluster, each cluster has: 

- allocatable cpu: 15500m
- allocatable memory: 63400724Ki
- capacity cpu: 16
- capacity memory: 64551700Ki

## Testing version 

ACM 2.9

## Testing flow

Build TWO ACM 2.9 environments, each has 1 hub + 2 managed clusters, follow the testing steps in [acm-workload](https://github.com/haoqing0110/acm-workload/blob/main/README.md) to get resource usage, will get 4 groups resource usage of the managed clusters and calculate the average usage. 

## Benchmark

CPU usage (millicore) of each agent

| Component                       | idel       | 10 applications | 2 policies (each contains 3 config policy) | 100 manifestworks |
|----------------------------------|------------|-----------------|--------------------------------------------|---------------------|
| klusterlet                       | 2.0        | 1.9             | 1.9                                        | 1.9                 |
| klusterlet-agent                 | 4.2        | 4.4             | 4.1                                        | 13.2                |
| klusterlet-addon-workmgr         | 1.1        | 1.1             | 1.1                                        | 1.1                 |
| application-manager              | 2.2        | 4.6             | 2.2                                        | 2.2                 |
| klusterlet-addon-search          | 12.0       | 12.8            | 12.4                                       | 13.0                |
| config-policy-controller         | 0.9        | 1.0             | 1.0                                        | 1.0                 |
| governance-policy-framework      | 1.0        | 1.0             | 1.0                                        | 1.0                 |
| cluster-proxy-proxy-agent         | 0.5        | 0.5             | 0.5                                        | 0.5                 |
| cluster-proxy-service-proxy       | 0.1        | 0.1             | 0.1                                        | 0.1                 |
| endpoint-observability-operator   | 0.6        | 0.6             | 0.6                                        | 0.6                 |
| metrics-collector-deployment      | 0.5        | 0.6             | 0.5                                        | 0.6                 |


Memory usage (MB) of each agent

| Component                       | idel       | 10 applications | 2 policies (each contains 3 config policy) | 100 manifestworks |
|----------------------------------|------------|-----------------|--------------------------------------------|---------------------|
| klusterlet                       | 50.7       | 52.7            | 52.8                                       | 52.9                |
| klusterlet-agent                 | 71.0       | 73.2            | 72.8                                       | 78.8                |
| klusterlet-addon-workmgr         | 42.6       | 44.5            | 44.8                                       | 44.9                |
| application-manager              | 31.4       | 55.4            | 52.3                                       | 52.9                |
| klusterlet-addon-search          | 100.4      | 103.9           | 103.3                                      | 104.5               |
| config-policy-controller         | 66.1       | 68.5            | 70.4                                       | 69.6                |
| governance-policy-framework      | 60.9       | 63.7            | 69.1                                       | 68.5                |
| cluster-proxy-proxy-agent         | 33.2       | 35.4            | 35.4                                       | 35.4                |
| cluster-proxy-service-proxy       | 19.6       | 20.5            | 20.5                                       | 20.5                |
| endpoint-observability-operator   | 41.3       | 42.7            | 42.7                                       | 43.0                |
| metrics-collector-deployment      | 50.7       | 53.4            | 54.1                                       | 54.5                |
