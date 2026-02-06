#---------------------------------------------------------------------------
# Dockefile to build Docker Image of Apache WebServer running on Ubuntu
#
# Made by Gurenich Andrey  26-October-2025
#---------------------------------------------------------------------------

FROM php:7.4-apache

# Включаем mod_rewrite и делаем настройку в apache
RUN a2enmod rewrite && \
    sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf

COPY index.php /var/www/html/
COPY .htaccess /var/www/html/.htaccess

EXPOSE 80
