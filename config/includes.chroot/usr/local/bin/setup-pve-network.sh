#!/bin/bash
# If Live boot with persistence volume is configured, something keeps dynamically resetting /etc/network/interfaces to default ifupdown.
# I'm too lazy to figure it out so this script with systemd services in /etc/systemd/system/*-pve-network.service exists as a workaround

# Exit on error
set -e

case "$1" in
    start)
        # If regular file exists, backup first
        if [ -f /etc/network/interfaces ] && [ ! -L /etc/network/interfaces ]; then
            cp /etc/network/interfaces /etc/network/interfaces.bak
        fi
        # Create symlink
        rm -f /etc/network/interfaces
        ln -s /usr/local/share/interfaces /etc/network/interfaces
        ;;
    stop)
        # Save changes if symlink was replaced with regular file
        if [ -f /etc/network/interfaces ] && [ ! -L /etc/network/interfaces ]; then
            cp /etc/network/interfaces /usr/local/share/interfaces
        fi
        ;;
    *)
        echo "Usage: $0 {start|stop}"
        exit 1
        ;;
esac
