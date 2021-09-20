FROM evilmachine/alpine
#FROM brandonc/docker-vault:1.2.3

ARG service_user=vault
ARG system_dirs="/bin /etc /lib /sbin /usr"

RUN addgroup -g 1001 $service_user && \
    adduser -u 1001 -S -G $service_user $service_user

RUN rm -rf /var/spool/cron \
           /etc/crontabs \
           /etc/periodic
            
RUN rm -rf /usr/sbin/login_duo \
           /usr/sbin/setup-proxy \
           /usr/sbin/sshd \
           /usr/sbin/start.sh

RUN find / -xdev -type d -perm +0002 -exec chmod o-w {} + && \
    find / -xdev -type f -perm +0002 -exec chmod o-w {} +

RUN sed -i -r "/^(${service_user}|root|sshd)/!d" /etc/group && \
    sed -i -r "/^(${service_user}|root|sshd)/!d" /etc/passwd

RUN sed -i -r '/^'${service_user}':/! s#^(.*):[^:]*$#\1:/sbin/nologin#' /etc/passwd

RUN find $system_dirs -xdev -regex '.*apk.*' -exec rm -rf {} +
RUN find $system_dirs -xdev -type f -regex '.*-$' -exec rm -f {} +



RUN find $system_dirs -xdev -type f -a -perm +4000 -delete

RUN find $system_dirs -xdev \( \
    -name hexdump -o \
    -name chgrp -o \
    -name chmod -o \
    -name chown -o \
    -name ln -o \
    -name od -o \
    -name strings -o \
    -name su \
    \) -delete

RUN rm -rf /etc/init.d \
    rm -rf /lib/rc \
    rm -rf /etc/conf.d \
    rm -rf /etc/inittab \
    rm -rf /etc/runlevels \
    rm -rf /etc/rc.conf

RUN rm -rf /etc/sysctl* \
    rm -rf /etc/modprobe.d \
    rm -rf /etc/modules \
    rm -rf /etc/mdev.conf \
    rm -rf /etc/acpi

RUN rm -rf /root
RUN rm -f /etc/fstab
RUN find $system_dirs -xdev -type l -exec test ! -e {} \; -delete


EXPOSE 8200
ENTRYPOINT  ["vault"]

