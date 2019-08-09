FROM centos:7
LABEL maintainer="seweryn.sitarski@p.lodz.pl"

EXPOSE 6445

#mfsmount -S /blueocean/opt /opt
#mount -o bind /usr/local/pbis /opt/pbis

# SGE
ADD soge/blueocean-v15 /usr/local/sge/blueocean-v15
ADD soge/sgeexecd.blueocean-v15 /etc/init.d/
ADD soge/sge.sh /etc/profile.d/
ADD soge/module.sh /etc/profile.d/

ADD soge/hwloc-1.5-1.el6.x86_64.rpm /tmp/hwloc-1.5-1.el6.x86_64.rpm
ADD soge/jemalloc-3.6.0-1.el7.x86_64.rpm /tmp/jemalloc-3.6.0-1.el7.x86_64.rpm
ADD soge/gridengine-8.1.7-1.el6.x86_64.rpm /tmp/gridengine-8.1.7-1.el6.x86_64.rpm
ADD soge/gridengine-execd-8.1.7-1.el6.x86_64.rpm /tmp/gridengine-execd-8.1.7-1.el6.x86_64.rpm

# Dodanie konfiguracji monit-a
ADD monit/monitrc /etc/
ADD monit/sshd /etc/monit.d/
ADD monit/pbis /etc/monit.d/
ADD monit/sge /etc/monit.d/
ADD monit/sync_hosts /etc/monit.d/
ADD monit/jupyterhub /etc/monit.d/
ADD monit/start_sshd.sh /
ADD monit/start_pbis.sh /
ADD monit/start_sync_hosts.sh /
ADD monit/start_jupyterhub.sh /

# Dodanie i uruchomienie scenariuszy ansible
ADD ansible /ansible

RUN yum -y install yum-plugin-remove-with-leaves && \
    yum -y install ansible && \
    ansible-playbook /ansible/Playbooks/install_PBIS.yml --connection=local --extra-vars "var_host=127.0.0.1" && \
    ansible-playbook /ansible/Playbooks/install_SGE.yml --connection=local --extra-vars "var_host=127.0.0.1" && \
    ansible-playbook /ansible/Playbooks/Install_all.yml --connection=local --extra-vars "var_host=127.0.0.1" && \
    yum -y remove ansible --remove-leaves && \
    rm -rf /ansible

ADD start.sh /start.sh

CMD ["/bin/bash","-c","/start.sh"]
