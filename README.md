# Docker container to run GUI applications like Eclipse IDE

#### Upstream Links

* Docker Registry @[monstrenyatko/gui-app-run](https://hub.docker.com/r/monstrenyatko/gui-app-run/)
* GitHub @[monstrenyatko/docker-gui-app-run](https://github.com/monstrenyatko/docker-gui-app-run)

## Requirements

* X11 server (e.g., [X.Org](https://www.x.org), [XQuartz 2.7.11+](https://www.xquartz.org), [Xming](http://www.straightrunning.com/XmingNotes/))
* X11 server is configured to accept network connections
* Docker 18.06.1+
* `docker` command is working without `sudo`

## Quick Start example to run Eclipse IDE

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
* Create execution script for convenience:

```sh
#!/bin/bash

# Desired UID of the user inside container, keep it empty for default to `1000`
user_id=
# IP address of the host machine with running X11 server, see `host.docker.internal`
ip=<IP address>
# Allow connections to X11 server from host
# you might need to add IP of the docker machine, see `$(docker-machine ip $machine_name)`
xhost + localhost
# Remove old container if for some reason it was not removed automatically
docker rm eclipse
# Run
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
    monstrenyatko/gui-app-run                                                  \
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
* Get IP address automatically:

  - Set `ip` variable value to:

  ```sh
    ip=host.docker.internal
  ```
  - From `en0` interface. Set `ip` variable value to:

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
* Use default GTK theme

  - Add to the `Docker` command before `Eclipse` binary invocation:

  ``` sh
        && unset GTK_THEME                                                     \
  ```

## Tested On

* Mac OS 10.13.6 High Sierra, XQuartz 2.7.11:
  - Eclipse 4.6 Neon
