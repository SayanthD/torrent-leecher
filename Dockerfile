# creates a layer from the base Docker image.
FROM python:3.8.5-slim-buster

# set working directory
WORKDIR /app

# https://shouldiblamecaching.com/
ENV PIP_NO_CACHE_DIR=1

# we don't have an interactive xTerm
ENV DEBIAN_FRONTEND=noninteractive

# http://bugs.python.org/issue19846
# https://github.com/SpEcHiDe/PublicLeech/pull/97
ENV LANG=C.UTF-8

# sets the TimeZone, to be used inside the container
ENV TZ=Asia/Kolkata

# fix "ephimeral" / "AWS" file-systems
RUN sed -i.bak 's/us-west-2\.ec2\.//' /etc/apt/sources.list

# synchronize the package index files from their sources.
# and install required pre-requisites before proceeding ...
RUN apt update \
	&& apt install -y \
	curl \
	git \
	gnupg2 \
	software-properties-common \
	wget \
	&& apt-add-repository non-free

# add required files to sources.list
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && \
    echo "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" >> /etc/apt/sources.list

# install required packages
RUN apt update \
	&& apt install -y --no-install-recommends \
	# this package is required to fetch "contents" via "TLS"
	apt-transport-https \
	# install megatools and dependencies
	megatools jq pv \
	# install encoding tools
	ffmpeg \
	# install extraction tools
	p7zip rar unrar unzip zip \
	# miscellaneous helpers
	procps \
	# clean up previously installed SPC
	&& apt purge -y software-properties-common \
	# clean up the container "layer", after we are done
	&& rm -rf /var/lib/apt/lists /var/cache/apt/archives /tmp
	
# each instruction creates one layer
# Only the instructions RUN, COPY, ADD create layers.
# there are multiple '' dependancies,
# requiring the use of the entire repo, hence
# adds files from your Docker client’s current directory.
COPY . .

# install rclone, aria2 and pip packages via external scripts
RUN bash install-packages.sh

# specifies what command to run within the container.
CMD ["bash", "torrent-leecher.sh"]
