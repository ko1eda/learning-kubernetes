# Notes I took while setting up my first self-managed Kubernetes cluster
> Note: I have included a deploy script in ./kubernetes/scripts that can be used to easily build and tear down your cluster based on the flags that you pass into it. Checkout the readme file in that directory.

.
.
.

## Setting up Kubernetes on Digital Ocean using Kubeadm
## Requirements for kubeadm
+ One or more machines running a deb/rpm-compatible OS, for example Ubuntu or CentOS
+ 2 GB or more of RAM per machine. Any less leaves little room for your apps.
+ 2 CPUs or more on the master
+ Full network connectivity among all machines in the cluster. A public or private network is fine.


## Kubernetes commands cheat sheet
+ https://kubernetes.io/docs/reference/kubectl/cheatsheet/

---
## Video tutorial
https://www.youtube.com/watch?v=C8gq5hUWC0g

## Written tutorial
+ https://thenewstack.io/tutorial-run-multi-node-kubernetes-cluster-digitalocean/
+ this one is more up to date and official https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/ 



## Imperative commands vs imperative object configuration [link](https://kubernetes.io/docs/concepts/overview/object-management-kubectl/overview/#declarative-object-configuration)
### Imperative think 'can I have this resoruce, or can you create this for me'
### Declartive think 'this is the resource I want, make it happen'

### __important__ kubectl apply vs kubectl create [link](https://stackoverflow.com/questions/52500442/difference-between-kubectl-apply-and-kubectl-create)
+ create is a imperative (think verbs) and apply is declarative (because we don't specifcy an action only a target state we want -- like react react is a declarative framework, we specificy the state of the application and it gives it to us)
+ apply applies a configuration to a resource, and if that resource is not created it will create it.
+ you can run apply on the same resource and you will not get an error, if the config changes, apply will apply those changes to the resource, if not nothing will be changed
+ you can only create a resource once in the same namespce, so you cannot run create more than once for a give resoruce



## Setting up kube dashboard 
+ https://github.com/kubernetes/dashboard 
+ https://www.youtube.com/watch?v=aB0TagEzTAw
+ installation 

``` kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v1.10.1/src/deploy/recommended/kubernetes-dashboard.yaml ```

+ Access control for dashboard (permissions and settings for how users authenticate to the kubeapiserver throught the dasboard) https://github.com/kubernetes/dashboard/wiki/Access-control

### Errors 
> Not enough data to create auth info structure. https://github.com/kubernetes/dashboard/issues/2474#issuecomment-348912376
+ This is because by default no one has admin privlages when first accessing the dashboard (this is new to v1.7x I believe)
+ See https://github.com/kubernetes/dashboard/wiki/Access-control

> anonymous user error

A: WAS USING THE WRONG  apiversion to authenticate, the endpoints changed in a recent update of kubernetes
 ```
NOTE: apiVersion of ClusterRoleBinding resource may differ between Kubernetes versions. Prior to Kubernetes v1.8 the apiVersion was rbac.authorization.k8s.io/v1beta1 https://github.com/kubernetes/dashboard/wiki/Creating-sample-user
 ```


### Service Accounts [link](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/)
+ By default programs like kubeadm set up an admin service account which we can then bind to the dashboard service so that we can access it 
### ClusterRoles [link](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)
+ Roles and cluster roles are permissions for a user defined either in a single namespace(role) or throughout the cluster(clusterRole)
+ They control access to resources and endpoints in kubernetes and they are additive (if you don't define a permission then you don't have that permission)



### Kube admin config [link](https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/#optional-controlling-your-cluster-from-machines-other-than-the-master)
+ Any user who has access to this config can access your kubecluster as a superuser so this should be given out sparingly, it is better to make less privlaged accounts and whitelist the privlages you want the user to have 



## Getting persistent storage to work with digital ocean
+ Main tutorial I used https://github.com/digitalocean/csi-digitalocean
+ Notes on privlaged contaienrs https://stackoverflow.com/questions/36425230/privileged-containers-and-capabilities
+ Notes on editing the config files https://kubernetes.io/docs/setup/independent/kubelet-integration/
+ Notes on mount propegation https://kubernetes.io/docs/concepts/storage/volumes/#mount-propagation
+ https://success.docker.com/article/using-systemd-to-control-the-docker-daemon
+ indepth info on what mount propegation https://medium.com/kokster/kubernetes-mount-propagation-5306c36a4a2d
+ Notes on how to edit the files https://github.com/kubernetes/kubernetes/issues/34915
+ https://stackoverflow.com/questions/50007654/how-does-kube-apiserver-restart-after-editing-etc-kubernetes-manifests-kube-api
## Issues
Currently digital oceans driver does not support attaching to existing PersistentVolumes
+ https://github.com/digitalocean/csi-digitalocean/issues/85

## Useful info about volumes
To restrict and control the permissions for volumes as well as control the PID of a running contianer you can use securityContext objects
+ fsgroups work on volume perissions and runAsUser controls the PID of the running containers
    + https://kubernetes.io/docs/tasks/configure-pod-container/security-context/
    + https://stackoverflow.com/questions/43544370/kubernetes-how-to-set-volumemount-user-group-and-file-permissions

## Kube deployments READ ALL OF THIS [link](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
## Secrets
+ Info about creating secrets here https://kubernetes.io/docs/concepts/configuration/secret/#creating-a-secret-manually
+ Here https://kubernetes.io/docs/concepts/containers/images/#specifying-imagepullsecrets-on-a-pod
+ And heree https://vix.digital/insights/how-get-kubernetes-pulling-private-gitlab-container-registry/
+ Troubleshooting here : https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/
## Errors with secrets 
+ icompatible format from docker config causing errors when logging in to gitlab registry
+ https://gitlab.com/gitlab-com/support-forum/issues/2824

> Solution: The error was occuring because I had created the secret in the default namespace, but the service (the deployment) was trying to access the secret from the test namespace, by moving the secret to the test namespace it was able to access it https://stackoverflow.com/questions/46297949/kubernetes-sharing-secret-across-namespaces
+ Note: You can attach a secret to a service so that any pods that are mapped to that service can use those secrets without havint oe xplicitly define them see 




## DNS and Kubernetes
+ https://www.digitalocean.com/community/tutorials/an-introduction-to-the-kubernetes-dns-service
+ https://coredns.io/2018/01/29/deploying-kubernetes-with-coredns-using-kubeadm/
+ troubleshooting dns https://kubernetes.io/docs/tasks/administer-cluster/dns-debugging-resolution/




## Setting up mysql
### Errors
There seems to be an issue with the default container not allowing connections for the IP's of the node by defaut
to change this I think you could allow connections from laravel-svc (and it should resolve to the IP address of the correct pods)
```
SQLSTATE[HY000] [1045] Access denied for user 'test_user'@'10.244.1.175' (using password: YES) (SQL: select * from `users`)
```
> Solution: This turned out to be an error with the the base64 encoded secrets, mysql was not reading from the environment variables, changed by using stringData https://stackoverflow.com/questions/45650044/cant-connect-to-mysql-pod-in-kubernetes-when-using-secrets-for-password-access

Mysql cannot initialize if its storage directory already has files in it you can specifically disable this (because most ext4 disks have a lost+found directory by default)
> Solution: https://github.com/docker-library/mysql/issues/186


## Assigning Pods to specific nodes 
Taints make it so that pods will avoid tainted nodes unless their toleration allows them to be scheduled on them, this is usefule if you want to restrict a certain node to only certain types of containers (like a database or something)
+ https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/
Node selectors say that pods will be scheduled on nodes that match specific labels that you define 
+ https://kubernetes.io/docs/concepts/configuration/assign-pod-node/ 



## Setting up a distributed redis cluster 
+ https://redis.io/topics/cluster-tutorial



## Safely shutting down kube master
+ https://serverfault.com/questions/893886/proper-shutdown-of-a-kubernetes-cluster



## General Errors and solutions
> The connection to the server localhost:8080 was refused - did you specify the right host or port? https://github.com/kubernetes/kubernetes/issues/23726

Using the server flag for the command seems to work 
```
kubectl --server=<ip-of-master-node> get nodes
```

> Troubleshooting pods https://kubernetes.io/docs/tasks/debug-application-cluster/debug-pod-replication-controller/



## Setting up kubernetes for docker
+ exposing a service on localhost https://medium.com/@lizrice/accessing-an-application-on-kubernetes-in-docker-1054d46b64b1
+ setting up dashboard https://medium.com/slalom-technology/get-kubernetes-running-locally-on-osx-and-windows-b3b5f176b5bb
+ To access a service on your local host you would enter the command below, this will direct all traffic to the correct internal service and port
``` localhost:<node-port> ```


## Other useful info
What is a bridge network?
https://www.ibm.com/support/knowledgecenter/en/linuxonibm/liaag/wkvm/wkvm_c_net_bridge.htm

Iptables in linux
+ https://www.youtube.com/watch?v=XKfhOQWrUVw


## Digital Ocean useful info
Powering off droplet from shell 

``` shutdown -h now ```

> Note: you will be charged for a droplet that is shutdown, to avoid charges save a snapshot of that droplet and delete it, then restore from the snapshot. https://www.digitalocean.com/community/questions/will-i-still-be-charged-if-i-power-off-my-droplet

### Info about user data when intiializing a server (think aws)
https://www.digitalocean.com/community/tutorials/an-introduction-to-cloud-config-scripting