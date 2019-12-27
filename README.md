# phpmyadmin
[![Docker Stars](https://img.shields.io/docker/stars/takeyamajp/phpmyadmin.svg)](https://hub.docker.com/r/takeyamajp/phpmyadmin/)
[![Docker Pulls](https://img.shields.io/docker/pulls/takeyamajp/phpmyadmin.svg)](https://hub.docker.com/r/takeyamajp/phpmyadmin/)
[![license](https://img.shields.io/github/license/takeyamajp/docker-phpmyadmin.svg)](https://github.com/takeyamajp/docker-phpmyadmin/blob/master/LICENSE)

### Supported tags and respective Dockerfile links  
- [`latest`, `centos8`](https://github.com/takeyamajp/docker-phpmyadmin/blob/master/centos8/Dockerfile)
- [`centos7`](https://github.com/takeyamajp/docker-phpmyadmin/blob/master/centos7/Dockerfile)

### Image summary
    FROM centos:centos8  
    MAINTAINER "Hiroki Takeyama"
    
    ENV TIMEZONE Asia/Tokyo
    
    ENV REQUIRE_SSL true  
    ENV GZIP_COMPRESSION true
    
    ENV BASIC_AUTH false  
    ENV BASIC_AUTH_USER user  
    ENV BASIC_AUTH_PASSWORD user
    
    ENV HTTPD_LOG true  
    ENV HTTPD_LOG_LEVEL warn  
    ENV HTTPD_PHP_ERROR_LOG true
    
    ENV PMA_HOST mysql  
    ENV PMA_PORT 3306  
    ENV PMA_USER user  
    ENV PMA_PASSWORD password
    
    VOLUME /export
    
    EXPOSE 80  
    EXPOSE 443
