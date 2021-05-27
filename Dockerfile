FROM ubuntu:20.04
LABEL maintainer="Danila Lelyaev <danila.l@knowledgecity.pro>"

#ARG domain=kcexp.pro
ENV TZ=America/Los_Angeles

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
&& apt -yqq update \
&& apt -yqq install \
    wget \
    unzip \
    apache2 \
    php-fpm \
    php7.4-mbstring \
    php7.4-gd \
    php7.4-intl \
    php7.4-xml \
    php7.4-mysql \
    php7.4-zip \
    php7.4-curl \
    php-ssh2 \
    libapache2-mod-security2 \
    php-pear \
    php-dev \
    libmcrypt-dev \
    ffmpeg \
    sendmail \

&& pecl channel-update pecl.php.net \
&& pecl update-channels \
&& yes "" | pecl install mcrypt \
&& echo "extension=mcrypt.so" >> /etc/php/7.4/fpm/php.ini \

# removing default index.html file
&& unlink /var/www/html/index.html \
# backing up  apache config
&& cp /etc/apache2/apache2.conf /etc/apache2/apache2.conf.bak \
# changing some Apache & PHP  configuration.
&& sed -i "s/Options Indexes FollowSymLinks/Options FollowSymLinks/" /etc/apache2/apache2.conf \
&& sed -i "s/AllowOverride None/AllowOverride All/" /etc/apache2/apache2.conf \

&& a2enmod speling \
&& a2enmod ssl \
&& a2enmod rewrite \
&& a2enmod headers \
&& a2enmod reqtimeout \
&& a2ensite default-ssl \
&& a2enmod security2 \
&& a2enmod proxy_fcgi setenvif \
&& a2enconf php7.4-fpm \
&& a2enmod mpm_event \
&& a2enmod http2 \

# adding user and changing owner of the HTML folder to new user
&& newuser="deployuser" \
&& randompw=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1) \
&& useradd $newuser \
&& echo $newuser:$randompw | chpasswd \
&& mkdir /home/deployuser \
&& mkdir /home/deployuser/.ssh \
&& chown deployuser:deployuser /var/www/html/ -R \
&& chown deployuser:deployuser /home/deployuser -R \

# changing some PHP & Apache settings
&& sed -i "s/memory_limit.*/memory_limit = 1024M/" /etc/php/7.4/fpm/php.ini \
&& sed -i "s/post_max_size.*/post_max_size = 1024M/" /etc/php/7.4/fpm/php.ini \
&& sed -i "s/upload_max_filesize.*/upload_max_filesize = 1024M/" /etc/php/7.4/fpm/php.ini \
&& sed -i "s/listen.owner = www-data/listen.owner = deployuser/" /etc/php/7.4/fpm/pool.d/www.conf \
&& sed -i "s/export APACHE_RUN_USER=.*/export APACHE_RUN_USER=deployuser/" /etc/apache2/envvars \
&& sed -i "s/export APACHE_RUN_GROUP=.*/export APACHE_RUN_GROUP=deployuser/" /etc/apache2/envvars \
&& sed -i "s/listen.owner = www-data/listen.owner = deployuser/" /etc/php/7.4/fpm/pool.d/www.conf

COPY apache2.conf /etc/apache2/
COPY 000-default.conf /etc/apache2/sites-available/

RUN echo "#!/usr/bin/bash" > /start-script.sh \
# && sed -i "s/_domain.pro/$domain/" /etc/apache2/sites-available/000-default.conf \

&& echo "" >> /start-script.sh \
&& echo "/usr/sbin/php-fpm7.4" >> /start-script.sh \
#&& /usr/sbin/php-fpm7.4
&& echo "source /etc/apache2/envvars" >> /start-script.sh \
&& echo "/usr/sbin/apache2 -DFOREGROUND" >> /start-script.sh \
&& chmod 755 /start-script.sh

EXPOSE 80
#CMD  ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]

CMD ["/start-script.sh"]
