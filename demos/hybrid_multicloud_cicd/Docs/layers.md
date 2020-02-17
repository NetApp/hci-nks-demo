# Docker Images

### File system layers

*Each image consists of a series of layers. Docker makes use of union file systems to combine these layers into a single image. Union file systems allow files and directories of separate file systems, known as branches, to be transparently overlaid, forming a single coherent file system*

1. Start with a base image
1. Add custom code
1. Add static application data
1. Add configuration data 
~~~~
  IMAGE               CREATED             CREATED BY                                      SIZE                COMMENT
  ac44715da54a    2 weeks ago         /bin/sh -c #(nop)  CMD ["nginx" "-g" "daemon…        0B
  <missing>           2 weeks ago         /bin/sh -c #(nop)  STOPSIGNAL SIGTERM                     0B
  <missing>           2 weeks ago         /bin/sh -c #(nop)  EXPOSE 80                                        0B
  <missing>           2 weeks ago         /bin/sh -c ln -sf /dev/stdout /var/log/nginx…           22B
  <missing>           2 weeks ago         /bin/sh -c set -x  && apt-get update  && apt…           54.1MB
  <missing>           2 weeks ago         /bin/sh -c #(nop)  ENV PKG_RELEASE=1~stretch         0B
  <missing>           2 weeks ago         /bin/sh -c #(nop)  ENV NJS_VERSION=0.3.1                  0B
  <missing>           2 weeks ago         /bin/sh -c #(nop)  ENV NGINX_VERSION=1.16.0           0B
  <missing>           2 weeks ago         /bin/sh -c #(nop)  LABEL maintainer=NGINX Do…        0B
  <missing>           2 weeks ago         /bin/sh -c #(nop)  CMD ["bash"]                                      0B
  <missing>           2 weeks ago         /bin/sh -c #(nop) ADD file:5ffb798d64089418e…       55.3MB
~~~~

# Nothing you save to a container is persistent, when you stop, restart, reload, replace a container the data is **GONE**
### To fix this you store your dynamic data as a persistent volume, mounted to the container
#### This is what Trident is for, Trident processes a persistent volume claim and converts it into instructions for how to mount a volume. It is not in the data path.

