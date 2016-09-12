Raspbian-based CrashPlan Docker Container
=========================================

This Dockerfile and associated build script generates a container capable of running crashplan on both amd64 and Raspberry Pi hosts (albeit terribly slowly; see notes).

This container has been "successfully" tested on both amd64 (Arch Linux) and Raspberry Pi (all flavors, ARM) hosts. For example, this container runs on a Linux amd64 host running Arch and a Raspberry Pi running Arch for ARM.

Usage
=====

# (Optional) Expose ports 4242 and 4243 using -p
# (Optional) Mount configuration data volumes
# Mount desired backup data volumes
# Wait (and wait..) for /var/lib/crashplan/.ui_info to appear
# Get GUID from .ui_info file so you can remotely connect to the crashplan service
# Wait for the /usr/local/crashplan/my.service.xml to be generated
# Modify /usr/local/crashplan/my.service.xml, changing <serviceHost>localhost</serviceHost> to <serviceHost>0.0.0.0</serviceHost> (sed -i 's/localhost/0.0.0.0/' /usr/local/crashplan/conf/my.service.xml)
# Restart the container

Using the Container
===================

If at all possible, I recommend using a data volume to host your configuration files. They are stored in the container at /usr/local/crashplan/conf and /var/lib/crashplan. This makes it much easier to manage.


Using the GUI
=============

CrashPlan has a reasonable GUI for interfacing with the crashplan service. Unfortunately, various stupid hoops have to be jumped through in order to access and administrate remote clients.

First and foremost is the /var/lib/crashplan/.ui_info file, which contains a single, comma-delimited line of port,GUID,host. The GUID of the machine running the GUI must match the machine running the service.


Notes
=====

So far the performance is incredibly poor - almost unusuably slow. System startup is on the order of 10-20 minutes (no joke, that's minutes) with the primary bottleneck seeming to be java (it hits the CPU hard almost continuously on any architecture). Removing the qemu-user-static binary has no impact. No serous investigation or profiling has been performed yet. I wrote almost all this documentation in the time it took to start a container.

It takes about 15 minutes after initial startup for the /var/lib/crashplan/.ui_info file to appear, which is required before remotes can connect to the crashplan service daemon.

The my.service.xml file isn't created until /after/ you've started the crashplan service for the first time. By default, the crashplan service listens on localhost (defined by the serviceHost variable). In order for port forwarding to work correctly, the service has to be modified to listen on all interfaces (0.0.0.0). Alternatively, you can use --net=host to share the network stack of the container with the host; this simplifies things but is not recommended.


Licensing
=========

This Docker container depends on OpenJDK. This is by design. Oracle's JDK might work (might even be faster...) but this opens everyone up to hillarious legal issues. Maybe one day Oracle (Sun) will get its shit together, but judging by the last two decades of their stewardship of Java I wouldn't bet on it. If you're curious, read [Running Java on Docker? You're breaking the Law](http://blog.takipi.com/running-java-on-docker-youre-breaking-the-law/).


TODO
====

* ~~Add container and scripts for building libjtux.so~~
** Done
* ~~Move to dockerhub~~
** Semi-done, images are currently in my private Docker repo (where they'll remain due to the questionable licensing issues surrounding this).

