FROM rocker/geospatial
LABEL Description="OSM HUN Streetname compare"

RUN install2.r --error \
    SortableHTMLTables \
    RPostgreSQL \
    gtools \
    ggplot2 \
    devtools

RUN Rscript -e 'devtools::install_github("SESYNC-ci/postGIStools") '

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    ca-certificates \
    dirmngr \
    gnupg \
  && rm -rf /var/lib/apt/lists

ENV PG_MAJOR 11
RUN set -ex; \
	echo "deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main" > /etc/apt/sources.list.d/pgdg.list ;  \
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -


RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    gdal-bin \
    mc \
    osmctools \
    osmium-tool \
    postgresql-client-${PG_MAJOR} \
    wget \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists

# install imposm3 & pgclimb
ENV IMPOSMVER 0.8.1
RUN mkdir /tools \
    && cd /tools \
    && wget https://github.com/omniscale/imposm3/releases/download/v${IMPOSMVER}/imposm-${IMPOSMVER}-linux-x86-64.tar.gz \
    && tar zxvf imposm-${IMPOSMVER}-linux-x86-64.tar.gz \
    && rm imposm-${IMPOSMVER}-linux-x86-64.tar.gz \
    && ln -sf imposm-${IMPOSMVER}-linux-x86-64 latest \
    && /tools/latest/imposm version

RUN cd /tools/latest \
    && wget -O pgclimb https://github.com/lukasmartinelli/pgclimb/releases/download/v0.3/pgclimb_linux_amd64 \
    && chmod +x pgclimb \
    && wget -O pgfutter https://github.com/lukasmartinelli/pgfutter/releases/download/v1.2/pgfutter_linux_amd64 \
    && chmod +x pgfutter

# Map labels
ENV MAPLABEL1 env_maplabel1_unset
ENV MAPLABEL2 env_maplabel2_unset

# project files
COPY ./src       /osm/src
COPY ./start.sh  /osm/start.sh
WORKDIR /osm
CMD ["/osm/start.sh"]

