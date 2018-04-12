# Docker / Compose build cache miss test

This project demonstrates an issue I found when building the same image
using `docker-compose build` vs. `docker build`. The issue was reported on [docker/compose#5873](https://github.com/docker/compose/issues/5873).

## Running the demo

You'll need Docker + Compose:

### 1: Build the image using `docker build`

Run the following command:

```bash
$ docker build .
```

We should see the following output:

```
Sending build context to Docker daemon   7.68kB
Step 1/4 : FROM alpine:3.7
3.7: Pulling from library/alpine
ff3a5c916c92: Pull complete
Digest: sha256:7df6db5aa61ae9480f52f0b3a06a140ab98d427f86d8d5de0bedab9b8df6b1c0
Status: Downloaded newer image for alpine:3.7
 ---> 3fd9065eaf02
Step 2/4 : RUN apk add --no-cache openssh-keygen
 ---> Running in f3aa31fbbe9a
fetch http://dl-cdn.alpinelinux.org/alpine/v3.7/main/x86_64/APKINDEX.tar.gz
fetch http://dl-cdn.alpinelinux.org/alpine/v3.7/community/x86_64/APKINDEX.tar.gz
(1/1) Installing openssh-keygen (7.5_p1-r8)
Executing busybox-1.27.2-r7.trigger
OK: 4 MiB in 12 packages
Removing intermediate container f3aa31fbbe9a
 ---> 69526ecc54c7
Step 3/4 : ADD blah.txt /usr/src/blah.txt
 ---> 2ca5d35f9d8a
Step 4/4 : RUN apk add --no-cache openssh-client
 ---> Running in aa8fa691d561
fetch http://dl-cdn.alpinelinux.org/alpine/v3.7/main/x86_64/APKINDEX.tar.gz
fetch http://dl-cdn.alpinelinux.org/alpine/v3.7/community/x86_64/APKINDEX.tar.gz
(1/1) Installing openssh-client (7.5_p1-r8)
Executing busybox-1.27.2-r7.trigger
OK: 7 MiB in 13 packages
Removing intermediate container aa8fa691d561
 ---> b3bf2a57bb20
Successfully built b3bf2a57bb20
```

### 2: Build the image using `docker-compose build`

Run the following command:

```bash
docker-compose build test
```

We are currently observing the following output:

```
Building test
Building test
Step 1/4 : FROM alpine:3.7
 ---> 3fd9065eaf02
Step 2/4 : RUN apk add --no-cache openssh-keygen
 ---> Using cache
 ---> 69526ecc54c7
Step 3/4 : ADD blah.txt /usr/src/blah.txt
 ---> 127556331931
Step 4/4 : RUN apk add --no-cache openssh-client
 ---> Running in 6f4994391e39
fetch http://dl-cdn.alpinelinux.org/alpine/v3.7/main/x86_64/APKINDEX.tar.gz
fetch http://dl-cdn.alpinelinux.org/alpine/v3.7/community/x86_64/APKINDEX.tar.gz
(1/1) Installing openssh-client (7.5_p1-r8)
Executing busybox-1.27.2-r7.trigger
OK: 7 MiB in 13 packages
Removing intermediate container 6f4994391e39
 ---> 72bdc03430ef

Successfully built 72bdc03430ef
Successfully tagged vovimayhem/docker-compose-build-cache-miss:latest
```

Notice how the `Step 3/4` actually misses the cached layer built with
`docker build`, causing steps 3 & 4 to be run again.
