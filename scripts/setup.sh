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
    \t${BOLD}-d, --download_dependences${NORMAL}
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
function download_dependences () {
    mkdir -p -m 775 $DOWNLOADS_PATH
    mkdir -p -m 775 $SDK_AND_COMPILER

    export PREFIX="$HOME/opt/cross"
    export TARGET=i686-elf
    export PATH="$PREFIX/bin:$PATH"

    if [ ! -d "$SDK_AND_COMPILER/binutils-2.35" ]; then
        if [ ! -f "$DOWNLOADS_PATH/binutils-2.35.tar.xz" ]; then
            echo -e "${YELLOW}Downloading binutils-2.35${NC}"
            wget -P $DOWNLOADS_PATH wget https://ftp.gnu.org/gnu/binutils/binutils-2.35.tar.xz
        fi

        echo -e "${YELLOW}Extracting tarball contents${NC}"
        tar -xvf "$DOWNLOADS_PATH/binutils-2.35.tar.xz" -C $SDK_AND_COMPILER

        echo -e "${YELLOW} Installing binutils${NC}"
        cd $SDK_AND_COMPILER
        mkdir build-binutils

        cd build-binutils
        ../binutils-2.35/configure --target=$TARGET --prefix="$PREFIX" --with-sysroot --disable-nls --disable-werror
        make
        make install

        cd $DOCKER_BBB_MNT

    else
        echo -e "${GREEN}binutils-2.35 already installed${NC}"
    fi

    if [ ! -d "$SDK_AND_COMPILER/gcc-10.2.0" ]; then
        if [ ! -f "$DOWNLOADS_PATH/gcc-10.2.0.tar.gz" ]; then
            echo -e "${YELLOW}Downloading gcc-10.2.0${NC}"
            wget -P $DOWNLOADS_PATH wget https://bigsearcher.com/mirrors/gcc/releases/gcc-10.2.0/gcc-10.2.0.tar.gz
        fi

        echo -e "${YELLOW}Extracting tarball contents${NC}"
        tar -xvzf "$DOWNLOADS_PATH/gcc-10.2.0.tar.gz" -C $SDK_AND_COMPILER

        echo -e "${YELLOW} Installing gcc-10.2.0${NC}"
        cd $SDK_AND_COMPILER

        mkdir build-gcc
        cd build-gcc

        ../gcc-10.2.0/configure --target=$TARGET --prefix="$PREFIX" --disable-nls --enable-languages=c,c++ --without-headers
        make all-gcc
        make all-target-libgcc
        make install-gcc
        make install-target-libgcc

        cd $DOCKER_BBB_MNT
    else
        echo -e "${GREEN}gcc-10.2.0 already installed${NC}"
    fi

}

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
    xhost + # Enabling external connections to host x11 server

    if [ $ret -eq 0 ]; then
        echo -e "${BLUE}Creating container and openning it in interactive mode${NC}"
        docker run --rm \
                   --name $DOCKER_CONTAINER_NAME \
                   -i -t --privileged \
                   --user root \
                   --net=host \
                   --env="DISPLAY" \
                   --volume="$HOME/.Xauthority:/root/.Xauthority:rw" \
                   -v $SCRIPT_ABS_PATH/../:"/home/builder" \
                   -v /media:"/media" $DOCKER_IMAGE_NAME \
                   bash -c "source /home/builder/scripts/./setup.sh -e; bash"
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
    -c|--create_docker)
        create_docker
        break
    ;;
    -d|--download_dependences)
        download_dependences
        break
    ;;
    -e|--set_environment_variables)
        set_environment_variables
        break
    ;;
    -h|--help)
        help
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
