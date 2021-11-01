FROM ubuntu:latest

ENV DEBIAN_FRONTEND noninteractive
ARG MYSQL_SERVER_PACKAGE=mysql-community-server-minimal-8.0.27
ARG MYSQL_SHELL_PACKAGE=mysql-shell-8.0.27

RUN apt-get update \
  && apt-get install gnupg wget tzdata lsb-release -y

RUN wget https://repo.mysql.com/mysql-apt-config_0.8.19-1_all.deb \
  && dpkg -i mysql-apt-config_0.8.19-1_all.deb

RUN echo "deb http://repo.mysql.com/apt/ubuntu/ bionic mysql-apt-config" > /etc/apt/sources.list.d/mysql.list
RUN echo "deb http://repo.mysql.com/apt/ubuntu/ bionic mysql-8.0" >> /etc/apt/sources.list.d/mysql.list
RUN echo "deb http://repo.mysql.com/apt/ubuntu/ bionic mysql-tools" >> /etc/apt/sources.list.d/mysql.list
RUN echo "deb-src http://repo.mysql.com/apt/ubuntu/ bionic mysql-8.0" >> /etc/apt/sources.list.d/mysql.list

RUN apt update \
  && apt install mysql-server -y

COPY requirements.txt requirements.txt
COPY rabbitmq-server.sh rabbitmq-server.sh

RUN apt-get update \
  && apt-get install -y software-properties-common \
  && add-apt-repository universe \
  && apt-get update \
  && apt-get install -y net-tools redis-server curl git build-essential python2.7 python-dev libboost-python-dev libjpeg8-dev libjpeg-dev libjpeg-turbo8-dev
    
RUN apt-get install -y libaio1 libaio-dev libmysqlclient-dev mysql-client \
  && apt-get -f install \
  && rm -rf ${MYSQL_DATA_DIR} \
  && rm -rf /var/lib/apt/lists/*

RUN add-apt-repository 'deb http://archive.ubuntu.com/ubuntu bionic main' \
  && apt-get update \
  && apt-get install libgraphicsmagick++-dev python-mysqldb -y 

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

RUN chmod +x rabbitmq-server.sh
RUN bash rabbitmq-server.sh

COPY docker-entrypoint.sh /opt/entrypoint.sh

RUN chmod +x /opt/entrypoint.sh 

ENV MYSQL_UNIX_PORT /var/lib/mysql/mysql.sock

ENTRYPOINT ["/opt/entrypoint.sh"]
EXPOSE 3306 33060 33061
