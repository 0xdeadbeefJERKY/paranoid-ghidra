#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive
 
sudo apt-get update
sudo apt-get install -y git tmux wget ${desktop_packages} unzip
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

# Change "GNOME" to "KDE" for a KDE desktop, or "" for a generic desktop
MODE="${mode}"

#Uncommment this line if using Gnome and your keyboard mappings are incorrect.
#export XKL_XMODMAP_DISABLE=1

# Load X resources (if any)
if [ -e "$HOME/.Xresources" ]
then
        xrdb "$HOME/.Xresources"
fi

# Try a GNOME session (try KDE, then xfce4, then generic if this fails)
if [ "GNOME" = "$MODE" ]
then
        if which gnome-session >/dev/null
        then
                export XKL_XMODMAP_DISABLE=1
                export XDG_CURRENT_DESKTOP="GNOME-Flashback:GNOME"
                export XDG_MENU_PREFIX="gnome-flashback-"

                gnome-session --session=gnome-flashback-metacity --disable-acceleration-check &
                #gnome-session --session=ubuntu-2d &
        else
                MODE="KDE"
        fi
fi

# Try a KDE session (try xfce4, then generic if this fails)
if [ "KDE" = "$MODE" ]
then
        if which startkde >/dev/null
        then
                startkde &
        else
                MODE="xfce4"
        fi
fi

# Try a xfce4 session, or fall back to generic
if [ "xfce4" = "$MODE" ]
then
        if which startxfce4 >/dev/null
        then
                startxfce4 &
        else
                MODE=""
        fi
fi

# Run a generic session
if [ -z "$MODE" ]
then
        xsetroot -solid "#DAB082"
        x-terminal-emulator -geometry "80x24+10+10" -ls -title "$VNCDESKTOP Desktop" &
        x-window-manager &
fi
EOF

chmod +x ~/.vnc/xstartup

wget -O ghidra.zip https://ghidra-sre.org/ghidra_9.0_PUBLIC_20190228.zip
sha256sum ghidra.zip > ghidra.zip.sha256
unzip -qq ghidra.zip

cat > /usr/local/bin/runvnc <<- "EOF"
#!/bin/bash
PATH="$PATH:/usr/bin"
 
case "$1" in
start)
/usr/bin/vncserver -nolisten tcp -localhost -geometry ${resolution} :1
;;
 
stop)
/usr/bin/vncserver -kill :1
;;
 
restart)
$0 stop
$0 start
;;
esac
exit 0
EOF

chmod +x /usr/local/bin/runvnc

cat > /lib/systemd/system/runvnc.service <<- "EOF"
[Unit]
Description=VNC Server
 
[Service]
Type=forking
Environment="SHELL=/bin/bash"
ExecStart=/usr/local/bin/runvnc start
ExecStop=/usr/local/bin/runvnc stop
ExecReload=/usr/local/bin/runvnc restart
User=root
 
[Install]
WantedBy=multi-user.target
EOF

systemctl import-environment SHELL
systemctl daemon-reload
systemctl enable runvnc
systemctl start runvnc
