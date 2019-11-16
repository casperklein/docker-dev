ARG	debian=10

FROM    debian:$debian as build

ENV	USER="casperklein"
ENV	NAME="dev"
ENV	VERSION="latest"

ENV	PACKAGES="git"

# Install packages
RUN     apt-get update \
&&	apt-get -y install $PACKAGES

# bash-pack
RUN	git clone https://github.com/casperklein/bash-pack
RUN	sed -i '/checkinstall/d' bash-pack/packages
RUN	/bash-pack/install.sh -y

RUN	apt-file update

# Copy root filesystem
COPY	rootfs /

# install checkinstall
RUN	apt-get -y --no-install-recommends install file dpkg-dev && dpkg -i /checkinstall_1.6.2-4_amd64.deb

# Cleanup
RUN	apt -y autoremove

# Build final image
RUN	apt-get -y install dumb-init
#&&	rm -rf /var/lib/apt/lists/*
FROM	scratch
COPY	--from=build / /

ENTRYPOINT ["/usr/bin/dumb-init", "--"]

CMD	["/bin/bash"]
