# Experimenting with MLServer on Red Hat

## Based on the [sklearn example](https://github.com/SeldonIO/MLServer/tree/master/docs/examples/sklearn).

### Local Deployment
- RHEL 9.0
- Python 3.9.10 virtual environment

```
pip install pip jupyterlab mlserver mlserver_sklearn -U
```

#### Run Jupyter Lab
```
jupyter lab --ip=0.0.0.0
```

- Open the `README.ipynb` notebook and run the cells to train and save the SVC model.

#### Start mlserver in a separate window
```
mlserver start .
```

#### Get Prometheus metrics

```
export HOST=localhost
curl $HOST:8082/metrics
```

#### Make a request using the README.ipynb or curl
```
HOST=localhost

curl -X POST -H "Content-Type: application/json" \
	-d '{"inputs": [ { "name": "predict", "shape": [1,64], "datatype": "FP32", "data": [[0.0, 0.0, 1.0, 11.0, 14.0, 15.0, 3.0, 0.0, 0.0, 1.0, 13.0, 16.0, 12.0, 16.0, 8.0, 0.0, 0.0, 8.0, 16.0, 4.0, 6.0, 16.0, 5.0, 0.0, 0.0, 5.0, 15.0, 11.0, 13.0, 14.0, 0.0, 0.0, 0.0, 0.0, 2.0, 12.0, 16.0, 13.0, 0.0, 0.0, 0.0, 0.0, 0.0, 13.0, 16.0, 16.0, 6.0, 0.0, 0.0, 0.0, 0.0, 16.0, 16.0, 16.0, 7.0, 0.0, 0.0, 0.0, 0.0, 11.0, 13.0, 12.0, 1.0, 0.0]] } ] }' \
	${HOST}:8080/v2/models/mnist-svm/versions/v0.1.0/infer
```

Expected output:
```

{"model_name":"mnist-svm","model_version":"v0.1.0","id":"5b4368b5-6cb6-4e45-95e5-656e1bfa0c2d","parameters":{"content_type":null,"headers":null},"outputs":[{"name":"predict","shape":[1],"datatype":"INT64","parameters":null,"data":[8]}
```

### Prometheus

Edit local `prometheus.yml` and bind mount to the container.

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

- Version 4.10

#### Create a new application and wait for the mlserver pod to build and deploy.
```
oc new-app https://github.com/bkoz/mlserver-openshift
```

#### Expose the model server service.
```
oc expose service mlserver-openshift
```

#### Get the route and use it to make a request using the README.ipynb notebook or curl.
```
oc get routes mlserver-openshift
```
```
HOST=mlserver-openshift-ml-mon.apps.ocp.sandbox2395.opentlc.com
```

#### Test the model server and model health
```
curl $HOST/v2 | jq 
```
Sample output:
```
{
  "name": "mlserver",
  "version": "1.1.0",
  "extensions": []
}
```

```
curl $HOST/v2/models/mnist-svm/versions/v0.1.0 | jq .
```
Sample output:
```
{
  "name": "mnist-svm",
  "versions": [],
  "platform": "",
  "inputs": [],
  "outputs": [],
  "parameters": {
    "content_type": null,
    "headers": null
  }
}
```

#### Make a prediction request.
```

curl -X POST -H "Content-Type: application/json" \
	-d '{"inputs": [ { "name": "predict", "shape": [1,64], "datatype": "FP32", "data": [[0.0, 0.0, 1.0, 11.0, 14.0, 15.0, 3.0, 0.0, 0.0, 1.0, 13.0, 16.0, 12.0, 16.0, 8.0, 0.0, 0.0, 8.0, 16.0, 4.0, 6.0, 16.0, 5.0, 0.0, 0.0, 5.0, 15.0, 11.0, 13.0, 14.0, 0.0, 0.0, 0.0, 0.0, 2.0, 12.0, 16.0, 13.0, 0.0, 0.0, 0.0, 0.0, 0.0, 13.0, 16.0, 16.0, 6.0, 0.0, 0.0, 0.0, 0.0, 16.0, 16.0, 16.0, 7.0, 0.0, 0.0, 0.0, 0.0, 11.0, 13.0, 12.0, 1.0, 0.0]] } ] }' \
	${HOST}/v2/models/mnist-svm/versions/v0.1.0/infer | jq
```

Sample output:
```
{
  "model_name": "mnist-svm",
  "model_version": "v0.1.0",
  "id": "0f71dfbf-829a-4f0f-abcd-960a98eeb44e",
  "parameters": {
    "content_type": null,
    "headers": null
  },
  "outputs": [
    {
      "name": "predict",
      "shape": [
        1
      ],
      "datatype": "INT64",
      "parameters": null,
      "data": [
        8
      ]
    }
  ]
}
```

### Setup Prometheus and Grafana

#### Install the operators

#### Create a Prometheus service monitor

#### Create a Grafana Dashboard


