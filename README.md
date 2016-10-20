# Docker container to run Eclipse IDE

#### Upstream Links

* Docker Registry @[monstrenyatko/docker-eclipse-run](https://hub.docker.com/r/monstrenyatko/docker-eclipse-run/)
* GitHub @[monstrenyatko/docker-eclipse-run](https://github.com/monstrenyatko/docker-eclipse-run)

## Requirements

* X11 server (e.g., [X.Org](https://www.x.org), [XQuartz 2.7.10+](https://www.xquartz.org), [Xming](http://www.straightrunning.com/XmingNotes/))
* X11 server is configured to accept network connections
* Docker 1.12+
* `docker` command is working without `sudo`

## Quick Start

* Prepare environment/directories to persist state/plugins between container executions:
```sh
export WORK_ECLIPSE_HOME=$HOME/Eclipse
export WORK_ECLIPSE_BIN=$WORK_ECLIPSE_HOME/bin
export WORK_ECLIPSE_SETTINGS=$WORK_ECLIPSE_HOME/setting
export WORK_ECLIPSE_WORKSPACE=$WORK_ECLIPSE_HOME/workspace
mkdir -p $WORK_ECLIPSE_BIN $WORK_ECLIPSE_SETTINGS $WORK_ECLIPSE_WORKSPACE
```

* Download `Linux` `Eclipse` [package](http://www.eclipse.org/downloads/eclipse-packages)

* Extract `Eclipse` package content to `$WORK_ECLIPSE_BIN` directory.
Path to executable file like `$WORK_ECLIPSE_BIN/eclipse` must be valid

* Pull prebuilt `Docker` image compatible with `Eclipse Neon`:
```sh
docker pull monstrenyatko/docker-eclipse-run:neon
```

* Create execution script for convenience:

```sh
#!/bin/bash

# Desired UID of the user inside container, keep it empty for default to 1000
user_id=
# IP address of the host machine with running X11 server
ip=<IP address>

docker run --rm --name eclipse --net=host                                      \
    -e LOCAL_USER_ID=$user_id                                                  \
    -e DISPLAY=$ip:0                                                           \
                                                                               \
    -v $WORK_ECLIPSE_BIN:/opt/eclipse                                          \
    -v $WORK_ECLIPSE_WORKSPACE:/cfg/eclipse/workspace                          \
    -v $WORK_ECLIPSE_SETTINGS:/cfg/eclipse/.eclipse                            \
    -e ECLIPSE_HOME=/opt/eclipse                                               \
    -e SWT_GTK3=1                                                              \
                                                                               \
    monstrenyatko/docker-eclipse-run:neon                                      \
                                                                               \
    bash -c "                                                                  \
            ln -s /cfg/eclipse/workspace \$HOME/workspace                      \
        &&  ln -s /cfg/eclipse/.eclipse \$HOME/.eclipse                        \
                                                                               \
        &&  \$ECLIPSE_HOME/eclipse                                             \
    "
```

## Tricks

* Share host `Maven` repository if required:
  - Add to `Docker` run options:
  ```sh
    -v $HOME/.m2/repository:/m2_repo                                           \
    -e M2_REPO=/m2_repo                                                        \
  ```
  - Add to the `Docker` command before `Eclipse` binary invocation:
  ```sh
        &&  mkdir \$HOME/.m2 && ln -s \$M2_REPO \$HOME/.m2/repository          \
  ```

* Make `UID` of the `Docker` user equal with host user:
  - Change `user_id` variable value to:
  ```sh
    user_id=`id -u $USER`
  ```

* Get IP address automatically on `Mac OS` from `en0` interface:
  - Set `ip` variable value to:
  ```sh
    ip=$(ifconfig en0 | grep inet | awk '$1=="inet" {print $2}')
  ```

* Switch to `GTK2`:
  - Change `SWT_GTK3` value to `0`

* Allow connections from your local machine to the X server:
  - Add before execution of the `docker` command:
  ```sh
    xhost + $ip
  ```

## Tested On

* Mac OS 10.11.6 El Capitan, XQuartz 2.7.10_rc5:
  - Eclipse 4.6 Neon
