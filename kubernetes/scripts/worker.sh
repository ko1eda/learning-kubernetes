#! /bin/bash

#run this in user-data section when provisioning new nodes 
apt-get update && apt-get upgrade -y

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add 

cat <<EOF > /etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main  
EOF

apt-get update -y

apt-get install -y docker.io

# Install necessary kube programs
apt-get install -y kubelet kubeadm kubectl kubernetes-cni

# join the cluster and connect to the master node 
# note you can create a new token if the old one expires using kubeadm create token --print-join-command
kubeadm join 157.230.61.20:6443 --token nfu0c5.c2bgo1saky64xsdq --discovery-token-ca-cert-hash sha256:3928d90e4869aa9ad860855c7460e1de5bb16b7106972c0373af9e462dd59a80
