#!/bin/bash
#======================================
# Functions...
#--------------------------------------
test -f /.kconfig && . /.kconfig
test -f /.profile && . /.profile

#======================================
# Greeting...
#--------------------------------------
echo "Configure image: [$kiwi_iname]..."

#======================================
# Activate services
#--------------------------------------
baseInsertService dbus-broker
baseInsertService systemd-networkd
baseInsertService systemd-resolved
baseInsertService podman-bee

#======================================
# Setup default target, multi-user
#--------------------------------------
baseSetRunlevel 3

locale-gen "en_US.UTF-8"
