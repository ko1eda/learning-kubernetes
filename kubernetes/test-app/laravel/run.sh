#! /bin/bash

# prints the help menu using -h
function help_menu() {
    echo -e "By default this script will run any yml file in this directory that is not a -dev resource, you can change this behavior by using the below flags. \n
        -n <namespace> : the namespace to create the resources under, you must pass one in even if its default
        -r : tells the script to remove all the resources it created
        -d : tells the script to run in development, i.e. only create or delete the resources that have -dev in them
        -ra : this will delete the entire namespace and all resources in it
    "
}

# info on getopts https://archive.is/TRzn4#selection-1491.17-1513.72
# info on mandatory flags https://stackoverflow.com/questions/11279423/bash-getopts-with-multiple-and-mandatory-options
# bash functions https://ryanstutorials.net/bash-scripting-tutorial/bash-functions.php
# info on switch statments https://www.thegeekstuff.com/2010/07/bash-case-statement
while getopts ":n:drah" flag; do
    case $flag in
        n) 
            namespace=$OPTARG
            nflag=true
            kubectl create namespace $OPTARG 2> /dev/null # if the namespace already exists pass the error to dev null bc it doesn't matter
            ;;
        d)
            env=development
            ;;
        r)
            remove=true
            ;;
        a)
            removeall=true
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
if [ "$removeall" = true ] && [ "$remove" = true ] && [ "$namespace" ]
then
    kubectl delete namespace $namespace 
    exit 1 
fi


if [ "$env" = 'development' ]
then 
    if [ "$remove" = true ] 
        then 
            kubectl delete -f ./kubernetes/test-app/laravel/laravel-service-dev.yml
            kubectl delete -f ./kubernetes/test-app/laravel/laravel-deployment-dev.yml
            echo "deleted development resources for namespace $namespace"
        else 
            kubectl apply -f ./kubernetes/test-app/laravel/laravel-service-dev.yml
            kubectl apply -f ./kubernetes/test-app/laravel/laravel-deployment-dev.yml
            echo "created development resources for namespace $namespace"
    fi
else
    if [ "$remove" = true ] 
        then
            kubectl delete -f ./kubernetes/test-app/laravel/laravel-service.yml
            kubectl delete -f ./kubernetes/test-appl/laravel/laravel-deployment.yml
            echo "deleted production resources for namespace $namespace"
        else
            kubectl apply -f ./kubernetes/test-app/laravel/laravel-service.yml
            kubectl apply -f ./kubernetes/test-appl/laravel/laravel-deployment.yml
            echo "created production resources for namespace $namespace"
    fi
fi
