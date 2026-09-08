FROM debian:trixie
LABEL maintainer=darius.stefan@opensips.org

USER root

ENV DEBIAN_FRONTEND=noninteractive

ARG OPENSIPS_CP_VERSION="master"

RUN apt-get -y update -qq && apt-get -y install git cron &&\
    apt-get -y install apache2 libapache2-mod-php php-curl &&\
    apt-get install -y default-mysql-client

COPY opensips-cp.conf /etc/apache2/sites-available/

WORKDIR /var/www/html/

RUN git clone --single-branch -b ${OPENSIPS_CP_VERSION} https://github.com/OpenSIPS/opensips-cp.git &&\
    chown -R www-data:www-data /var/www/html/opensips-cp/ &&\
    git config --global --add safe.directory /var/www/html/opensips-cp &&\
    apt-get -y install php php-mysql php-gd php-pear php-cli php-apcu &&\
    a2ensite opensips-cp.conf &&\
    a2dissite 000-default.conf &&\
    a2enmod rewrite &&\
    rm -rf /var/lib/apt/lists/*

COPY docker-entrypoint.sh /docker-entrypoint.sh

WORKDIR /var/www/html/opensips-cp

ONBUILD COPY modules.inc.php /var/www/html/opensips-cp/config/

RUN sed -i "s/root/www-data/g" /var/www/html/opensips-cp/config/tools/system/smonitor/opensips_stats_cron &&\
    cp /var/www/html/opensips-cp/config/tools/system/smonitor/opensips_stats_cron /etc/cron.d/

EXPOSE 80

ENTRYPOINT ["/docker-entrypoint.sh"]
