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
RUN add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/'


RUN apt-get update && apt-get install -y \
    r-base \
   r-base-dev 

RUN Rscript -e "source('http://www.braju.com/R/hbLite.R')" -e "hbLite('sfit')" -e "install.packages('BiocManager')" -e "BiocManager::install('affxparser')"  -e "BiocManager::install('DNAcopy')" -e "BiocManager::install('aroma.light')" 
RUN Rscript -e "install.packages(c('R.filesets','PSCBS'), repos='http://cran.us.r-project.org', dependencies=TRUE)" 
RUN Rscript -e "install.packages(c('aroma.affymetrix','aroma.cn'), repos='http://cran.us.r-project.org', dependencies=TRUE)" 
RUN Rscript -e "install.packages('https://cran.r-project.org/src/contrib/Archive/cghseg/cghseg_1.0.2-1.tar.gz', repos = NULL, type = 'source', dependencies=TRUE)"
RUN Rscript -e "install.packages(c('changepoint', 'glmnet', 'HDPenReg', 'spikeslab'), repos='http://cran.us.r-project.org', dependencies=TRUE)"
RUN Rscript -e "install.packages('https://cran.r-project.org/src/contrib/Archive/MPAgenomics/MPAgenomics_1.1.2.tar.gz', repos=NULL, type = 'source', dependencies=TRUE)"

RUN apt-get update
RUN apt-get install -y libssl-dev libcurl4-openssl-dev
RUN Rscript -e "install.packages('optparse', repos='http://cran.us.r-project.org', dependencies=TRUE)" 

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


