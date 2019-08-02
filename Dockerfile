FROM centos:7
LABEL maintainer="seweryn.sitarski@p.lodz.pl"

EXPOSE 6445

# Dodanie do yum opcji kasowania zaleznosci wraz z kasowaniem pakietu
RUN yum -y install yum-plugin-remove-with-leaves && \
    yum clean all && \
    rm -rf /var/cache/yum

# Klient MFS
RUN curl "http://ppa.moosefs.com/RPM-GPG-KEY-MooseFS" > /etc/pki/rpm-gpg/RPM-GPG-KEY-MooseFS && \
curl "http://ppa.moosefs.com/MooseFS-3-el7.repo" > /etc/yum.repos.d/MooseFS.repo && \
sed -i -- 's/moosefs-3/3.0.100/g' /etc/yum.repos.d/MooseFS.repo && \
yum -y install moosefs-pro-client && \
yum clean all && \
rm -rf /var/cache/yum

#mfsmount -S /blueocean/opt /opt
#mount -o bind /usr/local/pbis /opt/pbis

# AD PBIS
# UWAGA! Pakiet jest skompilowany na sztywno ze ściekami dostępu i zawartymi bibliotekami.
# W celu nie wchodzenia w kolizję z montowanym katalogiem /opt po instalacji calosc jest 
# przeniesiona do /usr/local i utworzony jest link symboliczny w /opt.
# W montowanym katalopu /opt musi równie istnieć link symboliczny do katalogu /usr/local/pbis
RUN yum -y install wget && \
wget -O /etc/yum.repos.d/pbiso.repo http://repo.pbis.beyondtrust.com/yum/pbiso.repo && \
yum -y remove wget --remove-leaves && \
yum -y install pbis-open && \
mv /opt/pbis /usr/local && \
ln -s /usr/local/pbis /opt/pbis && \
(/opt/pbis/sbin/lwsmd --syslog& echo $! > /run/lwsmd.pid) && \
(echo "set_value [HKEY_THIS_MACHINE\Services\lsass\Parameters\Providers\ActiveDirectory\] \"AssumeDefaultDomain\" 0x00000001" > modreg.txt) && \
(echo "set_value [HKEY_THIS_MACHINE\Services\lsass\Parameters\Providers\ActiveDirectory\] \"HomeDirTemplate\" %H/likewise-open/%D/%U" >> modreg.txt) && \
(echo "set_value [HKEY_THIS_MACHINE\Services\lsass\Parameters\Providers\Local\] \"HomeDirTemplate\" %H/likewise-open/%D/%U" >> modreg.txt) && \
(echo "set_value [HKEY_THIS_MACHINE\Services\lsass\Parameters\RPCServers\samr\] \"HomeDirTemplate\" %H/likewise-open/%D/%U" >> modreg.txt) && \
(sleep 1; /opt/pbis/bin/regshell -f modreg.txt) && \
rm -f modreg.txt && \
rm -f /opt/pbis && \
kill $(cat /run/lwsmd.pid) && \
yum clean all && \
rm -rf /var/cache/yum

# SGE
ADD soge/blueocean-v15 /usr/local/sge/blueocean-v15
ADD soge/sgeexecd.blueocean-v15 /etc/init.d/
ADD soge/sge.sh /etc/profile.d/
ADD soge/module.sh /etc/profile.d/

ADD soge/hwloc-1.5-1.el6.x86_64.rpm /tmp/hwloc-1.5-1.el6.x86_64.rpm
ADD soge/jemalloc-3.6.0-1.el7.x86_64.rpm /tmp/jemalloc-3.6.0-1.el7.x86_64.rpm
ADD soge/gridengine-8.1.7-1.el6.x86_64.rpm /tmp/gridengine-8.1.7-1.el6.x86_64.rpm
ADD soge/gridengine-execd-8.1.7-1.el6.x86_64.rpm /tmp/gridengine-execd-8.1.7-1.el6.x86_64.rpm

RUN yum -y install /tmp/hwloc-1.5-1.el6.x86_64.rpm && \
yum -y install /tmp/jemalloc-3.6.0-1.el7.x86_64.rpm && \
yum -y install /tmp/gridengine-8.1.7-1.el6.x86_64.rpm && \
yum -y install /tmp/gridengine-execd-8.1.7-1.el6.x86_64.rpm && \
cp -a /opt/sge/* /usr/local/sge/ && \
rm -rf /opt/sge && \
chown -R sgeadmin:sgeadmin /usr/local/sge && \
rm -f /tmp/*.rpm && \
yum clean all && \
rm -rf /var/cache/yum

# Wysylanie powiadomien email:
RUN yum -y install epel-release.noarch && \
yum -y install mailx && \
yum -y install msmtp && \
yum clean all && \
rm -rf /var/cache/yum && \
ln -s /usr/bin/msmtp /usr/sbin/sendmail

# Dodanie i uruchomienie scenariuszy ansible
ADD ansible /ansible

RUN yum -y install ansible && \
    ansible-playbook /ansible/Playbooks/Install_all.yml --connection=local --extra-vars "var_host=127.0.0.1" && \
    yum -y remove ansible --remove-leaves && \
    rm -rf /ansible

ADD start.sh /start.sh

CMD ["/bin/bash","-c","/start.sh"]
