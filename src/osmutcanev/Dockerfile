FROM debian:jessie
MAINTAINER Imre Samu  https://github.com/ImreSamu
LABEL Description="OSM HUN Streetname compare"

ENV DEBIAN_FRONTEND noninteractive

# make the "en_US.utf8" locale 
RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
	&& localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8


RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates \
 	  curl \
 	  libcurl4-gnutls-dev \
 	  libgdal-dev \
 	  libgeos-dev \
 	  libpq-dev \
 	  libproj-dev \
 	  libxml2-dev \
 	  libxslt-dev \ 
 	  postgresql-client \
 	  wget \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /var/lib/apt/lists

# install imposm3 & pgclimb
RUN mkdir /tools \
    && cd /tools \
    && wget http://imposm.org/static/rel/imposm3-0.2.0dev-20160517-3c27127-linux-x86-64.tar.gz \
    && tar zxvf imposm3-0.2.0dev-20160517-3c27127-linux-x86-64.tar.gz \
    && ln -s imposm3-0.2.0dev-20160517-3c27127-linux-x86-64 latest \
    && cd latest \
    && wget -O pgclimb https://github.com/lukasmartinelli/pgclimb/releases/download/v0.2/pgclimb_linux_amd64 \
    && chmod +x pgclimb 
    
# Install R and R packages ...
RUN echo 'deb http://cloud.r-project.org/bin/linux/debian jessie-cran3/'  >> /etc/apt/sources.list \
 && echo 'deb http://cran.rstudio.com/bin/linux/debian jessie-cran3/'     >> /etc/apt/sources.list \
 && apt-key adv --keyserver keys.gnupg.net --recv-key 381BA480 \
 && apt-get update \
 && apt-get install -y --no-install-recommends r-base r-base-dev   \
 && echo 'options(repos = c(CRAN = "https://cran.rstudio.com/"), download.file.method = "libcurl")' >> /etc/R/Rprofile.site \ 
 && Rscript -e 'install.packages("SortableHTMLTables",dependencies=TRUE, clean=TRUE) ' \
 && Rscript -e 'install.packages("RPostgreSQL",dependencies=TRUE, clean=TRUE) ' \
 && Rscript -e 'install.packages("gtools",dependencies=TRUE, clean=TRUE) ' \
 && Rscript -e 'install.packages("sp"  ,dependencies=TRUE, clean=TRUE) ' \
 && Rscript -e 'install.packages("ggplot2",dependencies=TRUE, clean=TRUE) ' \
 && Rscript -e 'install.packages("RColorBrewer",dependencies=TRUE, clean=TRUE) ' \
 && Rscript -e 'install.packages("rgeos" ,dependencies=TRUE, clean=TRUE) '  \
 && Rscript -e 'install.packages("rgdal",dependencies=TRUE, clean=TRUE) ' \
 && Rscript -e 'install.packages("devtools",dependencies=TRUE, clean=TRUE) ' \
 && Rscript -e 'devtools::install_github("SESYNC-ci/postGIStools") ' \
 && apt-get purge -f -y g++ \
                        gcc \
                        gfortran \                        
                        libicu-dev \
                        r-base-dev \
 && apt-get clean \
 && apt-get autoclean -y \
 && apt-get autoremove -y \
 && apt-get clean \
 && rm -rf /tmp/* /var/tmp/* \
 && rm -rf /var/lib/apt/lists/* 

# project files
COPY ./src       /osm/src
COPY ./start.sh  /osm/start.sh  
WORKDIR /osm
CMD ["/osm/start.sh"]

