#!/bin/sh

# Example deploy script for OpDemand-powered Ubuntu servers
# NOTE: this script must be idemptoent!

# source orchestration inputs as environment vars
. /var/cache/opdemand/inputs.sh

# set locale for calls that require encoding
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# prevent dpkg prompting
export DEBIAN_FRONTEND=noninteractive

# install fail2ban
apt-get install -yq fail2ban

# perform idemtotent deploy actions that run on every deploy