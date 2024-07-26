# Terraform configs for creation of K8s clusters in AWS and Azure.

On clusters deployed this helm chart: https://artifacthub.io/packages/helm/cloudecho/hello

Command for helm deploy:

`helm install my-hello cloudecho/hello -n default --version=0.1.2 --set service.type=LoadBalancer`

Separate creation of LoadBalancer was not required becasue i use K8S LoadBalancer service type, which is handling it automatically.