#! /bin/bash

# create a new namespace to run this deployment in
# when a namespace is created it creates a default service account for that namespace,
# by default any resources running under that namespace use this default service account which has acces to all facets of the API
# https://kubernetes.io/docs/reference/access-authn-authz/authorization/#authorization-modules
kubectl create namespace app-example

# this auth helper can be used to see what permissins the currently logged in user has 
kubectl auth can-i create deployments --namespace test

# you can also use the as user flag to impersonate a users permissions for that given namespace
kubectl auth can-i list secrets --namespace test --as dave

# exec into a running pods container
kubectl exec -n test laravel-deployment-f4c5f64d-c5lvt -c php-fpm -it -- bash

# to get the logs for a failing container
kubectl logs -n test <deployment-name> -c <container-name>

# to edit your deployment (note this will open an editor window where you can change config settings)
# this also leaves a record of any config changes should you need to rollback the config 
# note that a revision is created ONLY if you update the spec.template fields of your deployment https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#rolling-back-a-deployment
kubectl edit -n test deployment.v1.apps/laravel-deployment --record

# you could also annotate the change you made by using 
kubectl annotate -n test deployment.v1.apps/laravel-deployment kubernetes.io/change-cause="image updated to 1.0.1"

# to get the status of your deployment as it is updating
kubectl rollout status -n test deployment.v1.apps/laravel-deployment

# to get the history of the updates to your deployment
$ kubectl rollout history -n test deployment.v1.apps/laravel-deployment

# When your done delete the namespace, this should delete the associated resources
kubectl delete namespace app-example