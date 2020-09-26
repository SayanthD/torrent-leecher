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
RUN curl -fsSL https://mkvtoolnix.download/gpg-pub-moritzbunkus.txt | apt-key add - && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && \
    echo "deb https://mkvtoolnix.download/debian/ $(lsb_release -sc) main" >> etc/apt/sources.list.d/bunkus.org.list && \
    echo "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" >> /etc/apt/sources.list

# http://bugs.python.org/issue19846
# https://github.com/SpEcHiDe/PublicLeech/pull/97
ENV LANG=C.UTF-8

# sets the TimeZone, to be used inside the container
ENV TZ=Asia/Kolkata

# copy aria2, rclone installer to /tmp
COPY requirements.txt install-packages.sh /tmp/

# install rclone and arai2 via external scripts
RUN bash /tmp/install-packages.sh

# install required packages
RUN apt update \
	&& apt -qq install -y --no-install-recommends \
	# this package is required to fetch "contents" via "TLS"
	apt-transport-https \
	# install coreutils
	coreutils jq pv procps \
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
	&& rm -rf /var/lib/apt/lists /var/cache/apt/archives /tmp

# each instruction creates one layer
# Only the instructions RUN, COPY, ADD create layers.
# there are multiple '' dependancies,
# requiring the use of the entire repo, hence
# adds files from your Docker client’s current directory.
COPY . /app/

# Set working directory
WORKDIR /app

# specifies what command to run within the container.
CMD ["bash", "torrent-leecher.sh"]
