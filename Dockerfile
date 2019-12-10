FROM centos:7
LABEL maintainer="seweryn.sitarski@p.lodz.pl"

EXPOSE 6445/tcp

# SGE
ADD soge/sgeexecd.blueocean-v15 /etc/init.d/
ADD soge/sge.sh /etc/profile.d/
ADD soge/module.sh /etc/profile.d/

ADD soge/jemalloc-3.6.0-1.el7.x86_64.rpm /tmp/jemalloc-3.6.0-1.el7.x86_64.rpm

# Dodanie i uruchomienie scenariuszy ansible, tymczasowo tylko na czas budowy
#ADD ansible /ansible

RUN \
# Tymczasowa instalacja git-a i ansible w celu uruchomienia playbook-ow
yum -y install yum-plugin-remove-with-leaves && \
yum -y install ansible && \
# Poprawka maksymalnej grupy systemowe konieczna ze wzgledu na wymagane GID grupy sgeadmin systemu SOGE, zaszlosc historyczna
sed -ie 's/SYS_GID_MAX               999/SYS_GID_MAX               997/g' /etc/login.defs && yum -y install git && \
# Pobranie repozytorium z playbook-ami
cd /; git clone https://github.com/bockpl/boplaybooks.git; cd /boplaybooks && \
# Instalacja systemu autoryzacji AD PBIS
ansible-playbook Playbooks/install_PBIS.yml --connection=local --extra-vars "var_host=127.0.0.1" && \
# Instalacja wymagan dla systemu kolejkowego SOGE    
ansible-playbook Playbooks/install_dep_SOGE.yml --connection=local --extra-vars "var_host=127.0.0.1" && \
# Instalacja obslugi e-mail
ansible-playbook Playbooks/install_mail_support.yml --connection=local --extra-vars "var_host=127.0.0.1" && \
# Instalacja systemu Monit
ansible-playbook Playbooks/install_monit.yml --connection=local --extra-vars "var_host=127.0.0.1" && \
# Instalacja wymagan dla podsystemu Module
ansible-playbook Playbooks/install_dep_module.yml --connection=local --extra-vars "var_host=127.0.0.1" && \
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
# Skasowanie tymczasowego srodowiska git i ansible
yum -y remove git --remove-leaves && \
yum -y remove ansible --remove-leaves && \
cd /; rm -rf /boplaybooks

# Dodanie konfiguracji monit-a
ADD monit/monitrc /etc/
ADD monit/sshd.conf /etc/monit.d/
ADD monit/pbis.conf /etc/monit.d/
ADD monit/sge_exec.conf /etc/monit.d/
ADD monit/sync_hosts.conf /etc/monit.d/
ADD monit/start_sshd.sh /etc/monit.d/
ADD monit/start_pbis.sh /etc/monit.d/
ADD monit/start_sync_hosts.sh /etc/monit.d/

# Zmiana uprawnien konfiguracji monit-a
RUN chmod 700 /etc/monitrc

ENV TIME_ZONE=Europe/Warsaw

ADD start.sh /start.sh

CMD ["/bin/bash","-c","/start.sh"]
