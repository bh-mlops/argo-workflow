# argo-workflow
learning argo workflow orchestration with different storage options for unpacking and tracking compressed datasets. There are a bunch of open datasets to work on.

The main objectives will eventually achieve are the following:
- Put values into iceberg
- Put values into postgres
- Argo Workflow uncompresses a dataset adds it to both postgres and iceberg

# Getting started

## Run Kubernetes locally

At the moment running a 5 node Kubernetes cluster using Docker Desktop. Using K9s to monitor the cluster

## Argo workflow
For this project, used the argo workflow quick start deployment that comes with minio( opensource variant of S3 object storage )

### Setup

```
kubectl create namespace argo
kubectl apply --server-side -n argo -f "https://github.com/argoproj/argo-workflows/releases/download/v4.0.5/quick-start-minimal.yaml"
```
After running that command you should see the following services for argo spin up.

```
➜  trino-helm git:(main) kubectl get svc -n argo
NAME          TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)             AGE
argo-server   ClusterIP   10.96.146.175   <none>        2746/TCP            10d
httpbin       ClusterIP   10.96.216.219   <none>        9100/TCP            10d
minio         ClusterIP   10.96.202.37    <none>        9000/TCP,9001/TCP   10d
➜  trino-helm git:(main) ✗
```

port forward the argo-server and minio. Normally create a background process for this.

```
nohup kubectl --namespace argo port-forward svc/minio 9001:9001 &
nohup kubectl --namespace argo port-forward svc/argo-server 2746:2746 &
```

Should be able to access now argo workflow locally at https://localhost:2746

### Upload the pipeline(WIP)
At the the time of this writing, the unpack-pipeline.yaml is pipeline going to working with. For easy uploading going to be using the [Argo CLI](https://github.com/argoproj/argo-workflows/releases/) to upload the pipeline

```
argo submit -n argo unpack-pipeline.yaml
```

![argo-workflow](argo-workflow.png)

Click on the running the job and should see that it succeeded.

![argo-workflow-test-run](argo-workflow-test-run.png)

## Datastores(WIP)

For this project, is going to be learning how to store the uncompressed object paths in different data stores to get to know which will be more performant.

### Iceberg
There will be 3 different types of tech that will be used to access the data.

#### Minio

Minio( Open source of S3 object storage ) - This came part of the argo workflow stack since it uses at a temporary storage backing.

To access the console

``` bash
  # port forward command to access console
  kubectl port-forward service/minio 9001:9001 -n argo

  # commands to get the user name and password for console
  kubectl get secret my-minio-cred -n argo -o jsonpath='{.data.accesskey}' | base64 --decode\n
  kubectl get secret my-minio-cred -n argo -o jsonpath='{.data.secretkey}' | base64 --decode\n
```
Create a bucket called iceberg( it can be any name you want )

### Nessie
Use Nessie as a iceberg catalog.

``` bash
# create the namespace
kubectl create namespace nessie-ns

# install the nessie helm chart
helm repo add nessie-helm https://charts.projectnessie.org
helm repo update

helm install -n nessie-ns nessie nessie-helm/nessie
```

### Trino
Pull down their helm chart and setup the values.yaml using the example in the infrastructure folder

``` bash
# setup the namespace
kubectl create namespace trino

# pull down the chart
helm repo add trino https://trinodb.github.io/charts

# install the chart with the values file. Note would recommend to create a values-local.yaml for testing
helm install example-trino-cluster trino/trino -f infrastructure/iceberg/trino-helm/values.yaml
```
After the chart gets deployed, it will setup the iceberg.properties file within the trino pod( trino/example-trino-cluster-trino-coordinator )

```bash
    [trino@example-trino-cluster-trino-coordinator-7949776fbc-t5zcm /]$ cd /etc/trino/catalog/
[trino@example-trino-cluster-trino-coordinator-7949776fbc-t5zcm catalog]$ ls -al
total 12
drwxrwxrwx 3 root root 4096 May 29 02:12 .
drwxrwxrwx 5 root root 4096 May 29 02:12 ..
drwxr-xr-x 2 root root 4096 May 29 02:12 ..2026_05_29_02_12_36.396138654
lrwxrwxrwx 1 root root   31 May 29 02:12 ..data -> ..2026_05_29_02_12_36.396138654
lrwxrwxrwx 1 root root   25 May 29 02:12 iceberg.properties -> ..data/iceberg.properties
lrwxrwxrwx 1 root root   23 May 29 02:12 tpcds.properties -> ..data/tpcds.properties
lrwxrwxrwx 1 root root   22 May 29 02:12 tpch.properties -> ..data/tpch.properties
```
To access trino, you would need a trino client. Install the latest version of java. See [Trino CLI Documentation](https://trino.io/docs/current/client/cli.html)

### Iceberg table example

```bash

    # create schema
    CREATE SCHEMA iceberg.logging WITH (location = 's3a://iceberg/'); 

    # creates table
    CREATE TABLE iceberg.logging.events (
    ->     level VARCHAR,
    ->     event_time TIMESTAMP(6),
    ->     message VARCHAR,
    ->     call_stack ARRAY(VARCHAR)
    -> )
    -> WITH (
    ->     format = 'PARQUET', -- Storage format (PARQUET, ORC, or AVRO)
    ->     partitioning = ARRAY['day(event_time)'], -- Partition by day automatically
    ->     location = 's3a://iceberg/');
```