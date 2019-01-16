#! /bin/bash
# Make the master IP available to any subprocesses 
# If you were to run this as a startup script you could get the ip like from the metadata endpoint
# export MASTER_IP=$(curl -s http://169.254.169.254/metadata/v1/interfaces/public/0/ipv4/address)
# see here https://developers.digitalocean.com/documentation/metadata/
export MASTER_IP=$(curl -s http://169.254.169.254/metadata/v1/interfaces/public/0/ipv4/address)

apt-get update && apt-get upgrade -y

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add 

# Read all lines from the debian kubernetes repo 
# Then save them to the source file > /etc/apt/sources.list.d/kubernetes.list
# https://unix.stackexchange.com/questions/159513/what-are-the-shells-control-and-redirection-operators
cat <<EOF > /etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main  
EOF

apt-get update -y

apt-get install -y docker.io

# Install necessary kube packages
# add --allow-unauthenticated flag if you were running this as a startup script
apt-get install -y kubelet kubeadm kubectl kubernetes-cni

# Inititalize kubeadm with the ip for your master, note it will generate a token for your workers to use to join
# you could generate the token yourself and pass it manaually using --token flag, if you were running this as a startup script.
# --apiserver-advertise-address tells kubeadm the ip of the master node so we can access the api-server
kubeadm init --pod-network-cidr=10.244.0.0/16  --apiserver-advertise-address $MASTER_IP

# Next we set up a pod network using flannel, although there are a bunch of other options
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/bc79dd1505b0c8681ece4de4c0d86c5cd2643275/Documentation/kube-flannel.yml