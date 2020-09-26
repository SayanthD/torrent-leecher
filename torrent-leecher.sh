#!/bin/bash

aria2c \
	--daemon=true \
	--enable-rpc \
	--rpc-listen-all=false \
	--rpc-listen-port=6800 \
	--rpc-max-request-size=1024M \
	--bt-stop-timeout=600 \
	--conf-path=/app/tobrot/aria2/aria2.conf &
python3 -m tobrot
