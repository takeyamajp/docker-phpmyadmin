FROM centos:centos8
MAINTAINER "Hiroki Takeyama"

# certificate
RUN mkdir /cert; \
    dnf -y install openssl; \
    openssl genrsa -aes128 -passout pass:dummy -out "/cert/key.pass.pem" 2048; \
    openssl rsa -passin pass:dummy -in "/cert/key.pass.pem" -out "/cert/key.pem"; \
    rm -f /cert/key.pass.pem; \
    dnf clean all;

# httpd
RUN dnf -y install httpd mod_ssl; \
    sed -i 's/^#\(ServerName\) .*/\1 ${HOSTNAME}/' /etc/httpd/conf/httpd.conf; \
    sed -i 's/\(DocumentRoot\) "\/var\/www\/html"/\1 "\/usr\/share\/phpMyAdmin"/' /etc/httpd/conf/httpd.conf; \
    sed -i '/^<Directory "\/var\/www\/html">$/,/^<IfModule dir_module>$/ s/\(AllowOverride\) None/\1 All/' /etc/httpd/conf/httpd.conf; \
    sed -i 's/\(<Directory\) "\/var\/www\/html">/\1 "\/usr\/share\/phpMyAdmin">/' /etc/httpd/conf/httpd.conf; \
    sed -i 's/^\s*\(CustomLog\) .*/\1 \/dev\/stdout "%{X-Forwarded-For}i %h %l %u %t \\"%r\\" %>s %b \\"%{Referer}i\\" \\"%{User-Agent}i\\" %I %O"/' /etc/httpd/conf/httpd.conf; \
    sed -i 's/^\(ErrorLog\) .*/\1 \/dev\/stderr/' /etc/httpd/conf/httpd.conf; \
    sed -i 's/^\s*\(CustomLog\) .*/\1 \/dev\/stdout "%{X-Forwarded-For}i %h %l %u %t \\"%r\\" %>s %b \\"%{Referer}i\\" \\"%{User-Agent}i\\" %I %O"/' /etc/httpd/conf.d/ssl.conf; \
    sed -i 's/^\(ErrorLog\) .*/\1 \/dev\/stderr/' /etc/httpd/conf.d/ssl.conf; \
    sed -i 's/^\s*"%t %h %{SSL_PROTOCOL}x %{SSL_CIPHER}x \\"%r\\" %b"//' /etc/httpd/conf.d/ssl.conf; \
    sed -i 's/^\(LoadModule lbmethod_heartbeat_module .*\)/#\1/' /etc/httpd/conf.modules.d/00-proxy.conf; \
    rm -f /usr/sbin/suexec; \
    dnf clean all;

# PHP (remi)
RUN dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm; \
    dnf -y install https://rpms.remirepo.net/enterprise/remi-release-8.rpm; \
    dnf module enable php:remi-7.4; \
    dnf -y install php php-mbstring php-curl php-mysqlnd php-opcache php-pecl-apcu; \
    sed -i 's/^;\(error_log\) .*/\1 = \/dev\/stderr/' /etc/php.ini; \
    dnf clean all;

# phpMyAdmin (remi)
RUN mkdir /export; \
    dnf -y install --enablerepo=remi phpMyAdmin; \
    sed -i '/^<Directory \/usr\/share\/phpMyAdmin\/>$/,/^<Directory \/usr\/share\/phpMyAdmin\/setup\/>$/ s/\(Require\) local/\1 all granted/' /etc/httpd/conf.d/phpMyAdmin.conf; \
    dnf clean all;

# entrypoint
RUN { \
    echo '#!/bin/bash -eu'; \
    echo 'rm -f /etc/localtime'; \
    echo 'ln -fs /usr/share/zoneinfo/${TIMEZONE} /etc/localtime'; \
    echo 'ESC_TIMEZONE=`echo ${TIMEZONE} | sed "s/\//\\\\\\\\\//g"`'; \
    echo 'sed -i "s/^;\?\(date\.timezone\) =.*/\1 =${ESC_TIMEZONE}/" /etc/php.ini'; \
    echo 'openssl req -new -key "/cert/key.pem" -subj "/CN=${HOSTNAME}" -out "/cert/csr.pem"'; \
    echo 'openssl x509 -req -days 36500 -in "/cert/csr.pem" -signkey "/cert/key.pem" -out "/cert/cert.pem" &>/dev/null'; \
    echo 'sed -i "s/^\(SSLCertificateFile\) .*/\1 \/cert\/cert.pem/" /etc/httpd/conf.d/ssl.conf'; \
    echo 'sed -i "s/^\(SSLCertificateKeyFile\) .*/\1 \/cert\/key.pem/" /etc/httpd/conf.d/ssl.conf'; \
    echo 'if [ -e /export/cert.pem ] && [ -e /export/key.pem ]; then'; \
    echo '  sed -i "s/^\(SSLCertificateFile\) .*/\1 \/export\/cert.pem/" /etc/httpd/conf.d/ssl.conf'; \
    echo '  sed -i "s/^\(SSLCertificateKeyFile\) .*/\1 \/export\/key.pem/" /etc/httpd/conf.d/ssl.conf'; \
    echo 'fi'; \
    echo 'sed -i "s/^\(LogLevel\) .*/\1 ${HTTPD_LOG_LEVEL}/" /etc/httpd/conf/httpd.conf'; \
    echo 'sed -i "s/^\(LogLevel\) .*/\1 ${HTTPD_LOG_LEVEL}/" /etc/httpd/conf.d/ssl.conf'; \
    echo 'sed -i "s/^\(CustomLog .*\)/#\1/" /etc/httpd/conf/httpd.conf'; \
    echo 'sed -i "s/^\(ErrorLog .*\)/#\1/" /etc/httpd/conf/httpd.conf'; \
    echo 'sed -i "s/^\(CustomLog .*\)/#\1/" /etc/httpd/conf.d/ssl.conf'; \
    echo 'sed -i "s/^\(ErrorLog .*\)/#\1/" /etc/httpd/conf.d/ssl.conf'; \
    echo 'if [ ${HTTPD_LOG,,} = "true" ]; then'; \
    echo '  sed -i "s/^#\(CustomLog .*\)/\1/" /etc/httpd/conf/httpd.conf'; \
    echo '  sed -i "s/^#\(ErrorLog .*\)/\1/" /etc/httpd/conf/httpd.conf'; \
    echo '  sed -i "s/^#\(CustomLog .*\)/\1/" /etc/httpd/conf.d/ssl.conf'; \
    echo '  sed -i "s/^#\(ErrorLog .*\)/\1/" /etc/httpd/conf.d/ssl.conf'; \
    echo 'fi'; \
    echo 'sed -i "s/^\(log_errors\) .*/\1 = Off/" /etc/php.ini'; \
    echo 'if [ ${HTTPD_PHP_ERROR_LOG,,} = "true" ]; then'; \
    echo '  sed -i "s/^\(log_errors\) .*/\1 = On/" /etc/php.ini'; \
    echo 'fi'; \
    echo 'if [ -e /usr/share/phpMyAdmin/.htaccess ]; then'; \
    echo '  sed -i '\''/^# BEGIN REQUIRE SSL$/,/^# END REQUIRE SSL$/d'\'' /usr/share/phpMyAdmin/.htaccess'; \
    echo '  sed -i '\''/^# BEGIN GZIP COMPRESSION$/,/^# END GZIP COMPRESSION$/d'\'' /usr/share/phpMyAdmin/.htaccess'; \
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
    echo 'if [ ${GZIP_COMPRESSION,,} = "true" ]; then'; \
    echo '  {'; \
    echo '  echo "# BEGIN GZIP COMPRESSION"'; \
    echo '  echo "<IfModule mod_deflate.c>"'; \
    echo '  echo "<IfModule mod_filter.c>"'; \
    echo '  echo "  SetOutputFilter DEFLATE"'; \
    echo '  echo "  SetEnvIfNoCase Request_URI \.(?:gif|jpe?g|png)$ no-gzip dont-vary"'; \
    echo '  echo "</IfModule>"'; \
    echo '  echo "</IfModule>"'; \
    echo '  echo "# END GZIP COMPRESSION"'; \
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
    echo 'echo "\$cfg['\''UploadDir'\''] = '\''/export'\'';"'; \
    echo 'echo "\$cfg['\''SaveDir'\''] = '\''/export'\'';"'; \
    echo 'echo "# END DB SETTINGS"'; \
    echo '} >> /etc/phpMyAdmin/config.inc.php'; \
    echo 'if [ -e /usr/share/phpMyAdmin/.htpasswd ]; then'; \
    echo '  sed -i '\''/^# BEGIN BASIC AUTH$/,/^# END BASIC AUTH$/d'\'' /etc/httpd/conf.d/phpMyAdmin.conf'; \
    echo '  rm -f /usr/share/phpMyAdmin/.htpasswd'; \
    echo 'fi'; \
    echo 'if [ ${BASIC_AUTH,,} = "true" ]; then'; \
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
    echo 'chown -R apache:apache /export'; \
    echo 'exec "$@"'; \
    } > /usr/local/bin/entrypoint.sh; \
    chmod +x /usr/local/bin/entrypoint.sh;
ENTRYPOINT ["entrypoint.sh"]

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
ENV PMA_USER root
ENV PMA_PASSWORD root

VOLUME /export

EXPOSE 80
EXPOSE 443

CMD ["httpd", "-DFOREGROUND"]
