FROM centos:centos7
MAINTAINER "Hiroki Takeyama"

# httpd (ius for CentOS7)
RUN yum -y install system-logos openssl mailcap; yum clean all; \
    yum -y install "https://centos7.iuscommunity.org/ius-release.rpm"; yum clean all; \
    yum -y install --disablerepo=base,extras,updates --enablerepo=ius httpd mod_ssl; yum clean all; \
    sed -i 's/DocumentRoot "\/var\/www\/html"/DocumentRoot "\/usr\/share\/phpMyAdmin"/1' /etc/httpd/conf/httpd.conf; \
    sed -i '/^<Directory "\/var\/www\/html">$/,/^<IfModule dir_module>$/ s/AllowOverride None/AllowOverride All/1' /etc/httpd/conf/httpd.conf; \
    sed -i 's/<Directory "\/var\/www\/html">/<Directory "\/usr\/share\/phpMyAdmin">"/1' /etc/httpd/conf/httpd.conf;

# prevent error AH00558 on stdout
RUN echo 'ServerName ${HOSTNAME}' >> /etc/httpd/conf.d/additional.conf;

# PHP (remi for CentOS7)
RUN yum -y install epel-release; yum clean all; \
    rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm; \
    yum -y install --disablerepo=ius --enablerepo=remi,remi-php72 php php-mbstring php-curl php-mysqlnd php-opcache php-pecl-apcu; yum clean all;

# phpMyAdmin
RUN yum -y install --disablerepo=ius --enablerepo=remi,remi-php72 phpMyAdmin; yum clean all; \
    sed -i '/^<Directory \/usr\/share\/phpMyAdmin\/>$/,/^<Directory \/usr\/share\/phpMyAdmin\/setup\/>$/ s/Require local/Require all granted/1' /etc/httpd/conf.d/phpMyAdmin.conf;

# entrypoint
RUN mkdir /backup; \
    { \
    echo '#!/bin/bash -eu'; \
    echo 'rm -f /etc/localtime'; \
    echo 'ln -fs /usr/share/zoneinfo/${TIMEZONE} /etc/localtime'; \
    echo 'sed -i "s/^;*date\.timezone =\.*\$/date\.timezone=${TIMEZONE}/1" /etc/php.ini'; \
    echo 'if [ -e /usr/share/phpMyAdmin/.htaccess ]; then'; \
    echo '  sed -i '\''/^# BEGIN REQUIRE SSL$/,/^# END REQUIRE SSL$/d'\'' /usr/share/phpMyAdmin/.htaccess'; \
    echo 'fi'; \
    echo 'if [ ${REQUIRE_SSL,,} = "true" ]; then'; \
    echo '  {'; \
    echo '  echo "# BEGIN REQUIRE SSL"'; \
    echo '  echo "<IfModule mod_rewrite.c>"'; \
    echo '  echo "  RewriteEngine On"'; \
    echo '  echo "  RewriteCond %{HTTPS} off"'; \
    echo '  echo "  RewriteCond %{HTTP:X-Forwarded-Proto} !https [NC]"'; \
    echo '  echo "  RewriteRule ^.*$ https://%{HTTP_HOST}%{REQUEST_URI} [R=301,L]"'; \
    echo '  echo "</IfModule>"'; \
    echo '  echo "# END REQUIRE SSL"'; \
    echo '  } >> /usr/share/phpMyAdmin/.htaccess'; \
    echo 'fi'; \
    echo 'sed -i '\''/^# BEGIN DB SETTINGS$/,/^# END DB SETTINGS$/d'\'' /etc/phpMyAdmin/config.inc.php'; \
    echo '{'; \
    echo 'echo "# BEGIN DB SETTINGS"'; \
    echo 'echo "\$cfg['\''Servers'\''][\$i]['\''auth_type'\''] = '\''config'\'';"'; \
    echo 'echo "\$cfg['\''Servers'\''][\$i]['\''host'\''] = '\''${PMA_HOST}'\'';"'; \
    echo 'echo "\$cfg['\''Servers'\''][\$i]['\''port'\''] = '\''${PMA_PORT}'\'';"'; \
    echo 'echo "\$cfg['\''Servers'\''][\$i]['\''user'\''] = '\''${PMA_USER}'\'';"'; \
    echo 'echo "\$cfg['\''Servers'\''][\$i]['\''password'\''] = '\''${PMA_PASSWORD}'\'';"'; \
    echo 'echo "\$cfg['\''UploadDir'\''] = '\''/backup'\'';"'; \
    echo 'echo "\$cfg['\''SaveDir'\''] = '\''/backup'\'';"'; \
    echo 'echo "# END DB SETTINGS"'; \
    echo '} >> /etc/phpMyAdmin/config.inc.php'; \
    echo 'if [ -e /usr/share/phpMyAdmin/.htpasswd ]; then'; \
    echo '  sed -i '\''/^# BEGIN BASIC AUTH$/,/^# END BASIC AUTH$/d'\'' /etc/httpd/conf.d/phpMyAdmin.conf'; \
    echo '  rm -f /usr/share/phpMyAdmin/.htpasswd'; \
    echo 'fi'; \
    echo 'if [ ${REQUIRE_BASIC_AUTH,,} = "true" ]; then'; \
    echo '  {'; \
    echo '  echo "# BEGIN BASIC AUTH"'; \
    echo '  echo "<Directory /usr/share/phpMyAdmin/>"'; \
    echo '  echo "  AuthType Basic"'; \
    echo '  echo "  AuthName '\''Basic Authentication'\''"'; \
    echo '  echo "  AuthUserFile /usr/share/phpMyAdmin/.htpasswd"'; \
    echo '  echo "  Require valid-user"'; \
    echo '  echo "</Directory>"'; \
    echo '  echo "# END BASIC AUTH"'; \
    echo '  } >> /etc/httpd/conf.d/phpMyAdmin.conf'; \
    echo '  htpasswd -bmc /usr/share/phpMyAdmin/.htpasswd ${BASIC_AUTH_USER} ${BASIC_AUTH_PASSWORD} &>/dev/null'; \
    echo 'fi'; \
    echo 'chown -R apache:apache /backup'; \
    echo 'cp /etc/php.ini /backup/php.ini'; \
    echo 'timedatectl > /backup/timezone.txt'; \
    echo 'exec "$@"'; \
    } > /usr/local/bin/entrypoint.sh; \
    chmod +x /usr/local/bin/entrypoint.sh;
ENTRYPOINT ["entrypoint.sh"]

ENV TIMEZONE Asia/Tokyo

ENV REQUIRE_SSL true

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

CMD ["httpd", "-DFOREGROUND"]
