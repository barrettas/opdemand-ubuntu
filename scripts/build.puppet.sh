#!/bin/sh
#
# puppet-specific server build (run once on first boot)
#

# source orchestration inputs as environment vars
. /var/cache/opdemand/inputs.sh

# execute common build scrip
/var/lib/opdemand/scripts/ubuntu/common.sh

# install puppet modules
gem install puppet hiera hiera-json hiera-puppet 

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
