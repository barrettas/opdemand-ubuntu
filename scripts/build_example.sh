#!/bin/sh

# Example build script for OpDemand-powered Ubuntu servers
# For customization, best practice is to leave this file alone
# and create a separate directory structure to better organize your scripts

# source orchestration inputs as environment vars
. /var/cache/opdemand/inputs.sh

# set locale for calls that require encoding
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# prevent dpkg prompting
export DEBIAN_FRONTEND=noninteractive

# perform one-time actions that run on first server boot only