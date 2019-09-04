ARG	FROM=debian:10-slim

FROM    $FROM as build

ENV	PACKAGES="git"

# Install packages
RUN     apt-get update \
&&	apt-get -y install $PACKAGES

# Copy root filesystem
#COPY	rootfs /

# bash-pack
RUN	git clone https://github.com/casperklein/bash-pack \
&&	sed -i '/checkinstall/d' bash-pack/packages \
&&	/bash-pack/install.sh -y

# Build final image
RUN	apt-get -y install dumb-init \
&&	rm -rf /var/lib/apt/lists/*
FROM	scratch
COPY	--from=build / /

ENTRYPOINT ["/usr/bin/dumb-init", "--"]

CMD	["/bin/bash"]
