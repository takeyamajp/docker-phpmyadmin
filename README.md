# phpmyadmin
Star this repository if it is useful for you.  
[![Docker Stars](https://img.shields.io/docker/stars/takeyamajp/phpmyadmin.svg)](https://hub.docker.com/r/takeyamajp/phpmyadmin/)
[![Docker Pulls](https://img.shields.io/docker/pulls/takeyamajp/phpmyadmin.svg)](https://hub.docker.com/r/takeyamajp/phpmyadmin/)
[![license](https://img.shields.io/github/license/takeyamajp/docker-phpmyadmin.svg)](https://github.com/takeyamajp/docker-phpmyadmin/blob/master/LICENSE)

## Supported tags and respective Dockerfile links  
- [`latest`, `rocky9`](https://github.com/takeyamajp/docker-phpmyadmin/blob/master/rocky9/Dockerfile) (Rocky Linux 9)
- [`rocky8`](https://github.com/takeyamajp/docker-phpmyadmin/blob/master/rocky8/Dockerfile) (Rocky Linux 8)
- [`centos8`](https://github.com/takeyamajp/docker-phpmyadmin/blob/master/centos8/Dockerfile) (We have finished support for CentOS 8.)
- [`centos7`](https://github.com/takeyamajp/docker-phpmyadmin/blob/master/centos7/Dockerfile)

## Image summary
    FROM rockylinux/rockylinux:9   
    MAINTAINER "Hiroki Takeyama"
    
    ENV TIMEZONE Asia/Tokyo
    
    ENV HOSTNAME www.example.com  
    ENV FORCE_SSL true  
    ENV GZIP_COMPRESSION true
    
    ENV BASIC_AUTH false  
    ENV BASIC_AUTH_USER user  
    ENV BASIC_AUTH_PASSWORD password
    
    ENV HTTPD_SERVER_ADMIN root@localhost  
    ENV HTTPD_LOG true  
    ENV HTTPD_LOG_LEVEL warn  
    ENV HTTPD_PHP_ERROR_LOG true
    
    ENV PMA_HOST mysql  
    ENV PMA_PORT 3306  
    ENV PMA_USER root  
    ENV PMA_PASSWORD password
    
    # Upload And Save Files  
    VOLUME /export  
    # SSL Certificates  
    VOLUME /ssl_certs
    
    EXPOSE 80  
    EXPOSE 443

## How to use
This container is supposed to be used as a backend of a reverse proxy server.  
However, it can be simply used without the reverse proxy server.

### via [`docker-compose`](https://github.com/docker/compose)

    version: '3.1'  
    services:  
      wordpress:  
        image: takeyamajp/phpmyadmin  
        ports:  
          - "8080:80"  
        environment:  
          FORCE_SSL: "false"  
      mysql:  
        image: takeyamajp/mysql  

Run `docker-compose up -d`, wait for it to initialize completely. (It takes several minutes.)  
Then, access it via `http://localhost:8080` or `http://host-ip:8080` in your browser.

## Time zone
You can use any time zone such as America/Chicago that can be used in Rocky Linux.  

See below for zones.  
https://www.unicode.org/cldr/charts/latest/verify/zones/en.html

## Force SSL
If `FORCE_SSL` is true, the URL will be redirected automatically from HTTP to HTTPS protocol.

## GZIP Compression
The `GZIP_COMPRESSION` option will save bandwidth and increase browsing speed.  
Normally, It is not necessary to be changed.

## Basic Authentication
Set `BASIC_AUTH` true if you want to use Basic Authentication.  
When `FORCE_SSL` is true, it will be used after the protocol is redirected to HTTPS.
