FROM centos
MAINTAINER "Hiroki Takeyama"

# timezone
RUN rm -f /etc/localtime; \
    ln -fs /usr/share/zoneinfo/Asia/Tokyo /etc/localtime;

# httpd
RUN yum -y install httpd mod_ssl; yum clean all; \
    sed -i 's/DocumentRoot "\/var\/www\/html"/DocumentRoot "\/usr\/share\/phpMyAdmin"/1' /etc/httpd/conf/httpd.conf; \
    sed -i 's/<Directory "\/var\/www\/html">/<Directory "\/usr\/share\/phpMyAdmin">"/1' /etc/httpd/conf/httpd.conf;

# PHP
RUN yum -y install epel-release; yum clean all; \
    rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm; \
    yum -y install --enablerepo=remi --enablerepo=remi-php72 php php-mbstring php-curl php-mysqlnd; yum clean all; \
    sed -i 's/^;date\.timezone =$/date\.timezone=Asia\/Tokyo/1' /etc/php.ini;

# phpMyAdmin
RUN yum -y install --enablerepo=remi,remi-php72 phpMyAdmin; yum clean all; \
    sed -i '/^<Directory \/usr\/share\/phpMyAdmin\/>$/,/^<Directory \/usr\/share\/phpMyAdmin\/setup\/>$/ s/Require local/Require all granted/1' /etc/httpd/conf.d/phpMyAdmin.conf; \
    { \
    echo '<Directory /usr/share/phpMyAdmin/>'; \
    echo '    AuthType Basic'; \
    echo '    AuthName "Basic Authentication"'; \
    echo '    AuthUserFile /usr/share/phpMyAdmin/.htpasswd'; \
    echo '    Require valid-user'; \
    echo '</Directory>'; \
    } >> /etc/httpd/conf.d/phpMyAdmin.conf;

# entrypoint
RUN mkdir /share; \
    chown -R apache:apache /share; \
    { \
    echo '#!/bin/bash -eu'; \
    echo '{'; \
    echo '    echo "\$cfg['\''Servers'\''][\$i]['\''auth_type'\''] = '\''config'\'';"'; \
    echo '    echo "\$cfg['\''Servers'\''][\$i]['\''host'\''] = '\''${PMA_HOST}'\'';"'; \
    echo '    echo "\$cfg['\''Servers'\''][\$i]['\''port'\''] = '\''${PMA_PORT}'\'';"'; \
    echo '    echo "\$cfg['\''Servers'\''][\$i]['\''user'\''] = '\''${PMA_USER}'\'';"'; \
    echo '    echo "\$cfg['\''Servers'\''][\$i]['\''password'\''] = '\''${PMA_PASSWORD}'\'';"'; \
    echo '    echo "\$cfg['\''UploadDir'\''] = '\''/share'\'';"'; \
    echo '    echo "\$cfg['\''SaveDir'\''] = '\''/share'\'';"'; \
    echo '} >> /etc/phpMyAdmin/config.inc.php'; \
    echo 'htpasswd -b -m -c /usr/share/phpMyAdmin/.htpasswd ${BASIC_AUTH_USER} ${BASIC_AUTH_PASSWORD}'; \
    echo 'exec "$@"'; \
    } > /usr/local/bin/entrypoint.sh; \
    chmod +x /usr/local/bin/entrypoint.sh;
ENTRYPOINT ["entrypoint.sh"]

ENV BASIC_AUTH_USER user
ENV BASIC_AUTH_PASSWORD user

ENV PMA_HOST 192.168.1.1
ENV PMA_PORT 3306
ENV PMA_USER root
ENV PMA_PASSWORD root

VOLUME /share

EXPOSE 80
EXPOSE 443

CMD ["httpd", "-DFOREGROUND"]
