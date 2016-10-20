FROM ubuntu:16.04

MAINTAINER Oleg Kovalenko <monstrenyatko@gmail.com>

RUN sed 's/main$/main universe/' -i /etc/apt/sources.list && \
    apt-get update && apt-get install -y software-properties-common && \
    add-apt-repository ppa:webupd8team/java -y && \
    apt-get update && \
    echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get install -y oracle-java8-installer libxext-dev libxrender-dev libxtst-dev g++ make autoconf libtool \
        libncurses5-dev bison flex sudo iputils-ping ca-certificates wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*

ENV GOSU_VERSION 1.9
RUN set -x \
    && dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" \
    && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch" \
    && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true

RUN apt-get update && \
    apt-get install -y gnome-themes-standard libcanberra-gtk-module gtk2-engines-murrine libwebkitgtk-1.0-0 libwebkitgtk-3.0-0 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*
ENV MOZILLA_FIVE_HOME /usr/lib/mozilla

COPY themes /usr/share/themes
RUN chmod -R +r /usr/share/themes && chmod -R +X /usr/share/themes
ENV GTK_THEME "Human Quarny"
ENV GTK2_RC_FILES "/usr/share/themes/Human Quarny/gtk-2.0/gtkrc"

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

