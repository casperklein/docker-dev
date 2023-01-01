FROM	debian:11 as build

SHELL	["/bin/bash", "-o", "pipefail", "-c"]

ARG	PACKAGES="file dpkg-dev checkinstall git ca-certificates dumb-init"

# Install packages
ARG	DEBIAN_FRONTEND=noninteractive
#RUN	echo 'deb http://deb.debian.org/debian buster-backports main' > /etc/apt/sources.list.d/buster-backports.list \
RUN	apt-get update \
&&	apt-get -y upgrade \
&&	apt-get -y --no-install-recommends install $PACKAGES

# bash-pack
RUN	git clone https://github.com/casperklein/bash-pack /scripts \
&&	/scripts/install.sh -y

# Set timezone
RUN	ln -fs /usr/share/zoneinfo/Europe/Berlin /etc/localtime

# Build final image
FROM	scratch

ARG	VERSION="unknown"

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD	["/bin/bash"]

COPY	--from=build / /
