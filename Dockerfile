FROM phusion/baseimage:master

LABEL maintainer="Kevin Barton"
LABEL description="PlaySMS 1.4 CVE 2017-9101 on Ubuntu 20.04 w/LAMP"
LABEL name="playsms1.4"

RUN    add-apt-repository ppa:ondrej/php
RUN apt-get update
RUN apt-get install -y \
    wget \
    git \
    unzip \
    nano \
    vim \
    mc \
    net-tools \
    apache2 apache2-utils libapache2-mod-php7.0 \
    php-pear php7.0 php7.0-cli php7.0-common php7.0-curl php7.0-gd php7.0-mcrypt php7.0-mysql \
    php7.0-mbstring php7.0-xml php7.0-zip \
    mariadb-server
RUN /etc/init.d/mysql start && \
    mysql -e "create database playsms;" && \
    mysql -e "create user 'playsmsuser'@'localhost' identified by 'Admin2020';" && \
    mysql -e "grant all on playsms.* to 'playsmsuser'@'localhost';" && \
    mysql -e "flush privileges;"
RUN chown www-data:www-data -R /var/www/html/ && \
    cd /var/www/html/ && \
    wget https://www.exploit-db.com/apps/577b6363d3e8baf4696744f911372ea6-playsms-1.4.tar.gz && \
    tar xzvf /var/www/html/577b6363d3e8baf4696744f911372ea6-playsms-1.4.tar.gz && \
    rm /var/www/html/577b6363d3e8baf4696744f911372ea6-playsms-1.4.tar.gz && \
    mv /var/www/html/playsms-1.4 /var/www/html/playsms && \
    cp /var/www/html/playsms/install.conf.dist /var/www/html/playsms/install.conf && \
    cp /var/www/html/playsms/install-playsms.sh /var/www/html/playsms/copy.install-playsms.sh && \
    sed -i 's/DBUSER="root"/DBUSER="playsmsuser"/g' /var/www/html/playsms/install.conf && \
    sed -i 's/DBPASS="password"/DBPASS="Admin2020"/g' /var/www/html/playsms/install.conf
RUN sed -i 's/USERID=$(id -u)/USERID=$(id -u)\n<<comment/g' /var/www/html/playsms/install-playsms.sh && \
    sed -i 's/echo "INSTALL DATA:"/comment\necho "INSTALL DATA:"/g' /var/www/html/playsms/install-playsms.sh && \
    sed -i 's/echo "Please read and confirm INSTALL DATA above"/echo "Please read and confirm INSTALL DATA above"\n<<comment/g' /var/www/html/playsms/install-playsms.sh && \
    sed -i 's/echo "Installation is in progress"/echo "Installation is in progress"\ncomment/g' /var/www/html/playsms/install-playsms.sh
RUN /etc/init.d/mysql start && \
    cd /var/www/html/playsms && \
    ./install-playsms.sh
    
EXPOSE 80 443 3306

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
