# Experimenting with MLServer on Red Hat

## Local Deployment
- RHEL 9.0
- Python 3.9.10 virtual environment

```
pip install pip jupyterlab mlserver mlserver_sklearn -U
```

### MLServer

git clone https://github.com/SeldonIO/MLServer.git

cd MLServer/docs/examples/sklearn

#### Run Jupyter Lab
```
jupyter lab --ip=0.0.0.0
```

#### Start mlserver in a separate window
```
mlserver start .
```

#### Get Prometheus metrics

```
export HOST=ec2-3-145-152-17.us-east-2.compute.amazonaws.com
curl $HOST:8082/metrics
```

#### Make a request using the README.ipynb or curl
```
curl -X POST -H "Content-Type: application/json" -d '{"inputs": [ { "name": "predict", "shape [1,64], "datatype": "FP32", "data": [[0.0, 0.0, 1.0, 11.0, 14.0, 15.0, 3.0, 0.0, 0.0, 1.0, 13.0, 16.0, 12.0, 16.0, 8.0, 0.0, 0.0, 8.0, 16.0, 4.0, 6.0, 16.0, 5.0, 0.0, 0.0, 5.0, 15.0, 11.0, 13.0, 14.0, 0.0, 0.0, 0.0, 0.0, 2.0, 12.0, 16.0, 13.0, 0.0, 0.0, 0.0, 0.0, 0.0, 13.0, 16.0, 16.0, 6.0, 0.0, 0.0, 0.0, 0.0, 16.0, 16.0, 16.0, 7.0, 0.0, 0.0, 0.0, 0.0, 11.0, 13.0, 12.0, 1.0, 0.0]] } ] }' ${HOST}:8080/v2/models/mnist-svm/versions/v0.1.0/infer


{"model_name":"mnist-svm","model_version":"v0.1.0","id":"5b4368b5-6cb6-4e45-95e5-656e1bfa0c2d","parameters":{"content_type":null,"headers":null},"outputs":[{"name":"predict","shape":[1],"datatype":"INT64","parameters":null,"data":[8]}
```

### Prometheus

Edit local prometheus.yml and bind mount to the container.

Fix SELinux context so bind mount will work
```
chcon -R system_u:object_r:container_file_t:s0 shared
```

```
podman run --name=prometheus -d -p 9090:9090 -v /home/ec2-user/shared/prometheus.yml:/opt/bitnami/prometheus/conf/prometheus.yml bitnami/prometheus
```

### Grafana
```
podman run --name=grafana -it -p 8300:3000 bitnami/grafana
```

### Openshift

