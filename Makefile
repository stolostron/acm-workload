SHELL :=/bin/bash

test: test-klusterlet-agent test-work-mgr

test-failure: test-klusterlet-agent-failure test-work-mgr-failure

test-klusterlet-agent:
	cd klusterlet-agent && ./run.sh apply resource.yaml 10

test-klusterlet-agent-failure:
	cd klusterlet-agent && ./run.sh apply resource-failure.yaml 10

test-work-mgr:
	cd work-manager && ./run.sh apply resource.yaml 10

test-work-mgr-failure:
	cd work-manager && ./run.sh apply resource-failure.yaml 10

clean:
	cd klusterlet-agent && ./run.sh delete resource.yaml 10 && ./run.sh delete resource-failure.yaml 10
	cd work-manager && ./run.sh delete resource.yaml 10 && ./run.sh delete resource-failure.yaml 10
