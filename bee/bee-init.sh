#!/bin/sh
rm /var/lib/bee/password
cp /keys/* /var/lib/bee/keys
chown bee:bee /var/lib/bee/keys/*
cp ./bee.yaml /etc/bee/bee.yaml
