FROM quay.io/openshift/origin-cli:4.13 as builder
FROM registry.access.redhat.com/ubi8/ubi-minimal:latest

RUN microdnf install -y make \
    && microdnf clean all

# Copy oc binary
COPY --from=builder /usr/bin/oc /usr/bin/kubectl
COPY . /

WORKDIR /
