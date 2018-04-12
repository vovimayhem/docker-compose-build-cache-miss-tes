# Docker / Compose build cache miss test

This project demonstrates an issue I found when building the same image
using `docker-compose build` vs. `docker build`

## Running the demo

You'll need Docker + Compose:

### 1: Build the image using `docker-compose build`

Run the following command:

```bash
docker-compose build test
```

We should see the following output:

```
Building test
Step 1/4 : FROM alpine:3.7
3.7: Pulling from library/alpine
ff3a5c916c92: Pull complete
Digest: sha256:7df6db5aa61ae9480f52f0b3a06a140ab98d427f86d8d5de0bedab9b8df6b1c0
Status: Downloaded newer image for alpine:3.7
 ---> 3fd9065eaf02
Step 2/4 : RUN apk add --no-cache openssh-keygen
 ---> Running in 99dc5f571a2e
fetch http://dl-cdn.alpinelinux.org/alpine/v3.7/main/x86_64/APKINDEX.tar.gz
fetch http://dl-cdn.alpinelinux.org/alpine/v3.7/community/x86_64/APKINDEX.tar.gz
(1/1) Installing openssh-keygen (7.5_p1-r8)
Executing busybox-1.27.2-r7.trigger
OK: 4 MiB in 12 packages
Removing intermediate container 99dc5f571a2e
 ---> 72cd43e2d752
Step 3/4 : ADD blah.txt /usr/src/blah.txt
 ---> b3e38269511f
Step 4/4 : RUN apk add --no-cache openssh-client
 ---> Running in 7554745f0a64
fetch http://dl-cdn.alpinelinux.org/alpine/v3.7/main/x86_64/APKINDEX.tar.gz
fetch http://dl-cdn.alpinelinux.org/alpine/v3.7/community/x86_64/APKINDEX.tar.gz
(1/1) Installing openssh-client (7.5_p1-r8)
Executing busybox-1.27.2-r7.trigger
OK: 7 MiB in 13 packages
Removing intermediate container 7554745f0a64
 ---> 401ffe82377c

Successfully built 401ffe82377c
Successfully tagged vovimayhem/docker-compose-build-cache-miss:latest
```

### 2: Build the image using `docker build`

Run the following command:

```bash
docker build .
```

We are currently observing the following output:

```
Sending build context to Docker daemon  9.728kB
Step 1/4 : FROM alpine:3.7
 ---> 3fd9065eaf02
Step 2/4 : RUN apk add --no-cache openssh-keygen
 ---> Using cache
 ---> 72cd43e2d752
Step 3/4 : ADD blah.txt /usr/src/blah.txt
 ---> 04a8a8205b0e
Step 4/4 : RUN apk add --no-cache openssh-client
 ---> Running in 224ff1f5311f
fetch http://dl-cdn.alpinelinux.org/alpine/v3.7/main/x86_64/APKINDEX.tar.gz
fetch http://dl-cdn.alpinelinux.org/alpine/v3.7/community/x86_64/APKINDEX.tar.gz
(1/1) Installing openssh-client (7.5_p1-r8)
Executing busybox-1.27.2-r7.trigger
OK: 7 MiB in 13 packages
Removing intermediate container 224ff1f5311f
 ---> dd47cecace0d
Successfully built dd47cecace0d
```

Notice how the `Step 3/4` actually misses the cached layer built with
`docker-compose`, causing the `Step 4/4` to be run again.
