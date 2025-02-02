#!/bin/sh

# Remove all Docker containers
function dcnuke() {
    echo "Running: docker rm --force $(docker ps -aq)"
    docker rm --force $(docker ps -aq)
}

function docker-container-rm-all(){
    docker ps -aq | xargs docker container rm --force
}

function docker-container-stop-all(){
    docker ps -aq | xargs docker container stop
}

function docker-images-rm-all(){
    docker images -aq | xargs docker rmi --force
}

function docker-hard-reset(){
    echo "Running: sudo systemctl restart docker docker.socket"
    sudo systemctl restart docker docker.socket
}

function docker-full-cleanup(){
    docker-container-stop-all
    docker-container-rm-all
    docker-images-rm-all
}

function dccls(){
    echo "Running: docker container ls -a"
    docker container ls -a
}

function dcils(){
    echo "Running: docker image ls -a"
    docker image ls -a
}
