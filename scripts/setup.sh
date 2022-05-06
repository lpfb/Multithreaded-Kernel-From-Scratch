#!/bin/bash

#Colors
GREEN='\e[1;32m'
BLUE='\e[1;36m'
WITHE='\e[0;37m'
YELLOW='\e[1;33m'
RED='\e[1;31m'
NC='\e[0m'

# Print formatting
BOLD=$(tput bold)
NORMAL=$(tput sgr0)

# Used paths
SCRIPT_ABS_PATH=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
DOCKER_BBB_MNT=$(readlink -f "$SCRIPT_ABS_PATH/../")
SDK_AND_COMPILER="$DOCKER_BBB_MNT/crosslibs"
DOWNLOADS_PATH="$DOCKER_BBB_MNT/downloads"

# Docker container name
DOCKER_CONTAINER_NAME="kernel-developtment"

# Docker image name
DOCKER_IMAGE_NAME=($DOCKER_CONTAINER_NAME"/debian")


# ======================================
#              Help Menu
# ======================================
function help () {
    echo -e "${BLUE}Available Options:${NC}

    \t${BOLD}-h, --help${NORMAL}
    \t\tShow this help menu
    \t${BOLD}-c, --create_docker${NORMAL}
    \t\tStart docker container in interactive mode
    \t${BOLD}-o, --open_docker${NORMAL}
    \t\tStart docker container in interactive mode
    \t${BOLD}-r, --delete_docker${NORMAL}
    \t\tRemove docker image and container
    \t${BOLD}-x, --cleanup${NORMAL}
    \t\tClean up development environment.
    "
}

# ====================================================================
#   Functions used only by other scripts and/or internal functions
# ====================================================================

# Set environment variables to be used inside docker
function set_environment_variables () {
    ret=$(pwd)
    #
    # export ARMGCC_DIR="$SDK_AND_COMPILER/gcc-arm-none-eabi-10.3-2021.10"
    # export KL25Z_SDK_PATH="$SDK_AND_COMPILER/kl25z-sdk"
    # export PATH="$PATH:$SCRIPT_ABS_PATH:$ARMGCC_DIR/bin"
}

# =============================
#   User available functions
# =============================
function create_docker () {
    ret=$(docker images | grep $DOCKER_IMAGE_NAME | wc -l)

    if [ $ret -eq 0 ]; then
        echo -e "${GREEN}Building $DOCKER_IMAGE_NAME image${NC}"
        docker build -f $SCRIPT_ABS_PATH/../docker-build/Dockerfile --network=host -t $DOCKER_IMAGE_NAME .
    else
        echo -e "${YELLOW}Docker image $DOCKER_IMAGE_NAME already created${NC}"
    fi
}

function delete_docker () {
    echo -e "${GREEN}Removing $DOCKER_CONTAINER_NAME container${NC}"
    docker rm $DOCKER_CONTAINER_NAME > /dev/null 2>&1

    if [ $? -eq 0 ]; then
        echo -e "${BLUE}Container removed with success!${NC}"
    else
        echo -e "${RED}It was not possible to remove the container${NC}"
    fi

    echo -e "${GREEN}Removing $DOCKER_IMAGE_NAME image${NC}"
    docker rmi $DOCKER_IMAGE_NAME > /dev/null 2>&1

    if [ $? -eq 0 ]; then
        echo -e "${BLUE}Image removed with success!${NC}"
    else
        echo -e "${RED}It was not possible to remove the Image${NC}"
    fi
}

function open_docker () {
    ret=$(docker ps -a | grep $DOCKER_CONTAINER_NAME | wc -l)

    if [ $ret -eq 0 ]; then
        echo -e "${BLUE}Creating container and openning it in interactive mode${NC}"
        docker run --name $DOCKER_CONTAINER_NAME -i -t --privileged --user root --network host --env="DISPLAY" --volume="$HOME/.Xauthority:/root/.Xauthority:rw" -v $SCRIPT_ABS_PATH/../:"/home/builder" -v /media:"/media" $DOCKER_IMAGE_NAME bash -c "source /home/builder/scripts/./setup.sh -e; bash"
    else
        echo -e "${BLUE}Openning container $DOCKER_CONTAINER_NAME${NC}"
        docker start -a -i $DOCKER_CONTAINER_NAME
    fi
}

function cleanup () {
    echo -e "${YELLOW}Removing crosslibs and downloads folders${NC}"
    rm -rf $DOWNLOADS_PATH
    rm -rf $SDK_AND_COMPILER
}

# ======================================
#               Menu
# ======================================
if [ $# -eq 0 ]; then
    echo -e "${RED}No arguments provided!!${NC}"
    echo ""
    help
    exit 1
fi

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -h|--help)
        help
        break
    ;;
    -e|--set_environment_variables)
        set_environment_variables
        break
    ;;
    -c|--create_docker)
        create_docker
        break
    ;;
    -o|--open_docker)
        open_docker
        break
    ;;
    -r|--delete_docker)
        delete_docker
        break
    ;;
    -x|--cleanup)
        cleanup
        break
    ;;
    *)    # unknown options passed
        echo -e "${RED}ERROR: Wrong argument: {$1}${NC}"
        echo ""
        help
        break
    ;;
esac
done
