### Usage

#### healthy apps on cluster1

##### deploy 10 healthy apps on cluster1
```
go to hub cluster
% ./run.sh apply healthy-app-helloworld.yaml 10 cluster1
```

##### check one healthy app status on cluster1
```
go to cluster1
% oc get appsubstatus -n app1 helloworld-app-subscription -o yaml
```

##### remove 10 healthy apps from cluster1
```
go to hub cluster
% oc delete -f _output/healthy-app-helloworld.yaml
```

#### unhealthy apps on cluster1

##### deploy 10 unhealthy apps on cluster1
```
go to hub cluster
% ./run.sh apply unhealthy-app-nginx.yaml 10 cluster1
```

##### check one unhealthy app status on cluster1
```
go to cluster1
% oc get deployments -n app1
NAME                                  READY   UP-TO-DATE   AVAILABLE   AGE
nginx-ingress-6166b-controller        0/1     0            0           3m4s
nginx-ingress-6166b-default-backend   0/1     0            0           3m4s
```

##### remove 10 unhealthy apps from cluster1
```
go to hub cluster
% oc delete -f _output/unhealthy-app-nginx.yaml
```
