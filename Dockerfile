# Galaxy - MPAgenomics
#
# VERSION       0.2

FROM bgruening/galaxy-stable

MAINTAINER S. BLANCK, samuel.blanck@univ-lille.fr

ENV GALAXY_CONFIG_BRAND MPAgenomics

WORKDIR /galaxy-central



RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
#RUN echo "deb http://cran.rstudio.com/bin/linux/ubuntu trusty/" >> /etc/apt/sources.list
RUN apt-get update
RUN apt-get install -y software-properties-common 
RUN add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/'


RUN apt-get update && apt-get install -y \
    r-base \
   r-base-dev 

#RUN wget http://braju.com/R/src/contrib/aroma.affymetrix_2.13.1.tar.gz

RUN Rscript -e "source('http://www.braju.com/R/hbLite.R')" -e "hbLite('sfit')" -e "install.packages('BiocManager')" -e "BiocManager::install('affxparser')"  -e "BiocManager::install('DNAcopy')" -e "BiocManager::install('aroma.light')" 
RUN Rscript -e "install.packages(c('R.filesets','PSCBS'), repos='http://cran.us.r-project.org', dependencies=TRUE)" 
RUN Rscript -e "install.packages(c('aroma.affymetrix','aroma.cn'), repos='http://cran.us.r-project.org', dependencies=TRUE)" 
RUN Rscript -e "install.packages('https://cran.r-project.org/src/contrib/Archive/cghseg/cghseg_1.0.2-1.tar.gz', repos = NULL, type = 'source', dependencies=TRUE)"
RUN Rscript -e "install.packages(c('changepoint', 'glmnet', 'HDPenReg', 'spikeslab'), repos='http://cran.us.r-project.org', dependencies=TRUE)"
RUN Rscript -e "install.packages('https://cran.r-project.org/src/contrib/Archive/MPAgenomics/MPAgenomics_1.1.2.tar.gz', repos=NULL, type = 'source', dependencies=TRUE)"

RUN apt-get update
RUN apt-get install -y libssl-dev libcurl4-openssl-dev
RUN Rscript -e "install.packages('optparse', repos='http://cran.us.r-project.org', dependencies=TRUE)" 

# RUN install-repository \
#    "--url https://testtoolshed.g2.bx.psu.edu/ -o iuc --name package_r_3_1_2"

#RUN cd /usr/lib/R/lib
#RUN cp /galaxy-central/tool_deps/R/3.1.2/iuc/package_r_3_1_2/41f43a2064ba/lib/libgfortran.so.1 .
#RUN cp /galaxy-central/tool_deps/R/3.1.2/iuc/package_r_3_1_2/41f43a2064ba/lib/R/lib/libRblas.so .
#RUN cp /galaxy-central/tool_deps/R/3.1.2/iuc/package_r_3_1_2/41f43a2064ba/lib/R/lib/libRlapack.so .

#RUN rm /galaxy-central/tool_deps/R/3.1.2/iuc/package_r_3_1_2/41f43a2064ba/lib/libgfortran.so
#RUN ln -s /usr/lib/x86_64-linux-gnu/libgfortran.so.3  /galaxy-central/tool_deps/R/3.1.2/iuc/package_r_3_1_2/41f43a2064ba/lib/libgfortran.so

ADD tools.yml $GALAXY_ROOT/tools.yaml
RUN install-tools $GALAXY_ROOT/tools.yaml && \
    /tool_deps/_conda/bin/conda clean --tarballs
    
#ADD datatypes_conf.xml $GALAXY_ROOT/config/datatypes_conf.xml

# Install MPAgenomics
#RUN install-repository \
#    "--url https://testtoolshed.g2.bx.psu.edu/ -o sblanck --name mpagenomics_datatypes" 
#RUN install-repository \
#    "--url https://testtoolshed.g2.bx.psu.edu/ -o sblanck --name mpagenomics_wrappers --panel-section-name MPAgenomics" 




#env PATH /galaxy-central/tool_deps/R/3.1.2/iuc/package_r_3_1_2/41f43a2064ba/bin:$PATH


# Mark folders as imported from the host.
VOLUME ["/export/", "/data/", "/var/lib/docker"]

# Expose port 80 (webserver), 21 (FTP server), 8800 (Proxy)
EXPOSE :80
EXPOSE :21
EXPOSE :8800

# Autostart script that is invoked during container start
CMD ["/usr/bin/startup"]


