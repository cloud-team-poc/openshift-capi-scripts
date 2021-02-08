.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
OPENSHIFT_BRANCH=openshift
CAPI_CORE_REF=git@github.com:lobziik/cluster-api.git
CAPV_REF=git@github.com:lobziik/cluster-api-provider-vsphere.git

clone-capi-components: ## clone capi components into capi-components dir
	git clone -b $(OPENSHIFT_BRANCH) $(CAPI_CORE_REF) capi-components/cluster-api
	git clone -b $(OPENSHIFT_BRANCH) $(CAPV_REF) capi-components/cluster-api-provider-vsphere

upd-capi-components: ## update capi components code
	git -C capi-components/cluster-api pull
	git -C capi-components/cluster-api-provider-vsphere pull

ocp-manifests-capi-core:
	cd $(ROOT_DIR)
	cd capi-components/cluster-api && $(MAKE) ocp-manifests -f Makefile.openshift && cp out/openshift/core-components.yaml $(ROOT_DIR)/capi-manifests/capi-core.yaml

ocp-manifests-capv:
	cd $(ROOT_DIR)
	cd capi-components/cluster-api-provider-vsphere && $(MAKE) ocp-manifests -f Makefile.openshift && cp out/openshift/infrastructure-components.yaml $(ROOT_DIR)/capi-manifests/capv.yaml

ocp-manifests: upd-capi-components ocp-manifests-capi-core ocp-manifests-capv  ## generate capi manifests for ocp

scale-down-cvo-mao: ## disable cvo and mao
	oc scale --replicas=0 deploy/cluster-version-operator -n openshift-cluster-version
	oc scale --replicas=0 deployment/machine-api-operator -n openshift-machine-api
	oc scale --replicas=0 deployment/machine-api-controllers -n openshift-machine-api
	oc scale --replicas=0 deployment/cluster-baremetal-operator -n openshift-machine-api

install: ocp-manifests scale-down-cvo-mao ## install capi manifests onto your cluster
	 kubectl apply -f capi-manifests/capi-core.yaml
	 kubectl apply -f capi-manifests/capv.yaml