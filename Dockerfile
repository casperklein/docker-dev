ARG	debian=10

FROM	debian:$debian as build

ENV	USER="casperklein"
ENV	NAME="dev"
ENV	VERSION="latest"

ENV	PACKAGES="git"

SHELL	["/bin/bash", "-o", "pipefail", "-c"]

# Install packages
RUN	apt-get update \
&&	apt-get -y install $PACKAGES

# bash-pack
RUN	git clone https://github.com/casperklein/bash-pack
RUN	sed -i '/checkinstall/d' bash-pack/packages
RUN	/bash-pack/install.sh -y

RUN	apt-file update

# Copy root filesystem
COPY	rootfs /

# install checkinstall
RUN	MASCHINE=$(uname -m) \
;	[ "$MASCHINE" == "x86_64" ] && ARCH="amd64" || { \
		[ "$MASCHINE" == "aarch64" ] && ARCH="arm64" || \
			ARCH="armhf"; \
	} \
;	apt-get -y --no-install-recommends install file dpkg-dev && dpkg -i /checkinstall_1.6.2-4_$ARCH.deb

# Set timezone
RUN	ln -fs /usr/share/zoneinfo/Europe/Berlin /etc/localtime \
&&	dpkg-reconfigure -f noninteractive tzdata

# Build final image
RUN	apt-get -y install dumb-init
#&&	rm -rf /var/lib/apt/lists/*
FROM	scratch
COPY	--from=build / /

ENTRYPOINT ["/usr/bin/dumb-init", "--"]

CMD	["/bin/bash"]
