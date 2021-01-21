FROM	debian:10 as build

ENV	PACKAGES="file checkinstall dpkg-dev git dumb-init man checkinstall"

SHELL	["/bin/bash", "-o", "pipefail", "-c"]

# Install packages
ENV	DEBIAN_FRONTEND=noninteractive
RUN	echo 'deb http://deb.debian.org/debian buster-backports main' > /etc/apt/sources.list.d/buster-backports.list
RUN	apt-get update \
&&	apt-get -y upgrade \
&&	apt-get -y install $PACKAGES

# bash-pack
RUN	git clone https://github.com/casperklein/bash-pack
RUN	/bash-pack/install.sh -y

# Set timezone
RUN	ln -fs /usr/share/zoneinfo/Europe/Berlin /etc/localtime
#&&	dpkg-reconfigure -f noninteractive tzdata

# Build final image
FROM	scratch

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD	["/bin/bash"]

COPY	--from=build / /
