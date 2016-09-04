FROM scratch
MAINTAINER Tim Beck <tmbeck@gmail.com>

ADD rootfs.tar.gz /

# Clean up for raspbian
RUN wget https://archive.raspbian.org/raspbian.public.key -O - | apt-key add -
RUN echo "deb http://archive.raspbian.org/raspbian stable main contrib non-free" > /etc/apt/sources.list
RUN apt-get update && apt-get upgrade -y 
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENTRYPOINT [ "/bin/sh", "-c" ]
