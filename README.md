Some scripts for simplify cluster-api hacking on openshift.

## Usage
1. login to you dev cluster or set up proper kubeconfig
2. `make clone-capi-components` - clones capi components repos (lobziik's fork, openshift branch)
3. `make install` - apply capi manifests to your cluster


## Notes about [CAPI](https://github.com/lobziik/cluster-api/tree/openshift) / [CAPV](https://github.com/lobziik/cluster-api-provider-vsphere/tree/openshift) / etc manifests customization

* Cert manager deployment bypassed completely
* instead of cert manager - internal openshift mechanism for cert management used (ca-operator)
* separate namespace for webhook avoided, all namespaced stuff goes to respective namespace per component
    * openshift-cluster-api - for capi core
    * openshift-cluster-api-vsphere - for capv
    
Changes which was made agains CAPI/CAPV repos:
    * separate kustomize config, placed in `config/openshift` with necessary patches
    * separate makefile with ocp-specific targets `Makefile.openshift` in respective repo root
    
## forks used

* [CAPI](https://github.com/lobziik/cluster-api/tree/openshift)
* [CAPV](https://github.com/lobziik/cluster-api-provider-vsphere/tree/openshift)