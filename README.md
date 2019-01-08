# phpmyadmin
[![Docker Stars](https://img.shields.io/docker/stars/takeyamajp/phpmyadmin.svg)](https://hub.docker.com/r/takeyamajp/phpmyadmin/)
[![Docker Pulls](https://img.shields.io/docker/pulls/takeyamajp/phpmyadmin.svg)](https://hub.docker.com/r/takeyamajp/phpmyadmin/)
[![](https://img.shields.io/badge/GitHub-Dockerfile-orange.svg)](https://github.com/takeyamajp/docker-phpmyadmin/blob/master/Dockerfile)
[![license](https://img.shields.io/github/license/takeyamajp/docker-phpmyadmin.svg)](https://github.com/takeyamajp/docker-phpmyadmin/blob/master/LICENSE)

    FROM centos:centos7  
    MAINTAINER "Hiroki Takeyama"
    
    ENV TIMEZONE Asia/Tokyo
    
    ENV REQUIRE_SSL true  
    ENV ENABLE_GZIP_COMPRESSION true
    
    ENV REQUIRE_BASIC_AUTH false  
    ENV BASIC_AUTH_USER user  
    ENV BASIC_AUTH_PASSWORD user
    
    ENV HTTPD_LOGGING true  
    ENV HTTPD_LOG_LEVEL warn
    
    ENV PHP_ERROR_LOGGING true
    
    ENV PMA_HOST mysql  
    ENV PMA_PORT 3306  
    ENV PMA_USER root  
    ENV PMA_PASSWORD root
    
    VOLUME /export
    
    EXPOSE 80  
    EXPOSE 443
