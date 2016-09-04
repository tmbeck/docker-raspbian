Brief
=====

This Dockerfile and associated build script will compile the libjtux.so file,
notoriously required to run CrashPlan on Linux (in this case, raspbian, i.e.,
armhf).

This uses the raspbian base image to install a compiler and the Java 8 JDK,
then clones and builds this github repo: https://github.com/swenson/jtux/

The build script then obtains a copy of the libjtux.so binary from a container
for use by the host.

