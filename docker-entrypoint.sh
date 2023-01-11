#!/bin/bash


export UID=102
export GID=104
export LOGNAME=pulse
export USER=pulse
export HOME=/home/pulse

# dump for debug
id > /tmp/docker-entrypoint-pulseaudio.log
env >> /tmp/docker-entrypoint-pulseaudio.log
echo "ls -la $HOME" >> /tmp/docker-entrypoint-pulseaudio.log
ls -la $HOME >> /tmp/docker-entrypoint-pulseaudio.log
echo "ls done" >> /tmp/docker-entrypoint-pulseaudio.log
ls -la /etc/pulse >> /tmp/docker-entrypoint-pulseaudio.log

CONTAINER_IP_ADDR=$(hostname -i)
echo "Container local ip addr is $CONTAINER_IP_ADDR"
export CONTAINER_IP_ADDR

# replace CONTAINER_IP_ADDR in listen for pulseaudio
# sed -i "s/module-http-protocol-tcp/module-http-protocol-tcp listen=$CONTAINER_IP_ADDR/g" /etc/pulse/default.pa 
# sed -i "s/module-native-protocol-tcp/module-native-protocol-tcp listen=$CONTAINER_IP_ADDR/g" /etc/pulse/default.pa 

if [ ! -z "$PULSEAUDIO_COOKIE" ]; then
  mkdir -p ~/.config/pulse
  cat /etc/pulse/cookie | openssl rc4 -K "$PULSEAUDIO_COOKIE" -nopad -nosalt > ~/.config/pulse/cookie  
fi

#mkdir -p /home/balloon/.pulseaudio
# /usr/bin/pulseaudio --log-level=0 --log-target=newfile:/tmp/docker-entrypoint-pulseaudio.pulseaduio.log 
#HOME=/home/balloon/.pulseaudio 


#  -L, --load="MODULE ARGUMENTS"         Load the specified plugin module with
#                                        the specified argument


/usr/bin/pulseaudio --load="module-http-protocol-tcp listen=$CONTAINER_IP_ADDR" --load="module-native-protocol-tcp listen=$CONTAINER_IP_ADDR"
