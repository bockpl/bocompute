FROM centos:7
LABEL maintainer="seweryn.sitarski@p.lodz.pl"

EXPOSE 6445/tcp 8000/tcp 8081/tcp

#mfsmount -S /blueocean/opt /opt
#mount -o bind /usr/local/pbis /opt/pbis

# SGE
ADD soge/sgeexecd.blueocean-v15 /etc/init.d/
ADD soge/sge.sh /etc/profile.d/
ADD soge/module.sh /etc/profile.d/

ADD soge/jemalloc-3.6.0-1.el7.x86_64.rpm /tmp/jemalloc-3.6.0-1.el7.x86_64.rpm

# Dodanie i uruchomienie scenariuszy ansible, tymczasowo tylko na czas budowy
ADD ansible /ansible

RUN yum -y install yum-plugin-remove-with-leaves && \
    yum -y install ansible && \
    ansible-playbook /ansible/Playbooks/install_PBIS.yml --connection=local --extra-vars "var_host=127.0.0.1" && \
    ansible-playbook /ansible/Playbooks/install_dep_soge.yml --connection=local --extra-vars "var_host=127.0.0.1" && \
    ansible-playbook /ansible/Playbooks/Install_all.yml --connection=local --extra-vars "var_host=127.0.0.1" && \
    yum -y remove ansible --remove-leaves && \
    rm -rf /ansible

# Dodanie konfiguracji monit-a
ADD monit/monitrc /etc/
ADD monit/sshd.conf /etc/monit.d/
ADD monit/pbis.conf /etc/monit.d/
ADD monit/sge_exec.conf /etc/monit.d/
ADD monit/sync_hosts.conf /etc/monit.d/
ADD monit/start_sshd.sh /etc/monit.d/
ADD monit/start_pbis.sh /etc/monit.d/
ADD monit/start_sync_hosts.sh /etc/monit.d/

ENV JUPYTERHUB_WORKDIR=/var/run/jupyterhub
ADD monit/start_jupyterhub.sh /etc/monit.d/

# Zmiana uprawnien konfiguracji monit-a
RUN chmod 700 /etc/monitrc

ENV TIME_ZONE=Europe/Warsaw

ADD start.sh /start.sh

CMD ["/bin/bash","-c","/start.sh"]
