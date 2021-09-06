FROM centos:7
LABEL maintainer="pawel.adamczyk.1@p.lodz.pl" 
#"seweryn.sitarski@p.lodz.pl"

# SGE
#ADD soge/sgeexecd.blueocean-v15 /etc/init.d/
#ADD soge/sge.sh /etc/profile.d/
ADD soge/module.sh /etc/profile.d/
#
ADD soge/jemalloc-3.6.0-1.el7.x86_64.rpm /tmp/jemalloc-3.6.0-1.el7.x86_64.rpm
#
ADD repos/ghetto.repo /etc/yum.repos.d/

# SLURM

ARG SLURM_TAG=slurm-19-05-1-2
ARG GOSU_VERSION=1.11

RUN set -x \
    && export MUNGEUSER=991 \
    && groupadd -g $MUNGEUSER munge \
    && useradd  -m -c "MUNGE Uid 'N' Gid Emporium" -d /var/lib/munge -u $MUNGEUSER -g munge  -s /sbin/nologin munge \
    && export SLURMUSER=992 \
    && groupadd -g $SLURMUSER slurm \
    && useradd  -m -c "SLURM workload manager" -d /var/lib/slurm -u $SLURMUSER -g slurm  -s /bin/bash slurm

RUN set -ex \
    && yum makecache fast \
    && yum -y update \
    && yum -y install epel-release \
    && yum -y install \
       wget \
       bzip2 \
       perl \
       gcc \
       gcc-c++\
       git \
       gnupg \
       make \
       munge \
       munge-libs \
       munge-devel \
       python-devel \
       python-pip \
       python34 \
       python34-devel \
       python34-pip \
       mariadb-server \
       mariadb-devel \
       psmisc \
       bash-completion \
       vim-enhanced \
       rng-tools \
       mariadb-server \
       mariadb-devel \
    && yum clean all \
    && rm -rf /var/cache/yum

RUN pip install Cython nose && pip3.4 install Cython nose

#RUN set -x \
#    && rngd -r /dev/urandom \
#    && /usr/sbin/create-munge-key -r \
#    && dd if=/dev/urandom bs=1 count=1024 > /etc/munge/munge.key \
#    && chown munge: /etc/munge/munge.key \
#    && chmod 400 /etc/munge/munge.key \
#    && chown -R munge: /etc/munge/ /var/log/munge/ \
#    && chmod 0700 /etc/munge/ /var/log/munge/ \
#    && systemctl enable munge

#https://download.schedmd.com/slurm/slurm-20.11.4.tar.bz2

RUN set -ex \
    && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64" \
    && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64.asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg2 --import-ownertrust # mpapis@gmail.com \
    && gpg2 --import-ownertrust # piotr.kuczynski@gmail.com \
    && gpg2 --keyserver hkp://pgp.mit.edu/ --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB \
#    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && gpg2 --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && rm -rf "${GNUPGHOME}" /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true

RUN set -x \
    && git clone https://github.com/SchedMD/slurm.git \
    && pushd slurm \
    && git checkout tags/$SLURM_TAG \
    && ./configure --enable-debug --prefix=/usr --sysconfdir=/etc/slurm \
        --libdir=/usr/lib64 \
#        --with-mysql_config=/usr/bin  --libdir=/usr/lib64 \
    && make install \
    && install -D -m644 etc/cgroup.conf.example /etc/slurm/cgroup.conf.example \
    && install -D -m644 etc/slurm.conf.example /etc/slurm/slurm.conf.example \
    && install -D -m644 etc/slurmdbd.conf.example /etc/slurm/slurmdbd.conf.example \
    && install -D -m644 contribs/slurm_completion_help/slurm_completion.sh /etc/profile.d/slurm_completion.sh \
    && popd \
    && rm -rf slurm \
 #   && groupadd -r --gid=995 slurm \
 #   && useradd -r -g slurm --uid=995 slurm \
    && mkdir /etc/sysconfig/slurm \
        /var/spool/slurmd \
        /var/run/slurmd \
        /var/run/slurmdbd \
        /var/lib/slurmd \
        /var/log/slurm \
        /data \
    && touch /var/lib/slurmd/node_state \
        /var/lib/slurmd/front_end_state \
        /var/lib/slurmd/job_state \
        /var/lib/slurmd/resv_state \
        /var/lib/slurmd/trigger_state \
        /var/lib/slurmd/assoc_mgr_state \
        /var/lib/slurmd/assoc_usage \
        /var/lib/slurmd/qos_usage \
        /var/lib/slurmd/fed_mgr_state \
    && chown -R slurm:slurm /var/*/slurm*  

COPY slurm/munge.key /etc/munge/
RUN chown munge:munge /etc/munge/munge.key
RUN chmod 600 /etc/munge/munge.key

COPY slurm/slurm.conf /etc/slurm/slurm.conf
#3COPY slurm/slurmdbd.conf /etc/slurm/slurmdbd.conf

#COPY slurm/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
#ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

#CMD ["slurmdbd"]

#RUN \
# Tymczasowa instalacja git-a i ansible w celu uruchomienia playbook-ow
RUN yum -y install yum-plugin-remove-with-leaves epel-release
#&& \

RUN yum -y install ansible 
#&& \
# Poprawka maksymalnej grupy systemowe konieczna ze wzgledu na wymagane GID grupy sgeadmin systemu SOGE, zaszlosc historyczna
#RUN sed -ie 's/SYS_GID_MAX               999/SYS_GID_MAX               997/g' /etc/login.defs 
#&& 
RUN yum -y install git 
#&& \
# Pobranie repozytorium z playbook-ami
RUN cd /; git clone https://github.com/bockpl/boplaybooks.git
#; cd /boplaybooks 
#&& \
# Skasowanie tymczasowego srodowiska git, UWAGA: Brak tego wpisu w tej kolejnosci pozbawi srodowiska oprogramowania narzedziowego less, man itp.:
RUN yum -y remove git epel-release --remove-leaves 

#&& \
# Instalacja systemu autoryzacji AD PBIS
RUN \
cd boplaybooks ; echo ; pwd ; echo && \
ansible-playbook Playbooks/install_PBIS.yml --connection=local --extra-vars "var_host=127.0.0.1" && \
# Instalacja wymagan dla systemu kolejkowego SOGE    
#ansible-playbook Playbooks/install_dep_SOGE.yml --connection=local --extra-vars "var_host=127.0.0.1" && \
# Instalacja obslugi e-mail
ansible-playbook Playbooks/install_Mail_support.yml --connection=local --extra-vars "var_host=127.0.0.1" && \
# Instalacja systemu Monit
ansible-playbook Playbooks/install_Monit.yml --connection=local --extra-vars "var_host=127.0.0.1" && \
# Instalacja wymagan dla podsystemu Module
ansible-playbook Playbooks/install_dep_Module.yml --connection=local --extra-vars "var_host=127.0.0.1" && \
# Instalacja wymagan dla oprogramowania Augustus
ansible-playbook Playbooks/install_dep_Augustus.yml --connection=local --extra-vars "var_host=127.0.0.1" && \
# Instalacja wymagan dla oprogramownia Ansys v19.2
ansible-playbook Playbooks/install_dep_Ansys19.2.yml --connection=local --extra-vars "var_host=127.0.0.1" && \
# Instalacja wymagan dla oprogramowania Games
ansible-playbook Playbooks/install_dep_Games.yml --connection=local --extra-vars "var_host=127.0.0.1" && \
# Instalacja wymagan dla srodowiska MPI
ansible-playbook Playbooks/install_dep_MPI.yml --connection=local --extra-vars "var_host=127.0.0.1" && \
# Instalacja wymagan dla srodowiska TensorBoard
ansible-playbook Playbooks/install_dep_TensorBoard.yml --connection=local --extra-vars "var_host=127.0.0.1" && \
# Instalacja wymagan dla oprogramowanie MatLab
ansible-playbook Playbooks/install_dep_MatLab.yml --connection=local --extra-vars "var_host=127.0.0.1" && \
# Instalacja narzedzi do interaktywnej wpracy w konsoli dla uzytkownikow klastra
ansible-playbook Playbooks/install_boaccess_tools.yml --connection=local --extra-vars "var_host=127.0.0.1" && \
# Skasowanie katalogu z playbookami
rm -rf /boplaybooks && \
# Skasowanie tymczasowego srodowiska git i ansible
yum -y remove ansible --remove-leaves && \
cd /; rm -rf /boplaybooksi ; 

# Dodanie autoryzacji  LDAP
RUN  yum install -y \
        nss-pam-ldapd \
        openssl \
        nscd \
        openldap-clients \
        authconfig && \
     yum clean all && \
     rm -rf /var/cache/yum

RUN  authconfig --update --enableldap --enableldapauth
RUN  authconfig --updateall --enableldap --enableldapauth

COPY copy4ldap/fingerprint-auth-ac /etc/pam.d/
COPY copy4ldap/system-auth-ac /etc/pam.d/
COPY copy4ldap/smartcard-auth-ac /etc/pam.d/
COPY copy4ldap/password-auth-ac /etc/pam.d/
#COPY copy4ldap/*ac /etc/pam.d/
COPY copy4ldap/nsswitch.conf /etc/
#COPY copy4ldap/nslcd.conf /etc/
#COPY copy4ldap/*conf /etc/

# Dodanie konfiguracji monit-a
ADD monit/monitrc /etc/
ADD monit/nslcd.conf /etc/monit.d/
ADD monit/sync_hosts.conf /etc/monit.d/
ADD monit/sshd.conf /etc/monit.d/
#ADD monit/sge_exec.conf /etc/monit.d/
ADD monit/pbis.conf /etc/monit.d/
ADD monit/munge.conf /etc/monit.d/
ADD monit/slurmd.conf /etc/monit.d/
#ADD monit/slurmctld.conf /etc/monit.d/
#ADD monit/slurmdbd.conf /etc/monit.d/
#ADD monit/*.conf /etc/monit.d/
ADD monit/stop_sshd.sh /etc/monit.d/
ADD monit/stop_nslcd.sh /etc/monit.d/
ADD monit/start_sshd.sh /etc/monit.d/
ADD monit/start_nslcd.sh /etc/monit.d/
ADD monit/stop_pbis.sh /etc/monit.d/
ADD monit/start_sync_hosts.sh /etc/monit.d/
ADD monit/start_pbis.sh /etc/monit.d/ 
ADD monit/start_munged.sh /etc/monit.d/
ADD monit/stop_munged.sh /etc/monit.d/
ADD monit/start_slurmd.sh /etc/monit.d/
ADD monit/stop_slurmd.sh /etc/monit.d/
#ADD monit/start_slurmctld.sh /etc/monit.d/
#ADD monit/stop_slurmctld.sh /etc/monit.d/
#ADD monit/start_slurmdbd.sh /etc/monit.d/
#ADD monit/stop_slurmdbd.sh /etc/monit.d/
#ADD monit/*.sh /etc/monit.d/
#RUN mkdir /var/run/nslcd
RUN chown nslcd -fR /var/run/nslcd
RUN mkdir /var/run/slurm
RUN chown slurm:slurm /var/run/slurm
# Zmiana uprawnien konfiguracji monit-a
RUN chmod 700 /etc/monitrc

ENV TIME_ZONE=Europe/Warsaw
ENV LANG=en_US.UTF-8

ADD start.sh /usr/local/bin/start.sh

CMD ["/bin/bash","-c","/usr/local/bin/start.sh"]
