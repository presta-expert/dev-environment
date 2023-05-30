ARG PRESTASHOP_VERSION

# Using specified PrestaShop version from .env
FROM prestashop/prestashop:$PRESTASHOP_VERSION

# Update stretch repositories
RUN sed -i -e 's/deb.debian.org/archive.debian.org/g' \
           -e 's|security.debian.org|archive.debian.org/|g' \
           -e '/stretch-updates/d' /etc/apt/sources.list

# Installing some additional packages
RUN apt update \
    && apt install -y \
    nano \
    apt-utils \
    mailutils \
    && rm -rf /var/lib/apt/lists/*

# Installing composer
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php \
    && mv composer.phar /usr/local/bin/composer \
    && chmod +x /usr/local/bin/composer \
    && php -r "unlink('composer-setup.php');"

# Installing phpunit
RUN wget -q https://phar.phpunit.de/phpunit.phar \
    && mv phpunit.phar /usr/local/bin/phpunit \
    && chmod +x /usr/local/bin/phpunit

# Installing ioncube loader for current php version
RUN curl -fSL 'https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz' -o ioncube.tar.gz \
    && mkdir -p /usr/share/ioncube \
    && tar -xf ioncube.tar.gz -C /usr/share/ioncube --strip-components=1 \
    && rm ioncube.tar.gz \
    && export IONCUBE_PHP_VERSION=$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;') \
    && echo "zend_extension = /usr/share/ioncube/ioncube_loader_lin_$IONCUBE_PHP_VERSION.so" > /usr/local/etc/php/conf.d/00_ioncube.ini

# Installing mhsendmail to make MailHog work with php mail by default
RUN wget -q https://github.com/mailhog/mhsendmail/releases/download/v0.2.0/mhsendmail_linux_amd64 \
    && mv mhsendmail_linux_amd64 /usr/local/bin/mhsendmail \
    && chmod +x /usr/local/bin/mhsendmail

# Copying our php.ini which will override some values
COPY .docker/config/php.ini /usr/local/etc/php/conf.d/custom.ini
