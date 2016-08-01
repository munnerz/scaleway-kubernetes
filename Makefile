NAME =			scaleway-kubernetes
VERSION =		1.3.3
VERSION_ALIASES =	1.3.3 1.3 1
TITLE =			Kubernetes
DESCRIPTION =		Kuberenetes v1.3.3
SOURCE_URL =		https://github.com/munnerz/scaleway-kubernetes
DEFAULT_IMAGE_ARCH =	x86_64
IMAGE_VOLUME_SIZE =	100G
IMAGE_BOOTSCRIPT =	docker

## Image tools  (https://github.com/scaleway/image-tools)
all:	docker-rules.mk
docker-rules.mk:

	wget -qO - https://j.mp/scw-builder | bash
-include docker-rules.mk
## Here you can add custom commands and overrides