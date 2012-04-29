Ubuntu Scripts for OpDemand
===========================

This repository facilitates automation and orchestration on Ubuntu servers managed by OpDemand.
During first server build, this repository is cloned to `/var/lib/opdemand` using Ubuntu [cloud-init](https://help.ubuntu.com/community/CloudInit).
The files in `bin` will be linked to `/usr/local/bin` so they are pathed system-wide.

The following commands are the interface OpDemand uses to interact with
Ubuntu servers. **All scripts must be [idempotent](http://en.wikipedia.org/wiki/Idempotence)**.

opdemand-pull
-------------
Script to update the `/var/lib/opdemand` repository and any other deployment repositories
including `/usr/share/puppet/modules`.  

To ensure "opdemand-*" commands are always executed using the latest code, `opdemand-pull` 
is invoked by OpDemand prior to running any of the subsequent scripts.
However, it can be helpful to execute manually during server debug/testing, especially when
using a custom server repository.  Use `sudo opdemand-pull` to execute.

opdemand-build
--------------
Wrapper for OpDemand server builds, which are executed by OpDemand orchestration the first time a server is booted.

Because build scripts are only run on first boot, they should be used for 1-time actions to bootstrap a system.
Ideally build scripts will contain as little as possible, with most automation logic performed in `opdemand-deploy`.

To customize build scripts:

1. Fork <https://github.com/opdemand/opdemand-ubuntu>
2. Add your own scripts under the `scripts` directory
3. Override the "Build Script" path in the "Server" configuration section
 
Although this script will normally be invoked by OpDemand, use `sudo opdemand-build` to execute manually:

 - Reads in environment variables from /var/cache/opdemand
 - Uses the `$server_build_script` variable to find the correct build script
    - If the script is a URL, it is downloaded to /var/cache/opdemand/build
    - If the script is not a URL, it is treated as a relative path starting at /var/lib/opdemand (e.g "scripts/build_puppet.sh")
 - The build script is copied/downloaded to /var/cache/opdemand/build
 - Any user-defined `$server_build_additions` are added to the script
 - The script is executed with log output appended to `/var/log/opdemand/build.log`
 
opdemand-deploy
---------------
Wrapper for OpDemand server deploys, which occur on every server restart and every time the deploy action is triggered.  

Deploy scripts should be used to ensure the server is compliant with the latest "system policy".
Despite their learning curve, configuration management tools like Puppet and Chef are best suited to this task.
OpDemand templates use [Puppet modules](https://github.com/opdemand/puppet-modules) to achieve this, however, a policy-driven system administration approach *can* be implemented using idempotent shell scripts.

To customize deploy scripts:

1. Fork <https://github.com/opdemand/opdemand-ubuntu>
2. Add your own scripts under the `scripts` directory
3. Override the "Deploy Script" path in the "Server" configuration section

Although this script will normally be invoked by OpDemand, use `sudo opdemand-deploy` to execute manually:

 - Reads in environment variables from /var/cache/opdemand
 - Uses the `$server_deploy_script` variable to find the correct deploy script
    - If the script is a URL, it is downloaded to /var/cache/opdemand/deploy
    - If the script is not a URL, it is treated as a relative path starting at /var/lib/opdemand (e.g "scripts/deploy_puppet.py")
 - The build script is copied/downloaded to /var/cache/opdemand/deploy
 - Any user-defined `$server_deploy_additions` are added to the script
 - The script is executed with log output appended to `/var/log/opdemand/deploy.log`

opdemand-export
---------------
Script to update the `/var/cache/opdemand/inputs.sh` file to allow shell sourcing of dynamic
orchestration variables.

On every OpDemand-triggered action, `/var/cache/opdemand/inputs.json`
will be updated with a JSON version of the dynamic orchestration data.  This script
formats that data as key/val pairs of environment variables that live at `/var/cache/opdemand/inputs.sh`

It's important to note that any slashes in key names are converted to underscores.  For example to access the `server/build_script` variable use the following:

    . /var/cache/opdemand/inputs.sh    # source environment variables into your shell
    echo $server_build_script          # print out server_build_script

Any JSON lists will be space-separated when translated to environment variable form.  Dictionaries/Maps are not supported at present.

opdemand-output
---------------
Script to allow OpDemand to output dynamic orchestration variables following an `opdemand-deploy`.

It is often useful for the server to output custom key/value data to servers and other infrastructure
further downstream in the infrastructure stack.  This can be useful for passing dynamically generated
security keys, and any other user-defined values.

To use dynamic outputs, have your `opdemand-deploy` script populate `/var/cache/opdemand/outputs.json` with valid JSON.  For example:

    {"custom/secret_key": "xQU0PLDs4UX3k8lT6RJ1w0DStBlUki"}
    
On every OpDemand-triggered deploy, `/var/cache/opdemand/outputs.json` will be read, parsed and
included in the global execution context for downstream infrastructure.
