####################################
# PHPDocker.io PHP 7.1 / FPM image #
####################################

FROM phpdockerio/php71-cli

# Install FPM
RUN apt-get update \
    && apt-get -y --no-install-recommends install php7.1-fpm \
    && apt-get -y --no-install-recommends install php7.1-mbstring \
    && apt-get -y --no-install-recommends install php7.1-mysql \
    && apt-get -y --no-install-recommends install php7.1-gmp \
    && apt-get -y --no-install-recommends install php7.1-mcrypt \
    && apt-get -y --no-install-recommends install php-xdebug \
    && apt-get -y --no-install-recommends install wget \
    && apt-get -y --no-install-recommends install php7.1-gd \
    && apt-get -y --no-install-recommends install imagemagick \
    && apt-get -y --no-install-recommends install php-imagick \
    && apt-get -y --no-install-recommends install ffmpeg \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*


RUN wget https://getcomposer.org/installer --no-check-certificate
RUN php installer
RUN ln -s /composer.phar /usr/bin/composer

# Configure FPM to run properly on docker
RUN sed -i "/listen = .*/c\listen = [::]:9000" /etc/php/7.1/fpm/pool.d/www.conf \
    && sed -i "/;access.log = .*/c\access.log = /proc/self/fd/1" /etc/php/7.1/fpm/pool.d/www.conf \
    && sed -i "/;clear_env = .*/c\clear_env = no" /etc/php/7.1/fpm/pool.d/www.conf \
    && sed -i "/;catch_workers_output = .*/c\catch_workers_output = yes" /etc/php/7.1/fpm/pool.d/www.conf \
    && sed -i "/pid = .*/c\;pid = /run/php/php7.1-fpm.pid" /etc/php/7.1/fpm/php-fpm.conf \
    && sed -i "/;daemonize = .*/c\daemonize = no" /etc/php/7.1/fpm/php-fpm.conf \
    && sed -i "/error_log = .*/c\error_log = /proc/self/fd/2" /etc/php/7.1/fpm/php-fpm.conf \
    && usermod -u 1000 www-data


RUN mkdir -p /var/www/.config/psysh
RUN chown -R www-data:www-data /var/www/.config
RUN chmod -R 755 /var/www/.config

# The following runs FPM and removes all its extraneous log output on top of what your app outputs to stdout
CMD /usr/sbin/php-fpm7.1 -F -O 2>&1 | sed -u 's,.*: \"\(.*\)$,\1,'| sed -u 's,"$,,' 1>&1

# Open up fcgi port
EXPOSE 9000