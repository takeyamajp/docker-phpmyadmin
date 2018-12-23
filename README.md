FROM centos:centos7  
MAINTAINER "Hiroki Takeyama"

ENV REQUIRE_SSL true

ENV REQUIRE_BASIC_AUTH true  
ENV BASIC_AUTH_USER user  
ENV BASIC_AUTH_PASSWORD user

ENV PMA_HOST mysql  
ENV PMA_PORT 3306  
ENV PMA_USER root  
ENV PMA_PASSWORD root

VOLUME /dump

EXPOSE 80  
EXPOSE 443
