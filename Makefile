SHELL := /bin/bash

IMAGE ?= ghcr.io/correctroadh/opentoggl:local
K8S_DIR ?= k8s/local
K8S_NAMESPACE ?= opentoggl-local

.PHONY: help k8s-build k8s-apply k8s-set-image k8s-rollout k8s-deploy k8s-delete k8s-port-forward

help:
	@echo "OpenToggl Kubernetes targets"
	@echo "  make k8s-build                       Build local image ($(IMAGE))"
	@echo "  make k8s-apply                       Apply manifests in $(K8S_DIR)"
	@echo "  make k8s-set-image IMAGE=<image>     Set deployment image"
	@echo "  make k8s-rollout                     Wait for rollouts"
	@echo "  make k8s-deploy IMAGE=<image>        Apply + set image + rollout"
	@echo "  make k8s-delete                      Delete manifests in $(K8S_DIR)"
	@echo "  make k8s-port-forward                Forward local 8080 -> service/opentoggl:8080"

k8s-build:
	docker build -t $(IMAGE) .

k8s-apply:
	kubectl apply -k $(K8S_DIR)

k8s-set-image:
	kubectl -n $(K8S_NAMESPACE) set image deployment/opentoggl opentoggl=$(IMAGE)

k8s-rollout:
	kubectl -n $(K8S_NAMESPACE) rollout status deploy/postgres
	kubectl -n $(K8S_NAMESPACE) rollout status deploy/redis
	kubectl -n $(K8S_NAMESPACE) rollout status deploy/opentoggl

k8s-deploy: k8s-apply k8s-set-image k8s-rollout

k8s-delete:
	kubectl delete -k $(K8S_DIR)

k8s-port-forward:
	kubectl -n $(K8S_NAMESPACE) port-forward svc/opentoggl 8080:8080
