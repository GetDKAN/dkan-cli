ARG BASE_IMAGE_TAG

FROM drydockcloud/${BASE_IMAGE_TAG}:latest

ARG DRUSH_VER

ENV DEBIAN_FRONTEND=noninteractive
ENV PHP_INI_SCAN_DIR="/usr/local/php/etc/conf.d:/var/www/src/docker/etc/php"

RUN \
  apt-get update &&\
  apt-get upgrade -y &&\
  # Add Nodejs source.
  curl -sL https://deb.nodesource.com/setup_14.x | bash &&\
  apt-get update &&\
  # Install basic tools/packages.
  apt-get install -y apt-transport-https git pv patch vim zip unzip chromium-browser \
  # Install Cypress.io requirements
  xvfb libgtk2.0-0 libnotify-dev libgconf-2-4 libnss3 libxss1 libasound2 \
  # Drush dependencies.
  mysql-client \
  # Install AWS CLI.
  awscli \
  # Install ClamAV.
  clamav \
  # Install cmake
  cmake \
  # Install flex
  flex \
  # Install bison
  bison \
  # Install Node JS.
  nodejs &&\
  # Cleanup.
  apt-get clean &&\
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install doxygen
ENV PATH /usr/local/bin:$PATH
RUN wget https://github.com/doxygen/doxygen/archive/refs/tags/Release_1_8_19.tar.gz && \
  tar xzvf Release_1_8_19.tar.gz && \
  cd doxygen-Release_1_8_19 && \
  mkdir build && \
  cd build && \
  cmake -G "Unix Makefiles" ..  && \
  make && \
  make install && \
  cd ../../ && \
  rm -rf doxygen-Release_1_8_19

# Install Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" &&\
  php composer-setup.php &&\
  php -r "unlink('composer-setup.php');" &&\
  mv composer.phar /usr/bin/composer &&\
  chmod +x /usr/bin/composer

# Allow composer superuser and set environment to use composer executables path
ENV COMPOSER_ALLOW_SUPERUSER 1
ENV PATH "$PATH:/root/.config/composer/vendor/bin"

# Allow plugins
RUN composer global config --no-plugins allow-plugins.dealerdirect/phpcodesniffer-composer-installer true

# Install Drush, PHPCS and Drupal Coding Standards
RUN composer global require "drush/drush:$DRUSH_VER" squizlabs/php_codesniffer drupal/coder && \
  # Set Drupal as default CodeSniffer Standard
  phpcs --config-set installed_paths /root/.composer/vendor/drupal/coder/coder_sniffer/ &&\
  phpcs --config-set default_standard Drupal

# Move .composer to give way to the user's .composer config. Make sure to
# update the PATH.
RUN mv /root/.config/composer /root/composer
ENV PATH /root/composer/vendor/bin:$PATH

# Add git completion for the cli
RUN curl -o ~/.git-completion.bash https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash &&\
  curl -o ~/.git-prompt.sh https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh

# Add local settings
COPY php-cli.ini /usr/local/php/etc/fpm/conf.d/z_php.ini
COPY bash.rc /root/.bashrc
# Startup script
COPY ./startup.sh /opt/startup.sh

ENTRYPOINT ["/opt/startup.sh"]
CMD ["/usr/local/php/sbin/php-fpm"]
