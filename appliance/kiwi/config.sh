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
baseInsertService gdm

#======================================
# Setup default target, graphical
# multi-user system with network 
# services
#--------------------------------------
baseSetRunlevel 5
