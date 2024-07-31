# Terraform configs for creation of K8s clusters in AWS and Azure.

## Azure needed info:


### Add-on:

https://learn.microsoft.com/en-us/azure/application-gateway/tutorial-ingress-controller-add-on-existing

### Helm

https://learn.microsoft.com/en-us/azure/application-gateway/ingress-controller-install-new


## AWS needed info:

https://docs.aws.amazon.com/eks/latest/userguide/lbc-helm.html


## Hello world application:



On clusters deployed this helm chart: https://artifacthub.io/packages/helm/cloudecho/hello

Command for helm deploy:

`helm install my-hello cloudecho/hello -n default --version=0.1.2 -f helloapp/values-{cloud}.yaml`

Separate creation of LoadBalancer was not required becasue i use K8S LoadBalancer service type, which is handling it automatically.