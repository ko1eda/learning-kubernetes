#! /bin/bash

kubectl create namespace test

if [ "$env" = 'development' ];
    then
        kubectl apply -f ./kubernetes/test-app/laravel/laravel-service-dev.yml
        kubectl apply -f ./kubernetes/test-app/laravel/laravel-deployment-dev.yml
    else
        kubectl apply -f ./kubernetes/test-app/laravel/laravel-service.yml
        kubectl apply -f ./kubernetes/test-appl/laravel/laravel-deployment.yml
fi