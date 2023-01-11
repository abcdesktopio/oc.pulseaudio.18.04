FROM ubuntu:18.04

MAINTAINER Alexandre DEVELY

ENV PULSEUID=102
ENV PULSEGID=104
ENV PULSELOGNAME=pulse
ENV PULSEUSER=pulse
ENV PULSEGROUP=pulse

# correct debconf: (TERM is not set, so the dialog frontend is not usable.)
ENV DEBCONF_FRONTEND noninteractive
ENV TERM linux
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Next command use $BUSER context
RUN groupadd --gid $PULSEGID $PULSEUSER
RUN useradd --create-home --shell /bin/bash --uid $PULSEUID -g $PULSEUSER --groups sudo $PULSEUSER

RUN DEBIAN_FRONTEND=noninteractive  apt-get update && apt-get install -y --no-install-recommends\
        pulseaudio                      \
        pulseaudio-utils                \
	dbus				\
	openssl				\
        && apt-get clean		

## DBUS SECTION
RUN 	mkdir -p /var/run/dbus 		&& \
	touch /var/lib/dbus/machine-id  && \
	chown -R $PULSEUSER:$PULSEGROUP     \
                /var/run/dbus              \
                /var/lib/dbus              \
                /var/lib/dbus/machine-id

COPY etc/pulse /etc/pulse
RUN  chown -R $PULSEUID:$PULSEGID /etc/pulse 

# hack: be shure to own the home dir 
RUN chown -R $PULSEUSER:$PULSEGROUP /home/$PULSEUSER \
    && chown -R $PULSEUSER:$PULSEGROUP /etc/pulse \
    && echo `date` > /etc/build.date

COPY docker-entrypoint.sh /docker-entrypoint.sh
USER pulse
CMD /docker-entrypoint.sh

# expose pulseaudio tcp port
EXPOSE 4713 4714
