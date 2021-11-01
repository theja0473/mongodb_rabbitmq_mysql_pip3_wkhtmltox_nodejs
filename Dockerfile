FROM ubuntu:latest

ENV DEBIAN_FRONTEND noninteractive
ENV MYSQL_USER=mysql \
    MYSQL_VERSION=8.0.20 \
    MYSQL_DATA_DIR=/var/lib/mysql \
    MYSQL_RUN_DIR=/run/mysqld \
    MYSQL_LOG_DIR=/var/log/mysql

COPY requirements.txt requirements.txt

RUN apt-get update \
  && apt-get install -y software-properties-common redis-server \
  && add-apt-repository universe \
  && apt-get install -y curl git build-essential python2.7 python-dev libboost-python-dev libjpeg8-dev libjpeg-dev libjpeg-turbo8-dev
    
RUN curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.deb.sh | bash \
  && apt-get update \
  && apt-get install -y rabbitmq-server
  
RUN apt-get install -y libaio1 libaio-dev libmysqlclient-dev mysql-client mysql-server \
  && apt-get -f install \
  && rm -rf ${MYSQL_DATA_DIR} \
  && rm -rf /var/lib/apt/lists/*

RUN apt-get install libgraphicsmagick++-dev -y \
  && add-apt-repository 'deb http://archive.ubuntu.com/ubuntu bionic main' \
  && apt-get update \
  && apt-get install -y python-mysqldb 

RUN apt-get install openssl xorg libssl-dev libcurl4-openssl-dev wget libxml2-dev libxslt1-dev -y

RUN apt-get install libtiff5-dev libjpeg8-dev zlib1g-dev libfreetype6-dev liblcms2-dev libwebp-dev tcl8.6-dev tk8.6-dev python-tk -y

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - \
  && apt install nodejs -y

RUN wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.4/wkhtmltox-0.12.4_linux-generic-amd64.tar.xz \
  && tar -xvf wkhtmltox-0.12.4_linux-generic-amd64.tar.xz \
  && chown root:root wkhtmltox \
  && mv wkhtmltox /usr/bin/wkhtmltopdf \
  && rm wkhtmltox-0.12.4_linux-generic-amd64.tar.xz

RUN apt-get install gnupg -y \
  && wget -qO - https://www.mongodb.org/static/pgp/server-5.0.asc | apt-key add - \
  && echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/5.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-5.0.list \
  && apt-get update \
  && apt-get install -y mongodb-org
    
RUN apt-get update && apt-get install -y \
        software-properties-common
RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt-get update && apt-get install -y \
        python3.7 \
        python3-pip
RUN python3.7 -m pip install pip
RUN apt-get update && apt-get install -y \
        python3-distutils \
        python3-setuptools
RUN python3.7 -m pip install pip --upgrade pip \
  && pip install setuptools \
  && pip install -r requirements.txt

COPY docker-entrypoint.sh /sbin/entrypoint.sh

RUN chmod 755 /sbin/entrypoint.sh

EXPOSE 3306/tcp

ENTRYPOINT ["/sbin/entrypoint.sh"]

CMD ["/usr/bin/mysqld_safe"]

