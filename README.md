[![Docker Stars](https://img.shields.io/docker/stars/takeyamajp/phpmyadmin.svg?style=flat-square)](https://hub.docker.com/r/takeyamajp/phpmyadmin/)
[![Docker Pulls](https://img.shields.io/docker/pulls/takeyamajp/phpmyadmin.svg?style=flat-square)](https://hub.docker.com/r/takeyamajp/phpmyadmin/)

FROM centos:centos7  
MAINTAINER "Hiroki Takeyama"

ENV TIMEZONE Asia/Tokyo

ENV REQUIRE_SSL true  
ENV ENABLE_GZIP_COMPRESSION true

ENV REQUIRE_BASIC_AUTH false  
ENV BASIC_AUTH_USER user  
ENV BASIC_AUTH_PASSWORD user

ENV PMA_HOST mysql  
ENV PMA_PORT 3306  
ENV PMA_USER root  
ENV PMA_PASSWORD root

VOLUME /backup

EXPOSE 80  
EXPOSE 443
