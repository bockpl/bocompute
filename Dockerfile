FROM centos:7
LABEL maintainer="pawel.adamczyk.1@p.lodz.pl"

# SGE
ADD soge/sgeexecd.blueocean-v15 /etc/init.d/
ADD soge/sge.sh /etc/profile.d/
ADD soge/module.sh /etc/profile.d/

ADD soge/jemalloc-3.6.0-1.el7.x86_64.rpm /tmp/jemalloc-3.6.0-1.el7.x86_64.rpm

ADD repos/ghetto.repo /etc/yum.repos.d/

#RUN \
# Tymczasowa instalacja git-a i ansible w celu uruchomienia playbook-ow
RUN yum -y install yum-plugin-remove-with-leaves epel-release
#&& \

RUN yum -y install ansible 
#&& \
# Poprawka maksymalnej grupy systemowe konieczna ze wzgledu na wymagane GID grupy sgeadmin systemu SOGE, zaszlosc historyczna
RUN sed -ie 's/SYS_GID_MAX               999/SYS_GID_MAX               997/g' /etc/login.defs 
#&& 
RUN yum -y install git 
#&& \
# Pobranie repozytorium z playbook-ami
RUN cd /; git clone https://github.com/bockpl/boplaybooks.git
#; cd /boplaybooks 
#&& \
# Skasowanie tymczasowego srodowiska git, UWAGA: Brak tego wpisu w tej kolejnosci pozbawi srodowiska oprogramowania narzedziowego less, man itp.:
#RUN yum -y remove git epel-release --remove-leaves 

#&& \
# Instalacja systemu autoryzacji AD PBIS
RUN \
cd boplaybooks ; echo ; pwd ; echo && \
#ansible-playbook Playbooks/install_PBIS.yml --connection=local --extra-vars "var_host=127.0.0.1" && \
# Instalacja wymagan dla systemu kolejkowego SOGE    
ansible-playbook Playbooks/install_dep_SOGE.yml --connection=local --extra-vars "var_host=127.0.0.1" && \
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
# iInstalacja glibc-devel dla gcc
ansible-playbook Playbooks/install_glibc-dev.yml --connection=local --extra-vars "var_host=127.0.0.1" && \
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
ADD monit/sge_exec.conf /etc/monit.d/
#ADD monit/pbis.conf /etc/monit.d/
#ADD monit/*.conf /etc/monit.d/
ADD monit/stop_sshd.sh /etc/monit.d/
ADD monit/stop_nslcd.sh /etc/monit.d/
ADD monit/start_sshd.sh /etc/monit.d/
ADD monit/start_nslcd.sh /etc/monit.d/
#ADD monit/stop_pbis.sh /etc/monit.d/
ADD monit/start_sync_hosts.sh /etc/monit.d/
#ADD monit/start_pbis.sh /etc/monit.d/ 
#ADD monit/*.sh /etc/monit.d/
#RUN mkdir /var/run/nslcd
RUN chown nslcd -fR /var/run/nslcd

# Zmiana uprawnien konfiguracji monit-a
RUN chmod 700 /etc/monitrc

ENV TIME_ZONE=Europe/Warsaw
ENV LANG=en_US.UTF-8


ADD start.sh /usr/local/bin/start.sh

CMD ["/bin/bash","-c","/usr/local/bin/start.sh"]
