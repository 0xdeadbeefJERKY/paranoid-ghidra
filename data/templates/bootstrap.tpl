#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive
 
sudo apt-get update
sudo apt-get install -y git tmux wget xfce4 xfce4-goodies unzip
sudo apt-get install -y tightvncserver

wget https://download.java.net/java/GA/jdk11/9/GPL/openjdk-11.0.2_linux-x64_bin.tar.gz -O /tmp/openjdk-11.0.2_linux-x64_bin.tar.gz
mkdir -p /usr/lib/jvm
tar xvfz /tmp/openjdk-11.0.2_linux-x64_bin.tar.gz --directory /usr/lib/jvm
rm -f /tmp/openjdk-11.0.2_linux-x64_bin.tar.gz
update-alternatives --install /usr/bin/java java /usr/lib/jvm/jdk-11.0.2/bin/java 100
update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/jdk-11.0.2/bin/javac 100

mypass=${vnc_pass}

mkdir /root/.vnc
echo $mypass | vncpasswd -f > /root/.vnc/passwd
chown -R root:root /root/.vnc
chmod 0600 /root/.vnc/passwd

cat > ~/.vnc/xstartup <<- "EOF"
#!/bin/sh
#xrdb $HOME/.Xresources
startxfce4 &
EOF

chmod +x ~/.vnc/xstartup

vncserver :1
vncserver -kill :1
vncserver -nolisten tcp -localhost -geometry ${resolution} :1

wget -O ghidra.zip https://ghidra-sre.org/ghidra_9.0_PUBLIC_20190228.zip
sha256sum ghidra.zip > ghidra.zip.sha256
unzip -qq ghidra.zip