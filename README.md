
What is qBittorrent?
====================

[qBittorrent](http://www.qbittorrent.org/) NoX is the headless with remote web interface version of qBittorrent BitTorrent client.

How to use this image
=====================

This image is:

  * **Small**: `:latest` is based on official [Alpine](https://registry.hub.docker.com/_/alpine/) Docker image.
  * **Simple**: Exposes correct ports, configured for remote access...
  * **Secure**: Runs as non-root user with random UID/GID `520`, and handles correctly PID 1 (using dumb-init).

Usage
-----

All mounts and ports are optional and qBittorrent will work even with only:

    $ docker run 80x86/qbittorrent

... however that way some ports used to connect to peers are not exposed, accessing the
web interface requires you to proxy port 8080, and all settings as well as downloads will
be lost if the container is removed. So start it using this command:

```shell
    $ WEB_PORT=8082
    $ BT_PORT=8999
    $ mkdir -p config torrents downloads
	$ docker run -d --user $UID:$GID \
		-e WEB_PORT=8082 \
		-e BT_PORT=8999 \
		--restart=always \
		-p $WEB_PORT:$WEB_PORT -p $BT_PORT:$BT_PORT/tcp -p $BT_PORT:$BT_PORT/udp \
		-v $PWD/config:/config \
		-v $PWD/torrents:/torrents \
		-v $PWD/downloads:/downloads \
		80x86/qbittorrent
```

... to run as yourself and have WebUI running on [http://localhost:8082](http://localhost:8082)
(username: `admin`, password: `adminadmin`) with config in the following locations mounted:

  * `/config`: qBittorrent configuration files
  * `/torrents`: Torrent files
  * `/downloads`: Download location

Note: By default it runs as UID 520 and GID 520, but can run as any user/group.

It is probably a good idea to add `--restart=always` so the container restarts if it goes down.

You can change `8999` to some random  port number (also change in the settings).

_Note: For the container to run, the legal notice had to be automatically accepted. By running the container, you are accepting its terms. Toggle the flag in `qBittorrent.conf` to display the notice again._

_Note: `520` was chosen randomly to prevent running as root or as another known user on your system; at least until [issue #11253](https://github.com/docker/docker/pull/11253) is fixed._

Image Variants
--------------

### `80x86/qbittorrent:latest`

Latest release of qBittorrent (No X) compiled on Alpine Linux from source code.

User Feedbacks
==============

Having more issues? [Report a bug on GitHub](https://github.com/80x86/docker-qbittorrent/issues).
