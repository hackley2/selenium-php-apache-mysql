FROM selenium/standalone-firefox

USER root

# Inspired by Tutum Apache PHP.
#
# https://registry.hub.docker.com/u/tutum/apache-php/dockerfile/
#
ENV DEBIAN_FRONTEND noninteractive

# Set timezone and locale.
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN apt-get update
RUN apt-get purge `dpkg -l | grep php| awk '{print $2}' |tr "\n" " "`
RUN apt-get -y install software-properties-common
RUN add-apt-repository ppa:ondrej/php
RUN apt-get update
RUN apt-get -y install php5.6


# PHP Packages and databases
RUN apt-get -y install \
    php5.6-fpm php5.6-gd php5.6-ldap \
    php5.6-pgsql php5.6-sqlite php-pear php5.6-mysql php5.6-curl \
    php5.6-mcrypt php5.6-cli php5.6-xmlrpc php5.6-intl \
    build-essential curl mysql-client php-gettext xvfb redis-server mysql-server

##
# Now all our stuff.
##

# Preinstall some things that don't change.
RUN apt-get update -q \
  && apt-get install -y apt-utils \
  && apt-get -y install \
    git \
    unzip \
    nano \
  && apt-get clean

# Install composer related packages.
ENV PATH $PATH:$HOME/.composer/vendor/bin
RUN cd $HOME \
    && curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer


# Exporting current path to make tools available when using nsenter.
RUN echo "export PATH=$PATH" >> $HOME/.bashrc \
    && echo "export TERM=xterm" >> $HOME/.bashrc


# Apache
RUN apt-get update && apt-get -y install libapache2-mod-php5.6 apache2

RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf



# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


RUN mkdir /etc/service
RUN mkdir /etc/service/apache
ADD services/apache.sh /etc/service/apache/run

RUN rm /etc/apache2/sites-enabled/000-default.conf
ADD services/000-default.conf /etc/apache2/sites-enabled/000-default.conf

EXPOSE 80:80

RUN service apache2 start
RUN /etc/init.d/mysql start

CMD ["/opt/bin/entry_point.sh"]
