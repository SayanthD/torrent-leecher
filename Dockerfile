#  creates a layer from the base Docker image.
FROM python:3.8.5-slim-buster

# https://shouldiblamecaching.com/
ENV PIP_NO_CACHE_DIR=1

# we don't have an interactive xTerm
ENV DEBIAN_FRONTEND=noninteractive

# fix "ephimeral" / "AWS" file-systems
RUN sed -i.bak 's/us-west-2\.ec2\.//' /etc/apt/sources.list

# resynchronize the package index files from their sources.
# and install required pre-requisites before proceeding ...
RUN apt update \
	&& apt -qq install -y --no-install-recommends \
	curl \
	git \
	gnupg2 \
	unzip \
	wget \
	software-properties-common \
	&& rm -rf /var/lib/apt/lists/* \
	&& apt-add-repository non-free

# add required files to sources.list
RUN wget -qO- https://mkvtoolnix.download/gpg-pub-moritzbunkus.txt | apt-key add - && \
    wget -qO- https://ftp-master.debian.org/keys/archive-key-10.asc | apt-key add -
RUN echo "deb https://mkvtoolnix.download/debian/ buster main" >> /etc/apt/sources.list.d/bunkus.org.list && \
    echo deb http://deb.debian.org/debian buster main contrib non-free | tee -a /etc/apt/sources.list

# http://bugs.python.org/issue19846
# https://github.com/SpEcHiDe/PublicLeech/pull/97
ENV LANG=C.UTF-8

# sets the TimeZone, to be used inside the container
ENV TZ=Asia/Kolkata

# fetch and install rclone via script
RUN curl https://rclone.org/install.sh | bash

# copy 'requirements.txt' into the container
COPY requirements.txt .

# install required packages
RUN apt update \
	&& apt -qq install -y --no-install-recommends \
	# this package is required to fetch "contents" via "TLS"
	apt-transport-https \
	# install coreutils
	coreutils aria2 jq pv \
	# install encoding tools
	ffmpeg \
	# install extraction tools
	mkvtoolnix \
	p7zip rar unrar zip \
	# miscellaneous helpers
	megatools mediainfo \
	# clean up previously installed SPC
	&& apt purge -y software-properties-common \
	# clean up the container "layer", after we are done
	&& rm -rf /var/lib/apt/lists /var/cache/apt/archives /tmp \
	# install requirements, inside the container
	&& pip3 install --no-cache-dir -r requirements.txt

# each instruction creates one layer
# Only the instructions RUN, COPY, ADD create layers.
# there are multiple '' dependancies,
# requiring the use of the entire repo, hence
# adds files from your Docker client’s current directory.
COPY . /app/

# set workdir
WORKDIR /app

# specifies what command to run within the container.
CMD ["python3", "-m", "tobrot"]
