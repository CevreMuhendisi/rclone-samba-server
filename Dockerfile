FROM dperson/samba:latest
COPY smb.conf /etc/samba/smb.conf
RUN apk --no-cache --no-progress upgrade && apk --no-cache --no-progress add unzip supervisor fuse fuse3 nano
COPY supervisord.conf /etc/supervisord.conf
COPY rclone-mount.sh /rclone-mount.sh
RUN chmod +x /rclone-mount.sh
RUN wget https://downloads.rclone.org/v1.66.0/rclone-v1.66.0-linux-amd64.zip && \
    unzip rclone*.zip && cd rclone-v* && cp rclone /usr/bin/ && \
    chown root:root /usr/bin/rclone && chmod 755 /usr/bin/rclone && rm -R /rclone-v*
RUN mkdir -p /mnt/remote
VOLUME ["/rclone/config", "/rclone/cache"]

# important because otherwise there are problems with write/move access to the rclone mounts
ENV GLOBAL="vfs objects ="

ENV GROUPID=0
ENV USERID=0
ENV PERMISSIONS=true
ENV RECYCLE=false

# to change in production environments, just some defaults
ENV USER="pi;pi2"
ENV SHARE="remote;/mnt/remote;yes;no;no;pi;none;;;"

ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
