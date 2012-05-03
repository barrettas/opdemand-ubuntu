#!/bin/sh
#
# puppet-specific server build (run once on first boot)
#

# set locale for calls that require encoding
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# prevent dpkg prompting
export DEBIAN_FRONTEND=noninteractive

# source orchestration inputs as environment vars
. /var/cache/opdemand/inputs.sh

# execute common build script
/var/lib/opdemand/scripts/build_common.sh

# install puppet package
apt-get install -yq puppet

# install puppet modules
gem install --no-ri --no-rdoc hiera hiera-json hiera-puppet 

# install hiera config file
cat > /etc/puppet/hiera.yaml <<EOF
---
:backends: - json
           - puppet

:logger: console

:hierarchy: - inputs

:json:
   :datadir: /var/cache/opdemand

:puppet:
   :datasource: data
EOF

# clone puppet repository and checkout specified revision
mkdir -p $puppet_repository_path
git clone --recursive $puppet_repository_url $puppet_repository_path
cd $puppet_repository_path && git checkout -f $puppet_repository_revision
