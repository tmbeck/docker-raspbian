FROM tbeck/raspbian:latest
MAINTAINER Tim Beck <tmbeck@gmail.com>

RUN apt-get update && apt-get install --no-install-recommends -y git libjna-java openjdk-8-jdk patch make gcc libc6-dev

# When running without --verbose, git clone hangs indefinitely.
RUN git clone --verbose --depth=1 https://github.com/swenson/jtux

WORKDIR /jtux

# Target openjdk-8 rather than openjdk-6
RUN sed -i 's/java-6-openjdk/java-8-openjdk/' Makefile && make -j2

ENTRYPOINT [ "/bin/sh" ]
