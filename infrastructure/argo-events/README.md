# Argo events

https://argoproj.github.io/argo-events/quick_start/

```bash
kubectl create namespace argo-events
kubectl -n argo-events apply -f https://raw.githubusercontent.com/argoproj/argo-events/stable/manifests/install.yaml

# Install with a validating admission controller
kubectl apply -f https://raw.githubusercontent.com/argoproj/argo-events/stable/manifests/install-validating-webhook.yaml

# install event bus
kubectl apply -n argo-events -f https://raw.githubusercontent.com/argoproj/argo-events/stable/examples/eventbus/native.yaml
```