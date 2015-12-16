#!/bin/bash

cp setup_omero_apache24.sh ~omero
su - omero -c "bash -eux setup_omero_apache24.sh"

apt-get -y install apache2 libapache2-mod-wsgi

# See setup_omero*.sh for the apache config file creation

sed -i -r -e 's|(WSGISocketPrefix run/wsgi)|#\1|' -e 's|# (WSGISocketPrefix /var/run/wsgi)|\1|' ~omero/OMERO.server/apache.conf.tmp
cp ~omero/OMERO.server/apache.conf.tmp /etc/apache2/sites-available/omero-web.conf
a2dissite 000-default.conf
a2ensite omero-web.conf

service apache2 start
