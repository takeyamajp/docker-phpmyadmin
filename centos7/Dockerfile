FROM centos:centos7
MAINTAINER "Hiroki Takeyama"

# certificate
RUN mkdir /cert; \
    yum -y install openssl; \
    openssl genrsa -aes256 -passout pass:dummy -out "/cert/key.pass.pem" 2048; \
    openssl rsa -passin pass:dummy -in "/cert/key.pass.pem" -out "/cert/key.pem"; \
    rm -f /cert/key.pass.pem; \
    yum clean all;

# httpd (ius for CentOS7)
RUN yum -y install system-logos mailcap; \
    yum -y install "https://repo.ius.io/ius-release-el7.rpm"; \
    yum -y install --disablerepo=base,extras,updates --enablerepo=ius httpd mod_ssl; \
    sed -i 's/^#\(ServerName\) .*/\1 ${HOSTNAME}/' /etc/httpd/conf/httpd.conf; \
    sed -i 's/\(DocumentRoot\) "\/var\/www\/html"/\1 "\/usr\/share\/phpMyAdmin"/' /etc/httpd/conf/httpd.conf; \
    sed -i '/^<Directory "\/var\/www\/html">$/,/^<IfModule dir_module>$/ s/\(AllowOverride\) None/\1 All/' /etc/httpd/conf/httpd.conf; \
    sed -i 's/\(<Directory\) "\/var\/www\/html">/\1 "\/usr\/share\/phpMyAdmin">/' /etc/httpd/conf/httpd.conf; \
    sed -i 's/^\s*\(CustomLog\) .*/\1 \/dev\/stdout "%{X-Forwarded-For}i %h %l %u %t \\"%r\\" %>s %b \\"%{Referer}i\\" \\"%{User-Agent}i\\" %I %O"/' /etc/httpd/conf/httpd.conf; \
    sed -i 's/^\(ErrorLog\) .*/\1 \/dev\/stderr/' /etc/httpd/conf/httpd.conf; \
    sed -i 's/^\s*\(CustomLog\) .*/\1 \/dev\/stdout "%{X-Forwarded-For}i %h %l %u %t \\"%r\\" %>s %b \\"%{Referer}i\\" \\"%{User-Agent}i\\" %I %O"/' /etc/httpd/conf.d/ssl.conf; \
    sed -i 's/^\(ErrorLog\) .*/\1 \/dev\/stderr/' /etc/httpd/conf.d/ssl.conf; \
    sed -i 's/^\s*"%t %h %{SSL_PROTOCOL}x %{SSL_CIPHER}x \\"%r\\" %b"//' /etc/httpd/conf.d/ssl.conf; \
    sed -i 's/^\(LoadModule http2_module .*\)/#\1/' /etc/httpd/conf.modules.d/00-base.conf; \
    rm -f /etc/httpd/conf.modules.d/00-proxy.conf; \
    rm -f /usr/sbin/suexec; \
    yum clean all;

# PHP (remi for CentOS7)
RUN yum -y install epel-release; \
    rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm; \
    yum -y install --disablerepo=ius --enablerepo=remi,remi-php72 php php-mbstring php-curl php-mysqlnd php-opcache php-pecl-apcu; \
    sed -i 's/^;\(error_log\) .*/\1 = \/dev\/stderr/' /etc/php.ini; \
    yum clean all;

# phpMyAdmin (remi for CentOS7)
RUN mkdir /export; \
    yum -y install --disablerepo=ius --enablerepo=remi,remi-php72 phpMyAdmin; \
    sed -i '/^<Directory \/usr\/share\/phpMyAdmin\/>$/,/^<Directory \/usr\/share\/phpMyAdmin\/setup\/>$/ s/\(Require\) local/\1 all granted/' /etc/httpd/conf.d/phpMyAdmin.conf; \
    yum clean all;

# entrypoint
RUN { \
    echo '#!/bin/bash -eu'; \
    echo 'ln -fs /usr/share/zoneinfo/${TIMEZONE} /etc/localtime'; \
    echo 'ESC_TIMEZONE=`echo ${TIMEZONE} | sed "s/\//\\\\\\\\\//g"`'; \
    echo 'sed -i "s/^;\?\(date\.timezone\) =.*/\1 =${ESC_TIMEZONE}/" /etc/php.ini'; \
    echo 'openssl req -new -sha384 -key "/cert/key.pem" -subj "/CN=${HOSTNAME}" -out "/cert/csr.pem"'; \
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
    echo 'if [ -e /etc/httpd/conf.d/forceSsl.conf ]; then'; \
    echo '  rm -f /etc/httpd/conf.d/forceSsl.conf'; \
    echo 'fi'; \
    echo 'if [ ${FORCE_SSL,,} = "true" ]; then'; \
    echo '  {'; \
    echo '  echo "<IfModule mod_rewrite.c>"'; \
    echo '  echo "  RewriteEngine On"'; \
    echo '  echo "  RewriteCond %{HTTPS} off"'; \
    echo '  echo "  RewriteCond %{HTTP:X-Forwarded-Proto} !https [NC]"'; \
    echo '  echo "  RewriteRule ^.*$ https://%{HTTP_HOST}%{REQUEST_URI} [R=301,L]"'; \
    echo '  echo "</IfModule>"'; \
    echo '  } > /etc/httpd/conf.d/forceSsl.conf'; \
    echo 'fi'; \
    echo 'if [ -e /etc/httpd/conf.d/gzipCompression.conf ]; then'; \
    echo '  rm -f /etc/httpd/conf.d/gzipCompression.conf'; \
    echo 'fi'; \
    echo 'if [ ${GZIP_COMPRESSION,,} = "true" ]; then'; \
    echo '  {'; \
    echo '  echo "<IfModule mod_deflate.c>"'; \
    echo '  echo "<IfModule mod_filter.c>"'; \
    echo '  echo "  SetOutputFilter DEFLATE"'; \
    echo '  echo "  SetEnvIfNoCase Request_URI \.(?:gif|jpe?g|png)$ no-gzip dont-vary"'; \
    echo '  echo "</IfModule>"'; \
    echo '  echo "</IfModule>"'; \
    echo '  } > /etc/httpd/conf.d/gzipCompression.conf'; \
    echo 'fi'; \
    echo 'if [ -e /etc/httpd/conf.d/.htpasswd ]; then'; \
    echo '  sed -i '\''/^# BEGIN BASIC AUTH$/,/^# END BASIC AUTH$/d'\'' /etc/httpd/conf.d/phpMyAdmin.conf'; \
    echo '  rm -f /etc/httpd/conf.d/.htpasswd'; \
    echo 'fi'; \
    echo 'if [ ${BASIC_AUTH,,} = "true" ]; then'; \
    echo '  {'; \
    echo '  echo "# BEGIN BASIC AUTH"'; \
    echo '  echo "<Directory /usr/share/phpMyAdmin/>"'; \
    echo '  if [ ${FORCE_SSL,,} = "true" ]; then'; \
    echo '    echo "<If \"%{HTTPS} = '\''on'\''\">"'; \
    echo '  fi'; \
    echo '  echo "  AuthType Basic"'; \
    echo '  echo "  AuthName '\''Basic Authentication'\''"'; \
    echo '  echo "  AuthUserFile /etc/httpd/conf.d/.htpasswd"'; \
    echo '  echo "  Require valid-user"'; \
    echo '  if [ ${FORCE_SSL,,} = "true" ]; then'; \
    echo '    echo "</If>"'; \
    echo '  fi'; \
    echo '  echo "</Directory>"'; \
    echo '  echo "# END BASIC AUTH"'; \
    echo '  } >> /etc/httpd/conf.d/phpMyAdmin.conf'; \
    echo '  htpasswd -bmc /etc/httpd/conf.d/.htpasswd ${BASIC_AUTH_USER} ${BASIC_AUTH_PASSWORD} &>/dev/null'; \
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
    echo 'chown -R apache:apache /export'; \
    echo 'exec "$@"'; \
    } > /usr/local/bin/entrypoint.sh; \
    chmod +x /usr/local/bin/entrypoint.sh;

ENV TIMEZONE Asia/Tokyo

ENV FORCE_SSL true
ENV GZIP_COMPRESSION true

ENV BASIC_AUTH false
ENV BASIC_AUTH_USER user
ENV BASIC_AUTH_PASSWORD password

ENV HTTPD_LOG true
ENV HTTPD_LOG_LEVEL warn
ENV HTTPD_PHP_ERROR_LOG true

ENV PMA_HOST mysql
ENV PMA_PORT 3306
ENV PMA_USER root
ENV PMA_PASSWORD password

VOLUME /export

EXPOSE 80
EXPOSE 443

ENTRYPOINT ["entrypoint.sh"]
CMD ["httpd", "-DFOREGROUND"]
