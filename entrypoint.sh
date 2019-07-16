#!/bin/sh -e

# Default configuration file
if [ ! -f /config/qBittorrent.conf ]
then
	echo "init default config ..."
	cp /default/qBittorrent.conf /config/qBittorrent.conf
fi

echo "init config ..."
sed -i "s|Connection\\\PortRangeMin=.*|Connection\\\PortRangeMin=${BT_PORT}|i" /config/qBittorrent.conf
sed -i "s|WebUI\\\Port=.*|WebUI\\\Port=${WEB_PORT}|i" /config/qBittorrent.conf

# Allow groups to change files.
umask 002

exec "$@"
