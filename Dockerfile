## -*- docker-image-name: "munnerz/scaleway-kubernetes:amd64" -*-
FROM scaleway/debian:amd64-sid
MAINTAINER James Munnelly <james@munnelly.eu>

# Prepare rootfs for image-builder.
#   This script prevent aptitude to run services when installed
RUN /usr/local/sbin/builder-enter

# Add early-docker group
RUN addgroup early-docker

# Install docker dependencies & upgrade system
RUN apt-get -q update \
	&& apt-get -y -qq upgrade \
	&& apt-get install -y -q \
		apparmor \
		arping \
		aufs-tools \
		btrfs-tools \
		bridge-utils \
		cgroupfs-mount \
		git \
		ifupdown \
		kmod \
		lxc \
		python-setuptools \
		vlan \
	&& apt-get clean

# Install docker
RUN curl -L https://get.docker.com/ | sh

# Install etcd
RUN wget https://github.com/coreos/etcd/releases/download/v3.0.4/etcd-v3.0.4-linux-amd64.tar.gz \
    && tar xvf etcd-v3.0.4-linux-amd64.tar.gz \
    && mv etcd-v3.0.4-linux-amd64/etcd etcd-v3.0.4-linux-amd64/etcdctl /usr/bin/ \
    && rm -Rf etcd-v3.0.4-linux-amd64 etcd-v3.0.4-linux-amd64.tar.gz

# Install flanneld
RUN wget https://github.com/coreos/flannel/releases/download/v0.5.5/flannel-0.5.5-linux-amd64.tar.gz \
    && tar xvf flannel-0.5.5-linux-amd64.tar.gz \
    && mv flannel-0.5.5/flanneld /usr/bin/ \
    && rm -Rf flannel-0.5.5 flannel-0.5.5-linux-amd64.tar.gz

# Add local files into the root (extra config etc)
COPY ./rootfs/ /

RUN systemctl enable docker \
    && systemctl enable early-docker \
    && systemctl enable etcd \
    && systemctl enable flannel \
    && systemctl enable update-firewall \
    && systemctl enable kubelet

# Clean rootfs from image-builder.
#   Revert the builder-enter script
RUN /usr/local/sbin/builder-leave
