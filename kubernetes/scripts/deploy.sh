#! /bin/bash


# prints the help menu using -h
function usage() {
    echo -e "This script provides a convienient way to deploy and remove your application to the given namespace in your cluster.\nIt can be ran in either production (-p) or development (-d) mode.\nBelow are a list of the possible flags that can be passed into the script.\nAny of the flags can be combined with the -r flag to remove the resource specifed, \nfor example -rs removes all secrets for the given namepace or -rds removes all secrets and deletes the development cluster if you had created one.\nOptions:
        -n <namespace> : the namespace to create the resources under, you must pass one in even if its default
        -r : tells the script to remove all the resources created for a given flags p, s, d or any combination 
        -s: tells the script to create all secrets for the given namespace
        -d : tells the script to run in development, i.e. only create or delete the resources in .kubernetes/app/dev
        -p : tells the script to run in production 
        -ra : this will delete the entire namespace and all resources in it
        -t <account-name> : this will get the token for the given account in the given namespace (useful for quickly getting a dashboard token)
    "
}

function handle_secrets() {
    if [ -d ./kubernetes/app/secrets/ ] 
    then
        secrets=./kubernetes/app/secrets/*
        if [ "$rflag" = true ]
        then
            for secret in $secrets
            do
                cat $secret | sed "s|{{NAMESPACE}}|$namespace|g" | kubectl delete -f -
            done
            echo "Deleted secrets for namespace $namespace"
        else
          for secret in $secrets
            do
                # this replaces any {{NAMESPACE}} variable with the namespace passed into the script
                # https://stackoverflow.com/questions/48296082/how-to-set-dynamic-values-with-kubernetes-yaml-file
                cat $secret | sed "s|{{NAMESPACE}}|$namespace|g" | kubectl apply -f -
            done
            echo -e "Applied secrets for namespace $namespace\n"
            kubectl get secrets -n $namespace
        fi
    fi
}

# apply or delete all resources in the dev folder
function handle_dev() {
    if [ -d ./kubernetes/app/dev/ ]
    then
        resources=./kubernetes/app/dev/*
        if [ "$rflag" = true ]
        then
            for resource in $resources
            do
                cat $resource | sed "s|{{NAMESPACE}}|$namespace|g" | kubectl delete -f -
            done
            echo "Deleted development resources for namespace $namespace"
        else
          for resource in $resources
            do
               cat $resource | sed "s|{{NAMESPACE}}|$namespace|g" | kubectl apply -f -
            done
            echo -e "Applied development resources for namespace $namespace\n"
            kubectl get all -n $namespace
        fi
    fi
}


# https://opensource.com/article/18/5/you-dont-know-bash-intro-bash-arrays
function handle_prod() {
    if [ -d ./kubernetes/app/pvc/ ]; then  pvc=./kubernetes/app/pvc/* ; fi
    if [ -d ./kubernetes/app/svc/ ]; then  svc=./kubernetes/app/svc/* ; fi
    if [ -d ./kubernetes/app/deployment/ ]; then dpl=./kubernetes/app/deployment/* ; fi
    # echo "$app" | sed -rn 's|(^[\w]+-(?:svc|service)\.yml$)|\1 \2/gm'

    for resource in $pvc
    do 
        if [ "$rflag"  = true ]
        then
            cat $resource | sed "s|{{NAMESPACE}}|$namespace|g" | kubectl delete -f -
        else
            echo "Provisioing pvcs..."
            cat $resource | sed "s|{{NAMESPACE}}|$namespace|g" | kubectl apply -f -
            sleep 6
        fi
    done        
 

    for resource in $svc
    do 
        if [ "$rflag"  = true ]
        then
            cat $resource | sed "s|{{NAMESPACE}}|$namespace|g" | kubectl delete -f -
        else
            echo "Provisioing svcs..."
            cat $resource | sed "s|{{NAMESPACE}}|$namespace|g" | kubectl apply -f -
            sleep 2
        fi
    done    
    
 
    for resource in $dpl
    do 
        if [ "$rflag"  = true ]
        then
            cat $resource | sed "s|{{NAMESPACE}}|$namespace|g" | kubectl delete -f -
        else
            echo "Deploying..."
            cat $resource | sed "s|{{NAMESPACE}}|$namespace|g" | kubectl apply -f -
            sleep 2
        fi
    done    
 

    # print the action taken
    if [ "$rflag"  = true ]; 
    then 
        echo "Deleted production resources for namespace $namespace"; 
    else
        echo -e "Applied production resources for namespace $namespace\n"; 
        kubectl get all -n $namespace
    fi
}

# info on getopts https://archive.is/TRzn4#selection-1491.17-1513.72
# info on mandatory flags https://stackoverflow.com/questions/11279423/bash-getopts-with-multiple-and-mandatory-options
# bash functions https://ryanstutorials.net/bash-scripting-tutorial/bash-functions.php and subshells https://unix.stackexchange.com/questions/305358/do-functions-run-as-subprocesses-in-bash
# info on switch statments https://www.thegeekstuff.com/2010/07/bash-case-statement
while getopts ":n:drahspt:x" flag; do
    case $flag in
        n) 
            namespace=$OPTARG
            nflag=true
            kubectl create namespace $OPTARG 2> /dev/null # if the namespace already exists pass the error to dev null bc it doesn't matter
            ;;
        d)
            dflag=true
            ;;
        r)
            rflag=true
            ;;
        a)
            aflag=true
            ;;
        s)
            sflag=true
            ;;
        t) 
            kubectl -n $namespace describe secret $(kubectl -n $namespace get secret | grep $OPTARG | awk '{print $1}')
            exit 0
            ;;
        p)
            pflag=true
            ;;  
        h)
            usage
            exit 0
            ;;
        x) 
            xflag=true 
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            exit 1
    esac
done

# Set debug for the script
# https://stackoverflow.com/questions/36273665/what-does-set-x-do/36273740
if [ "$xflag" = 'true' ]; then set -x; fi

# The namespace flag should be set 
if [ ! "$nflag" ] 
then
    echo "-n must be set, even if its set to default"
    exit 1
fi

# Delete all resources under the passed in namespace with -ra
if [ "$aflag" = true ] && [ "$rflag" = true ]
then
    kubectl delete namespace $namespace 
    exit 0 
fi

# Main logic 
if [ "$dflag" = true ]; then handle_dev; fi

if [ "$sflag" = true ]; then handle_secrets ; fi

# Cant use the handle_prod function because the order of svc and deployment creation matter but left it for refrence
if [ "$pflag" = true ]; then handle_prod; fi