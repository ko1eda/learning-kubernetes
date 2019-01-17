#! /bin/bash
# Some notes and commands used to setup digital ocean storage provisioner
# https://github.com/digitalocean/csi-digitalocean

# to add the flagged features to the api server edit the manifest with
# --feature-gates=VolumeSnapshotDataSource=true,KubeletPluginsWatcher=true,CSINodeInfo=true,CSIDriverRegistry=true
/etc/kubernetes/manifests/

# to pass flags to the kublet edit
# --feature-gates=VolumeSnapshotDataSource=true,KubeletPluginsWatcher=true,CSINodeInfo=true,CSIDriverRegistry=true
vi /var/lib/kubelet/kubeadm-flags.env


# allow feature gates 
# then set MountFlags=shared
# Note resetting these should also reupdate config for the apiserver
sudo systemctl edit docker
sudo systemctl daemon-reload;
sudo systemctl restart docker

# To get features enabled by the apiserver use
ps aux | grep apiserver | grep <feature-name>

# for the kubelet
ps aux | grep kubelet | grep <feature-name>
