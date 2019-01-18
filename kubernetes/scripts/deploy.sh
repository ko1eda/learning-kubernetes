#! /bin/bash

# prints the help menu using -h
function help_menu() {
    echo -e "By default this script will run any yaml file in the ./kubernetes/app directory that does not have a name of *-dev.yml \nYou can change this behavior by using the flags below:\n
        -n <namespace> : the namespace to create the resources under, you must pass one in even if its default
        -r : tells the script to remove all the resources created for a given flags p, s, d or any combination 
        -s: tells the script to create all secretes for the given namespace
        -d : tells the script to run in development, i.e. only create or delete the resources in .kubernetes/app/dev
        -p : tells the script to run in production 
        -ra : this will delete the entire namespace and all resources in it
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
                kubectl delete -f  $secret
            done
            echo -e "Deleted secrets for namespace $namespace\n"
        else
          for secret in $secrets
            do
                kubectl apply -f $secret
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
                kubectl delete -f $resource
            done
            echo -e "Deleted development resources for namespace $namespace\n"
        else
          for resource in $resources
            do
               kubectl apply -f $resource
            done
            echo -e "Applied development resources for namespace $namespace\n"
            kubectl get all -n $namespace
        fi
    fi
}

# info on getopts https://archive.is/TRzn4#selection-1491.17-1513.72
# info on mandatory flags https://stackoverflow.com/questions/11279423/bash-getopts-with-multiple-and-mandatory-options
# bash functions https://ryanstutorials.net/bash-scripting-tutorial/bash-functions.php and subshells https://unix.stackexchange.com/questions/305358/do-functions-run-as-subprocesses-in-bash
# info on switch statments https://www.thegeekstuff.com/2010/07/bash-case-statement
while getopts ":n:drahsp" flag; do
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
        s)
            pflag=true
            ;;
        h)
            help_menu
            exit 1
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
    exit 1 
fi

# Main logic 
if [ "$dflag" = true ]; then handle_dev; fi

if [ "$sflag" = true ]; then handle_secrets ; fi

# Cant use the handle_prod function because the order of svc and deployment creation matter but left it for refrence
if [ "$pflag" = true ]
then 
    if [ "$rflag" = true ] 
    then
        kubectl delete -f ./kubernetes/app/pvc/50gi-claim.yml
        kubectl delete -f ./kubernetes/app/laravel/laravel-svc.yml
        kubectl delete -f ./kubernetes/app/laravel/laravel-deployment.yml
        kubectl delete -f ./kubernetes/app/mysql/mysql-svc.yml
        kubectl delete -f ./kubernetes/app/mysql/mysql-deployment.yml
        echo -e  "Deleted production resources for namespace $namespace\n"; 
    else 
        kubectl apply -f ./kubernetes/app/pvc/50gi-claim.yml
        kubectl apply -f ./kubernetes/app/laravel/laravel-svc.yml
        kubectl apply -f ./kubernetes/app/laravel/laravel-deployment.yml
        kubectl apply -f ./kubernetes/app/mysql/mysql-svc.yml
        kubectl apply -f ./kubernetes/app/mysql/mysql-deployment.yml
        echo -e "Applied production resources for namespace $namespace\n"
        kubectl get all -n $namespace
    fi
fi


# https://opensource.com/article/18/5/you-dont-know-bash-intro-bash-arrays
# function handle_prod() {
#     if [ -d ./kubernetes/app/laravel/ ]; then app=./kubernetes/app/laravel/* ; fi
#     if [ -d ./kubernetes/app/mysql/ ]; then  db=./kubernetes/app/mysql/* ; fi
#     if [ -d ./kubernetes/app/pvc/ ]; then  pvc=./kubernetes/app/pvc/* ; fi
    
#    for resource in $pvc
#     do 
#         if [ "$rflag"  = true ]
#         then
#             echo "delete $resource"
#         else
#             echo "add $resource"
#         fi
#     done        


#     for resource in $app
#     do 
#         if [ "$rflag"  = true ]
#         then
#             echo "delete $resource"
#         else
#             echo "add $resource"
#         fi
#     done    

#     for resource in $db
#     do 
#         if [ "$rflag"  = true ]
#         then
#             echo "delete $resource"
#         else
#             echo "add $resource"
#         fi
#     done    

#     # print the action taken
#     if [ "$rflag"  = true ]; 
#     then 
#         echo "Deleted production resources for namespace $namespace"; 
#     else
#         echo "Applied production resources for namespace $namespace"; 
#     fi
# }