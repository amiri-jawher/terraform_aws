#!/bin/bash

sudo -i
############################################################# Debut de l'installation ######################################################
#installation openjdk git et maven
apt update && apt -y install  default-jdk unzip git curl 

#installation maven
cd /usr/local/src
wget http://n.grassa.free.fr/download/apache-maven-3.8.8-bin.tar.gz
tar -xf apache-maven-3.8.8-bin.tar.gz
mv apache-maven-3.8.8/  apache-maven/

rm /etc/profile.d/maven.sh
echo "export M2_HOME=/usr/local/src/apache-maven" > /etc/profile.d/maven.sh
echo "export PATH=\${M2_HOME}/bin:\${PATH}" >> /etc/profile.d/maven.sh
chmod +x /etc/profile.d/maven.sh
source /etc/profile.d/maven.sh


### variable d'environnement pour java.sh

rm /etc/profile.d/java.sh
echo "export JAVA_HOME=/usr/lib/jvm/default-java" > /etc/profile.d/java.sh
echo "export PATH=\${JAVA_HOME}/bin:\${PATH}" >> /etc/profile.d/java.sh
chmod +x /etc/profile.d/java.sh
source /etc/profile.d/java.sh

### Affichage variables d'environnements

echo "M2_HOME:$M2_HOME"
echo "JAVA_HOME:$JAVA_HOME"

#installation Tomcat 

cd /tmp
wget http://n.grassa.free.fr/download/apache-tomcat-8.5.59.zip
unzip apache-tomcat-8.5.59.zip
mkdir -p /opt/tomcat
mv apache-tomcat-8.5.59 /opt/tomcat
rm -rf /opt/tomcat/latest
ln -s  /opt/tomcat/apache-tomcat-8.5.59 /opt/tomcat/latest
sh -c 'chmod +x /opt/tomcat/latest/bin/*.sh'
########
cd
########
#creation service Tomcat
rm /etc/systemd/system/tomcat.service
cat << EOF >> /etc/systemd/system/tomcat.service
[Unit]
Description=Tomcat 8.5 servlet container
After=network.target
[Service]
Type=forking
Environment="JAVA_HOME=/usr/lib/jvm/default-java"
Environment="JAVA_OPTS=-Djava.security.egd=file:///dev/urandom"
Environment="CATALINA_BASE=/opt/tomcat/latest"
Environment="CATALINA_HOME=/opt/tomcat/latest"
Environment="CATALINA_PID=/opt/tomcat/latest/temp/tomcat.pid"
Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"
ExecStart=/opt/tomcat/latest/bin/startup.sh
ExecStop=/opt/tomcat/latest/bin/shutdown.sh
[Install]
WantedBy=multi-user.target
EOF
#fin

systemctl daemon-reload
systemctl enable tomcat
systemctl start tomcat
#systemctl status tomcat

# build et dÃ©ploiement
git clone https://github.com/ngrassa/projet_j2ee.git
cd projet_j2ee
mvn clean install package
cp  webapp/target/webapp.war  /opt/tomcat/latest/webapps/
var4=`ip a | grep global | cut -d" " -f6 | cut -d"/" -f1 | head -n 1`
echo "Voici l'URL pour acceder a votre java web application en local: http://$var4:8080/webapp"
curl http://$var4:8080/webapp
# purge 

rm /usr/local/src/apache-maven-3.8.8-bin.tar.gz
rm /tmp/apache-tomcat-8.5.59.zip