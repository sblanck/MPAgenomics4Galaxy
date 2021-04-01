# Galaxy - MPAgenomics
#
# VERSION       0.4

FROM bgruening/galaxy-stable

MAINTAINER S. BLANCK, samuel.blanck@univ-lille.fr

ENV GALAXY_CONFIG_BRAND MPAgenomics

WORKDIR /galaxy-central

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
RUN apt-get update
RUN apt-get install -y software-properties-common 
RUN apt-get update && apt-get install -y libssl-dev libcurl4-openssl-dev
RUN add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/'


RUN apt-get update && apt-get install -y \
    r-base \
   r-base-dev 

ADD Rinstall.R $GALAXY_ROOT/Rinstall.R
RUN Rscript $GALAXY_ROOT/Rinstall.R

ADD tools.yml $GALAXY_ROOT/tools.yaml
RUN install-tools $GALAXY_ROOT/tools.yaml && \
    /tool_deps/_conda/bin/conda clean --tarballs
    
ADD integrated_tool_panel.xml /export/galaxy-central/integrated_tool_panel.xml
# Mark folders as imported from the host.
VOLUME ["/export/", "/data/", "/var/lib/docker"]

# Expose port 80 (webserver), 21 (FTP server), 8800 (Proxy)
EXPOSE :80
EXPOSE :21
EXPOSE :8800

# Autostart script that is invoked during container start
CMD ["/usr/bin/startup"]


