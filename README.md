# Wasm Workers Server supply chain on Tanzu Application Platform


## Install kwasm

```
helm repo add kwasm http://kwasm.sh/kwasm-operator/
helm upgrade --install -n kwasm --create-namespace kwasm-operator kwasm/kwasm-operator --wait
```

Enable kwasm on all node

```
for node in $(kubectl get node --context kiwi-run -ojsonpath='{.items[*].metadata.name}');do
  kubectl annotate node $node kwasm.sh/kwasm-node=true
done
```

Add RuntimeClass for wws

```
kubectl apply -f - <<EOF
apiVersion: node.k8s.io/v1
kind: RuntimeClass
metadata:
  name: wws
handler: wws
EOF
```

## Install SupplyChain

### Install Tekton Task

```
kubectl apply -f https://github.com/making/wws-supplychain/raw/main/wasm-tekton-task.yaml
```

### Install ClusterImageTemplate


```
kubectl apply -f https://github.com/making/wws-supplychain/raw/main/wws-image-template.yaml
```

### Install ClusterConfigTemplate


```
kubectl apply -f https://github.com/making/wws-supplychain/raw/main/wws-config-template.yaml
```

### Install ClusterSupplyChain


Change `registry` for your environment. `server` must be included in `registries-credentials` secret.

```
ytt -f https://github.com/making/wws-supplychain/raw/main/supply-chain-wws.yaml \
  --data-value-yaml='registry={"server":"ghcr.io", "repository":"making/wasm"}' \
  -v service_account=default \
  -v git_implementation=go-git \
  --data-value-yaml=external_delivery=false \
| kubectl apply -f- 
```

## Deploy　Workloads


### Rust

```
tanzu apps workload apply hello-wasm \
  --type wws \
  --git-repo https://github.com/vmware-labs/wasm-workers-server \
  --git-branch main \
  --sub-path examples/rust-basic \
  --app hello-wasm \
  -n demo
```


### JavaScript

```
tanzu apps workload apply hello-wasm \
  --type wws \
  --git-repo https://github.com/vmware-labs/wasm-workers-server \
  --git-branch main \
  --sub-path examples/js-basic \
  --app hello-wasm \
  -n demo
```

### Go

```
tanzu apps workload apply hello-wasm \
  --type wws \
  --git-repo https://github.com/vmware-labs/wasm-workers-server \
  --git-branch main \
  --sub-path examples/go-basic \
  --app hello-wasm \
  -n demo
```

### Java

```
tanzu apps workload apply hello-wasm \
  --type wws \
  --git-repo https://github.com/making/wws-java \
  --git-branch develop \
  --sub-path samples/hello-wasm \
  --app hello-wasm \
  -n demo
```