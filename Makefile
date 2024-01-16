SHELL :=/bin/bash
MANAGED_CLUSTER_NAME ?= cluster1
RESOUCE_COUNT ?= 10
KUBECTL ?= kubectl

test: test-klusterlet-agent test-work-mgr test-managed-service-account test-application test-obs-search test-policy

test-failure: test-klusterlet-agent-failure test-work-mgr-failure test-application-failure test-obs-search-failure

test-klusterlet-agent:
	cd klusterlet-agent && ./run.sh apply resource.yaml $(RESOUCE_COUNT) $(MANAGED_CLUSTER_NAME)

test-klusterlet-agent-failure:
	cd klusterlet-agent && ./run.sh apply resource-failure.yaml $(RESOUCE_COUNT) $(MANAGED_CLUSTER_NAME)

test-work-mgr:
	cd work-manager && ./run.sh apply resource.yaml $(RESOUCE_COUNT) $(MANAGED_CLUSTER_NAME)

test-work-mgr-failure:
	cd work-manager && ./run.sh apply resource-failure.yaml $(RESOUCE_COUNT) $(MANAGED_CLUSTER_NAME)

test-managed-service-account:
	cd managed-service-account && \
	./run.sh apply resource.yaml $(RESOUCE_COUNT) $(MANAGED_CLUSTER_NAME)

test-application:
	cd application && ./run.sh apply healthy-app-helloworld.yaml $(RESOUCE_COUNT) $(MANAGED_CLUSTER_NAME)

test-application-failure:
	cd application && ./run.sh apply unhealthy-app-nginx.yaml $(RESOUCE_COUNT) $(MANAGED_CLUSTER_NAME)

test-obs-search:
	cd klusterlet-agent && ./run.sh apply resource.yaml 100 $(MANAGED_CLUSTER_NAME)

test-obs-search-failure:
	cd klusterlet-agent && ./run.sh apply resource-failure.yaml 100 $(MANAGED_CLUSTER_NAME)

test-policy:
	cd policy && ./run.sh apply resource.yaml 2 $(MANAGED_CLUSTER_NAME)

clean-klusterlet-agent:
	cd klusterlet-agent && \
	./run.sh delete resource.yaml $(RESOUCE_COUNT) $(MANAGED_CLUSTER_NAME) || true && \
	./run.sh delete resource-failure.yaml $(RESOUCE_COUNT) $(MANAGED_CLUSTER_NAME) || true

clean-work-mgr:
	cd work-manager && \
	./run.sh delete resource.yaml $(RESOUCE_COUNT) $(MANAGED_CLUSTER_NAME) || true && \
	./run.sh delete resource-failure.yaml $(RESOUCE_COUNT) $(MANAGED_CLUSTER_NAME) || true

clean-managed-service-account:
	cd managed-service-account && \
	./run.sh delete resource.yaml $(RESOUCE_COUNT) $(MANAGED_CLUSTER_NAME) || true

clean-application:
	cd application && \
	./run.sh delete healthy-app-helloworld.yaml $(RESOUCE_COUNT) $(MANAGED_CLUSTER_NAME) || true && \
	./run.sh delete unhealthy-app-nginx.yaml $(RESOUCE_COUNT) $(MANAGED_CLUSTER_NAME) || true 

clean-obs-search:
	cd klusterlet-agent && ./run.sh delete resource.yaml 100 $(MANAGED_CLUSTER_NAME) || true

clean-policy:
	cd policy && ./run.sh delete resource.yaml 2 $(MANAGED_CLUSTER_NAME) || true

clean-all: clean-klusterlet-agent clean-work-mgr clean-managed-service-account clean-application clean-obs-search clean-policy

enable-app:
	${KUBECTL} patch klusterletaddonconfig -n ${MANAGED_CLUSTER_NAME} ${MANAGED_CLUSTER_NAME} -p='{"spec":{"applicationManager":{"enabled": true}}}' --type=merge

disable-app:
	${KUBECTL} patch klusterletaddonconfig -n ${MANAGED_CLUSTER_NAME} ${MANAGED_CLUSTER_NAME} -p='{"spec":{"applicationManager":{"enabled": false}}}' --type=merge

enable-policy:
	${KUBECTL} patch klusterletaddonconfig -n ${MANAGED_CLUSTER_NAME} ${MANAGED_CLUSTER_NAME} -p='{"spec":{"policyController":{"enabled": true}}}' --type=merge
	${KUBECTL} patch klusterletaddonconfig -n ${MANAGED_CLUSTER_NAME} ${MANAGED_CLUSTER_NAME} -p='{"spec":{"iamPolicyController":{"enabled": false}}}' --type=merge
	${KUBECTL} patch klusterletaddonconfig -n ${MANAGED_CLUSTER_NAME} ${MANAGED_CLUSTER_NAME} -p='{"spec":{"certPolicyController":{"enabled": false}}}' --type=merge

disable-policy:
	${KUBECTL} patch klusterletaddonconfig -n ${MANAGED_CLUSTER_NAME} ${MANAGED_CLUSTER_NAME} -p='{"spec":{"policyController":{"enabled": false}}}' --type=merge
	${KUBECTL} patch klusterletaddonconfig -n ${MANAGED_CLUSTER_NAME} ${MANAGED_CLUSTER_NAME} -p='{"spec":{"iamPolicyController":{"enabled": false}}}' --type=merge
	${KUBECTL} patch klusterletaddonconfig -n ${MANAGED_CLUSTER_NAME} ${MANAGED_CLUSTER_NAME} -p='{"spec":{"certPolicyController":{"enabled": false}}}' --type=merge

enable-search:
	${KUBECTL} patch klusterletaddonconfig -n ${MANAGED_CLUSTER_NAME} ${MANAGED_CLUSTER_NAME} -p='{"spec":{"searchCollector":{"enabled": true}}}' --type=merge

disable-search:
	${KUBECTL} patch klusterletaddonconfig -n ${MANAGED_CLUSTER_NAME} ${MANAGED_CLUSTER_NAME} -p='{"spec":{"searchCollector":{"enabled": false}}}' --type=merge

enable-cluster-proxy:
	${KUBECTL} patch multiclusterengine multiclusterengine -p '{"spec":{"overrides":{"components":[{"enabled":true,"name":"cluster-proxy-addon"}]}}}' --type=merge

disable-cluster-proxy:
	${KUBECTL} patch multiclusterengine multiclusterengine -p '{"spec":{"overrides":{"components":[{"enabled":false,"name":"cluster-proxy-addon"}]}}}' --type=merge

enable-app-search-obs: enable-app enable-search disable-policy disable-cluster-proxy
enable-policy-search-obs: enable-policy enable-search disable-app disable-cluster-proxy
enable-policy-proxy-obs: enable-policy enable-cluster-proxy disable-app disable-search
enable-all: enable-app enable-policy enable-search enable-cluster-proxy