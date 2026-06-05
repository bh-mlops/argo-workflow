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

TODO: Look at https://pipekit.io/blog/how-to-set-up-a-minio-artifact-repository-for-argo-workflows

```bash
    minio-1780696959.minio.cluster.local

To access MinIO from localhost, run the below commands:

  1. export POD_NAME=$(kubectl get pods --namespace minio -l "release=minio-1780696959" -o jsonpath="{.items[0].metadata.name}")

  2. kubectl port-forward $POD_NAME 9000 --namespace minio

Read more about port forwarding here: http://kubernetes.io/docs/user-guide/kubectl/kubectl_port-forward/

You can now access MinIO server on http://localhost:9000. Follow the below steps to connect to MinIO server with mc client:

  1. Download the MinIO mc client - https://min.io/docs/minio/linux/reference/minio-mc.html#quickstart

  2. export MC_HOST_minio-1780696959-local=http://$(kubectl get secret --namespace minio minio-1780696959 -o jsonpath="{.data.rootUser}" | base64 --decode):$(kubectl get secret --namespace minio minio-1780696959 -o jsonpath="{.data.rootPassword}" | base64 --decode)@localhost:9000
```