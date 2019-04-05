# Install Guacamole

GUAC_VER='1.0.0'

# Default == password
GUAC_PWHASH='5F4DCC3B5AA765D61D8327DEB882CF99'

## Install Prereqs

# yum install -y wget cairo-devel libjpeg-devel libpng-devel uuid-devel \
#                freerdp-devel pango-devel libssh2-devel libssh-dev \
#                tomcat tomcat-admin-webapps tomcat-webapps

yum install -y dejavu-sans-mono-fonts tomcat

## Install Server

# mkdir /root/guacamole
# cd /root/guacamole
# wget -O /root/guacamole/guacamole-server-${GUAC_VER}.tar.gz https://www.apache.org/dist/guacamole/1.0.0/source/guacamole-server-${GUAC_VER}.tar.gz
# tar zxf guacamole-server-${GUAC_VER}.tar.gz
# cd guacamole-server-${GUAC_VER}
# ./configure --with-systemd-dir=/lib/systemd/system
# make 
# make install
# ldconfig
# systemctl daemon-reload

yum --enablerepo=epel-testing install -y guacd libguac{,-client*}

## Install Client ##

mkdir -p /usr/share/tomcat/.guacamole

rm -rf /var/lib/tomcat/webapps/*
wget -O /var/lib/tomcat/webapps/root.war https://www.apache.org/dist/guacamole/1.0.0/binary/guacamole-${GUAC_VER}.war

cat << EOF > /etc/sysconfig/guacd
guacd-hostname:     localhost
guacd-port:         4822
user-mapping:       /usr/share/tomcat/.guacamole/user-mapping.xml
auth-provider:      net.sourceforge.guacamole.net.basic.BasicFileAuthenticationProvider
EOF

ln -s /etc/sysconfig/guacd /usr/share/tomcat/.guacamole/guacamole.properties

cat << EOF > /usr/share/tomcat/.guacamole/user-mapping.xml
<user-mapping>
        <authorize 
                username="user" 
                password="5f4dcc3b5aa765d61d8327deb882cf99" 
                encoding="md5">
                <connection name="RHEL 7">
                        <protocol>rdp</protocol>
                        <param name="hostname">127.0.0.1</param>
                        <param name="port">3389</param>
                </connection>
        </authorize>
</user-mapping>
EOF

chmod 660 /usr/share/tomcat/.guacamole/user-mapping.xml
chown -R tomcat:tomcat /usr/share/tomcat
chown -R tomcat:tomcat /usr/share/tomcat/.guacamole/
# chgrp -R 0 /usr/share/tomcat/.guacamole/
# chmod -R g=u /usr/share/tomcat/.guacamole/
chown tomcat:tomcat /var/lib/tomcat/webapps/root.war
# chgrp -R 0 /var/lib/tomcat/webapps/
# chmod -R g=u /var/lib/tomcat/webapps/
# chmod 666 /var/log/tomcat

if [[ ! -z $SYSTEMD  ]]; then
        systemctl enable tomcat
        systemctl enable guacd
fi

cp /tmp/config/supervisord/conf.d/guacd.conf /etc/supervisord/conf.d/guacd.conf

# END