SHELL :=/bin/bash
MANAGED_CLUSTER_NAME ?= cluster1
RESOUCE_COUNT ?= 10

test: test-klusterlet-agent test-work-mgr test-managed-service-account

test-failure: test-klusterlet-agent-failure test-work-mgr-failure

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

clean-all: clean-klusterlet-agent clean-work-mgr clean-managed-service-account
