FROM ubuntu
 
RUN echo 'deb http://archive.ubuntu.com/ubuntu precise main universe' > /etc/apt/sources.list && \
    echo 'deb http://archive.ubuntu.com/ubuntu precise-updates universe' >> /etc/apt/sources.list && \
    apt-get update

#Prevent daemon start during install
RUN dpkg-divert --local --rename --add /sbin/initctl && ln -sf /bin/true /sbin/initctl

#Supervisord
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y supervisor && mkdir -p /var/log/supervisor
CMD ["/usr/bin/supervisord", "-n"]

#SSHD
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y openssh-server &&	mkdir /var/run/sshd && \
	echo 'root:root' |chpasswd

#Utilities
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y vim less net-tools inetutils-ping curl git telnet nmap socat dnsutils netcat tree htop unzip sudo

#Dependencies
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y default-jdk build-essential libncurses5-dev openssl libssl-dev fop xsltproc unixodbc-dev

#Postgres
RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main' > /etc/apt/sources.list.d/pgdg.list
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y postgresql-9.3

#Erlang
RUN wget --no-check-certificate https://packages.erlang-solutions.com/erlang/esl-erlang-src/otp_src_R16B03-1.tar.gz && \
    tar xvf otp*tar.gz && \
    rm otp*tar.gz
RUN cd otp_src* && \
    ./configure && \
    make && \
    make install
RUN rm -rf otp_src*
RUN echo 'export PATH=/usr/local/lib/erlang/lib/erl_interface-3.7.15/bin:$PATH' >> /root/.bashrc

#Zotonic
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y imagemagick
RUN wget https://zotonic.googlecode.com/files/zotonic-0.9.4.zip && \
    unzip zotonic*.zip && \
    rm zotonic*.zip

RUN cd /zotonic && \
    make

#Configuration
ADD . /docker
RUN ln -s /docker/supervisord-ssh.conf /etc/supervisor/conf.d/supervisord-ssh.conf
RUN ln -s /docker/supervisord-postgres.conf /etc/supervisor/conf.d/supervisord-postgres.conf
RUN ln -s /docker/pg_hba.conf /var/lib/postgresql/9.3/main/pg_hba.conf

#Init DB
RUN supervisord & sleep 3 && \
    sudo -u postgres psql < /docker/zotonic.ddl 
EXPOSE 22

