FROM debian:stable

MAINTAINER "lpfb"

RUN sed -i '/jessie-updates/d' /etc/apt/sources.list  # Now archived

# Install docker dependencies
RUN apt-get update && apt-get install -y \
    vim \
    nasm \
    qemu-system-x86 \
    python3 \
    git \
    wget \
    tmux \
    iputils-ping

# Create a user and group used to launch processes
RUN  groupadd -g 1003 builder \
  && useradd -u 1003 -g builder -G builder -m -d /home/builder -s /bin/bash -c "builder user" -p builder builder

RUN echo "PS1='\${debian_chroot:+(\$debian_chroot)}\h:\w\$ '\nexport LS_OPTIONS='--color=auto'\nalias ls='ls \$LS_OPTIONS'\nalias ll='ls \$LS_OPTIONS -l'\nalias l='ls \$LS_OPTIONS -lA'\nalias rm='rm -i'\nalias cp='cp -i'\nalias mv='mv -i'" > ~/.bashrc

USER builder

WORKDIR /home/builder