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
gem install foreman -v 0.47.0
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
mkdir -p $PUPPET_REPOSITORY_PATH
git clone --recursive $PUPPET_REPOSITORY_URL $PUPPET_REPOSITORY_PATH
cd $PUPPET_REPOSITORY_PATH && git checkout -f $PUPPET_REPOSITORY_REVISION

# install bugfix not yet integrated into puppet master
gem install --no-ri --no-rdoc puppet --version 2.7.14
install /var/lib/opdemand/files/upstart.rb /usr/lib/ruby/gems/1.8/gems/puppet-2.7.14/lib/puppet/provider/service
install /var/lib/opdemand/files/init.rb /usr/lib/ruby/gems/1.8/gems/puppet-2.7.14/lib/puppet/provider/service
