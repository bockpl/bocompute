FROM centos:7
MAINTAINER Seweryn Sitarski

# Klient MFS
RUN curl "http://ppa.moosefs.com/RPM-GPG-KEY-MooseFS" > /etc/pki/rpm-gpg/RPM-GPG-KEY-MooseFS && \
curl "http://ppa.moosefs.com/MooseFS-3-el7.repo" > /etc/yum.repos.d/MooseFS.repo && \
sed -i -- 's/moosefs-3/3.0.100/g' /etc/yum.repos.d/MooseFS.repo && \
yum -y install moosefs-pro-client

#mfsmount -S /blueocean/opt /opt
#mount -o bind /usr/local/pbis /opt/pbis

# AD PBIS
RUN yum -y install wget && \
wget -O /etc/yum.repos.d/pbiso.repo http://repo.pbis.beyondtrust.com/yum/pbiso.repo && \
yum clean all && \
yum -y install pbis-open && \
cp -a /opt/pbis /usr/local && \
(/opt/pbis/sbin/lwsmd --syslog& echo $! > /run/lwsmd.pid) && \
(echo "set_value [HKEY_THIS_MACHINE\Services\lsass\Parameters\Providers\ActiveDirectory\] \"AssumeDefaultDomain\" 0x00000001" > modreg.txt) && \
(echo "set_value [HKEY_THIS_MACHINE\Services\lsass\Parameters\Providers\ActiveDirectory\] \"HomeDirTemplate\" %H/likewise-open/%D/%U" >> modreg.txt) && \
(echo "set_value [HKEY_THIS_MACHINE\Services\lsass\Parameters\Providers\Local\] \"HomeDirTemplate\" %H/likewise-open/%D/%U" >> modreg.txt) && \
(echo "set_value [HKEY_THIS_MACHINE\Services\lsass\Parameters\RPCServers\samr\] \"HomeDirTemplate\" %H/likewise-open/%D/%U" >> modreg.txt) && \
(sleep 1; /opt/pbis/bin/regshell -f modreg.txt) && \
kill $(cat /run/lwsmd.pid)

ADD soge/hwloc-1.5-1.el6.x86_64.rpm /tmp/hwloc-1.5-1.el6.x86_64.rpm
ADD soge/jemalloc-3.6.0-1.el7.x86_64.rpm /tmp/jemalloc-3.6.0-1.el7.x86_64.rpm
ADD soge/gridengine-8.1.7-1.el6.x86_64.rpm /tmp/gridengine-8.1.7-1.el6.x86_64.rpm
ADD soge/gridengine-execd-8.1.7-1.el6.x86_64.rpm /tmp/gridengine-execd-8.1.7-1.el6.x86_64.rpm

RUN (yum -y install /tmp/hwloc-1.5-1.el6.x86_64.rpm) && \
(yum -y install /tmp/jemalloc-3.6.0-1.el7.x86_64.rpm) && \
(yum -y install /tmp/gridengine-8.1.7-1.el6.x86_64.rpm) && \
(yum -y install /tmp/gridengine-execd-8.1.7-1.el6.x86_64.rpm) && \
(cp -a /opt/sge /usr/local/)

ADD soge/blueocean-v15 /usr/local/sge/blueocean-v15
ADD soge/sgeexecd.blueocean-v15 /etc/init.d/
ADD soge/sge.sh /etc/profile.d/
ADD soge/module.sh /etc/profile.d/

RUN (chown -R sgeadmin:sgeadmin /usr/local/sge)

# Wysylanie powiadomien email:
RUN (yum -y install epel-release.noarch) && \
(yum -y install mailx) && \
(yum -y install msmtp) && \
(ln -s /usr/bin/msmtp /usr/sbin/sendmail)

# Proteza dla dzialania Module
RUN (ln -s /usr/lib64/libtcl8.5.so /usr/lib64/libtcl8.6.so)

# Do poprawnego dzialania oprogramowania Gamess (gamess_2016.R1):
RUN (yum -y install libgfortran.x86_64)

RUN (rm -rf /tmp/*)
RUN (rm -rf /opt/sge)
RUN (rm -rf /opt/pbis)

ADD start.sh /start.sh

EXPOSE 6445

CMD ["/bin/bash","-c","/start.sh"]
