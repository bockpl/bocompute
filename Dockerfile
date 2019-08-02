FROM centos:7
LABEL maintainer="seweryn.sitarski@p.lodz.pl"

EXPOSE 6445

# Dodanie do yum opcji kasowania zaleznosci wraz z kasowaniem pakietu
RUN yum -y install yum-plugin-remove-with-leaves && \
    yum clean all && \
    rm -rf /var/cache/yum

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

# Dodanie i uruchomienie scenariuszy ansible
ADD ansible /ansible

RUN yum -y install ansible && \
    ansible-playbook /ansible/Playbooks/install_PBIS.yml --connection=local --extra-vars "var_host=127.0.0.1" && \
    ansible-playbook /ansible/Playbooks/install_SGE.yml --connection=local --extra-vars "var_host=127.0.0.1" && \
    ansible-playbook /ansible/Playbooks/Install_all.yml --connection=local --extra-vars "var_host=127.0.0.1" && \
    yum -y remove ansible --remove-leaves && \
    rm -rf /ansible

ADD start.sh /start.sh

CMD ["/bin/bash","-c","/start.sh"]
