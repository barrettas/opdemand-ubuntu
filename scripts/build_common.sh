#!/bin/sh

# Common build script for OpDemand-powered Ubuntu servers
# This script is not invoked directly, but rather by a
# configuration management specific wrapper (e.g. build.puppet.sh)

# source orchestration inputs as environment vars
. /var/cache/opdemand/inputs.sh

# set locale for calls that require encoding
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# prevent dpkg prompting
export DEBIAN_FRONTEND=noninteractive

# install and update rubygems
apt-get install rubygems -yq
gem install --no-ri --no-rdoc rubygems-update && update_rubygems

# install required system gems
gem install --no-ri --no-rdoc foreman -v 0.47.0

