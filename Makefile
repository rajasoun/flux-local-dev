# Flux local dev environment with Docker and Kubernetes KIND
# Requirements:
# - Docker
# - Homebrew

.DEFAULT_GOAL := help
.PHONY: help

help:  ## Display this help menu
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  ./assist.sh \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

up: install-tools cluster-up flux-push flux-up ## Create the local cluster and registry, install Flux and the cluster addons
	kubectl -n flux-system wait kustomization/cluster-sync --for=condition=ready --timeout=5m
	kubectl -n flux-system wait kustomization/apps-sync --for=condition=ready --timeout=5m

down: cluster-down uninstall-tools  ## Delete the local cluster and registry

sync: flux-push ## Build, push and reconcile the manifests
	flux reconcile ks cluster-sync --with-source
	flux reconcile ks apps-sync --with-source

check: ## Check if the NGINX ingress self-signed TLS works
	curl --insecure https://podinfo.flux.local.gd

install-tools: ## Install Kubernetes kind, kubectl, FLux CLI and other tools with Homebrew
	brew bundle

uninstall-tools: ## UnInstall Kubernetes kind, kubectl, FLux CLI and other tools with Homebrew
	fetch --repo https://github.com/rajasoun/mac-onboard --branch main --source-path /packages/Brewfile  /tmp/Brewfile 
	brew bundle --file  /tmp/Brewfile --force cleanup

validate: ## Validate the Kubernetes manifests (including Flux custom resources)
	scripts/test/validate.sh

cluster-up:
	scripts/kind/up.sh

cluster-down:
	scripts/kind/down.sh

flux-up:
	scripts/flux/up.sh

flux-down:
	scripts/flux/down.sh

flux-push:
	scripts/flux/push.sh

cue-mod:
	@cd cue && go get -u k8s.io/api/... && cue get go k8s.io/api/...

cue-gen: ## Print the CUE generated objects
	@cd cue && cue fmt ./... && cue vet --all-errors --concrete ./...
	@cd cue && cue gen

cue-ls: ## List the CUE generated objects
	@cd cue && cue ls

cue-push: ## Push the CUE generated manifests to the registry
	scripts/flux/push-cue.sh


