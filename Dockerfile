################# BASE IMAGE #####################
FROM continuumio/miniconda3:4.7.12

################## METADATA #######################

LABEL base_image="continuumio/miniconda3"
LABEL version="4.7.12"
LABEL software="svaba-nf"
LABEL software.version="1.0"
LABEL about.summary="Container image containing all requirements for svaba-nf"
LABEL about.home="http://github.com/IARCbioinfo/svaba-nf"
LABEL about.documentation="http://github.com/IARCbioinfo/svaba-nf/README.md"
LABEL about.license_file="http://github.com/IARCbioinfo/svaba-nf/LICENSE.txt"
LABEL about.license="GNU-3.0"

################## MAINTAINER ######################
MAINTAINER Nicolas Alcala <alcalan@iarc.fr>

################## INSTALLATION ######################
COPY environment.yml /
RUN apt-get update && apt-get install -y procps && apt-get clean -y
RUN conda env create -n svaba-nf -f /environment.yml && conda clean -a
ENV PATH /opt/conda/envs/svaba-nf/bin:$PATH
RUN apt-get clean && \
	apt-get update -y && \
	DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
	build-essential \
	zlib1g-dev \
	libbz2-dev \
	liblzma-dev && \
	# install svaba from github repository
	git clone --recursive https://github.com/walaj/svaba && \
	cd svaba && \
	./configure && \
	make && \
	make install && \
	# export executable to PATH
	cp bin/svaba /usr/bin/ && \
	# Clean
	DEBIAN_FRONTEND=noninteractive apt-get autoremove -y && \
	apt-get clean
