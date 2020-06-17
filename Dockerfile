ARG BASE_IMAGE_TAG

FROM ubuntu:${BASE_IMAGE_TAG}

ARG DRUSH_VER

RUN apt-get update
RUN apt-get install software-properties-common -y
RUN apt-get update


# The basics
RUN apt-get install -y \
  supervisor \
  curl \
  wget \
  unzip \
  locales \
  git \
  pv \
  apt-transport-https \
  vim \
  patch \
  zip

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Cypress.io requirements
RUN apt update
RUN DEBIAN_FRONTEND=noninteractive apt install xvfb libgtk2.0-0 libnotify-dev libgconf-2-4 libnss3 libxss1 libasound2 -y

# PHP
RUN apt update && apt-get update && apt install apache2 -y && \
    apt install mysql-server -y && \
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:ondrej/php && \
    DEBIAN_FRONTEND=noninteractive apt install php7.3 -y && \
    DEBIAN_FRONTEND=noninteractive apt install php7.3-dev php7.3-cli php7.3-common php7.3-curl php7.3-gd php7.3-json php7.3-opcache php7.3-mysql php7.3-mbstring php7.3-zip php7.3-xml php7.3-xdebug -y

RUN update-alternatives --set php /usr/bin/php7.3 && \
    update-alternatives --set phar /usr/bin/phar7.3 && \
    update-alternatives --set phar.phar /usr/bin/phar.phar7.3 && \
    update-alternatives --set phpize /usr/bin/phpize7.3 && \
    update-alternatives --set php-config /usr/bin/php-config7.3

# Disable loading of xdebug.so
RUN rm -f /etc/php/7.3/cli/conf.d/20-xdebug.ini

# Install AWS CLI
RUN apt-get install -y awscli

# Install ClamAV
RUN apt-get install -y clamav

# Install Nodejs and Ruby
RUN curl -sL https://deb.nodesource.com/setup_13.x | bash
RUN apt-get install -y nodejs

# Cleanup
RUN DEBIAN_FRONTEND=noninteractive apt-get clean && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"
RUN mv composer.phar /usr/bin/composer
RUN chmod +x /usr/bin/composer

# Allow composer superuser and set environment to use composer executables path
ENV COMPOSER_ALLOW_SUPERUSER 1
ENV PATH "$PATH:/root/.composer/vendor/bin"

# Install Drush, PHPCS and Drupal Coding Standards
RUN composer global require "drush/drush:$DRUSH_VER"
RUN composer global require squizlabs/php_codesniffer
RUN composer global require drupal/coder

# Set Drupal as default CodeSniffer Standard
RUN phpcs --config-set installed_paths /root/.composer/vendor/drupal/coder/coder_sniffer/
RUN phpcs --config-set default_standard Drupal

# Move .composer to give way to the user's .composer config
RUN mv /root/.composer /root/composer

# Add local settings
COPY php-cli.ini /etc/php/7.3/cli/conf.d/z_php.ini

# Add git completion for the cli
RUN curl -o ~/.git-completion.bash https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash
RUN curl -o ~/.git-prompt.sh https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh
COPY bash.rc /root/.bashrc

WORKDIR /var/www

# Add Composer bin directory to PATH
ENV PATH /root/composer/vendor/bin:$PATH

# Startup script
COPY ./startup.sh /opt/startup.sh
RUN chmod +x /opt/startup.sh

# Starter script
ENTRYPOINT ["/opt/startup.sh"]

ENV PHP_INI_SCAN_DIR="/etc/php/7.3/cli/conf.d:/var/www/src/docker/etc/php"

# By default, launch supervisord to keep the container running.
CMD /usr/bin/supervisord -n
