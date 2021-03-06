FROM tbeck/raspbian:latest

MAINTAINER Tim Beck <tmbeck@gmail.com>

# To satisfy the openjdk package.
RUN mkdir -p /usr/share/man/man1/

RUN apt-get update && apt-get install -y \ 
	openjdk-8-jre-headless
	
# may need to dpkg-reconfigure ca-certificates

ADD install.sh /
ADD CrashPlan_4.7.0_Linux.tgz /

RUN mkdir -p /usr/local/crashplan

WORKDIR /usr/local/crashplan
RUN cat /crashplan-install/CrashPlan_4.7.0.cpi | gzip -d -c - | cpio -i --no-preserve-owner && \
	rm -f /usr/local/crashplan/libjtux.so
ADD libjtux.so /usr/local/crashplan/

# Setup default runtime environment
WORKDIR /crashplan-install
RUN /install.sh && \
	rm -f /install.sh && \
	rm -f /CrashPlan_4.7.0_Linux.tgz && \
	rm -rf /crashplan-install
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# See https://support.code42.com/CrashPlan/4/Troubleshooting/Identifying_Ports_Used_By_The_Code42_CrashPlan_App
EXPOSE 4242
EXPOSE 4243

ENV JAVACOMMON=/usr/bin/java
ENV LC_ALL=en_US.UTF-8
ENV LC_CTYPE=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV TARGETDIR="/usr/local/crashplan"
ENV CPD="${TARGETDIR}/lib/com.backup42.desktop.jar"
ENV FULL_CP="${CPD}:${TARGETDIR}/lang"
ENV SRV_JAVA_OPTS="-Dfile.encoding=UTF-8 -Dapp=CrashPlanService -DappBaseName=CrashPlan -Xms20m -Xmx1024m -Dsun.net.inetaddr.ttl=300 -Dnetworkaddress.cache.ttl=300 -Dsun.net.inetaddr.negative.ttl=0 -Dnetworkaddress.cache.negative.ttl=0 -Dc42.native.md5.enabled=false"

WORKDIR /usr/local/crashplan
CMD $JAVACOMMON $SRV_JAVA_OPTS -classpath $FULL_CP com.backup42.service.CPService
