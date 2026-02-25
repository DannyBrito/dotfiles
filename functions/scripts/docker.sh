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
    # Platform-aware Docker reset
    case "$(uname -s)" in
        Darwin*)
            echo "Running: killall Docker && open -a Docker"
            killall Docker 2>/dev/null
            open -a Docker
            ;;
        Linux*)
            echo "Running: sudo systemctl restart docker docker.socket"
            sudo systemctl restart docker docker.socket
            ;;
        *)
            echo "Unsupported platform for docker-hard-reset"
            return 1
            ;;
    esac
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
