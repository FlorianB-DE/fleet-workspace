# syntax=docker/dockerfile:1
ARG BASE=ubuntu
ARG VERSION=latest

FROM $BASE:$VERSION

# update and install neccassary packages 
RUN apt update && apt upgrade -y
RUN ["apt", "install", "-y", "sudo", "bash", "curl"]

# download fleet server
ARG TARGETPLATFORM
RUN ["mkdir", "/fleet"]
WORKDIR /fleet
RUN if [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
        curl -LSs "https://download.jetbrains.com/product?code=FLL&release.type=preview&release.type=eap&platform=linux_aarch64" --output server ; \
    elif [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
        curl -LSs "https://download.jetbrains.com/product?code=FLL&release.type=preview&release.type=eap&platform=linux_x64" --output server ; \
    else \
        echo "arch $TARGETPLATFORM not supported" && exit 255 ; \
    fi

RUN ["chmod", "+x", "/fleet/server"]

RUN ["groupadd", "fleet"]
RUN ["useradd", "-m", "-g", "fleet", "-G", "sudo", "fleet"]
RUN echo "fleet ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers 

USER fleet

# copy default settings
COPY default.settings.json /home/fleet/.fleet/settings.json
RUN ["sudo", "chown", "-R", "fleet:fleet", "/home/fleet"]

# create project folder
RUN ["mkdir", "/home/fleet/project"]
WORKDIR /home/fleet/project

CMD /bin/bash -c "/fleet/server --debug launch workspace --version 1.19.95 -- --auth=accept-everyone --publish --enableSmartMode --projectDir=$HOME/project"