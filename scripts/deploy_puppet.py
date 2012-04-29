#!/usr/bin/python
import json
import subprocess
import sys

# open opdemand inputs
with open('/var/cache/opdemand/inputs.json') as f:
    data = f.read()

# deserialize json inputs
inputs = json.loads(data)

# read puppet classes, default to opdemand::common
puppet_classes = inputs.get('puppet/classes', ["opdemand::common"])

# prepare puppet apply manifest using ordered list of classes
statements = []
for cls in puppet_classes:
    statements.append('class {"%s":}' % cls)
manifest = ' -> '.join(statements)

# write out puppet classes to stdout
sys.stdout.write("applying puppet classes: %s\n" % ' '.join(puppet_classes))
sys.stdout.flush()

# read debug flag
debug = inputs.get('puppet/debug', False)
if debug:
    debug_flag = '-d'
else:
    debug_flag = '-v'

# prepare exec args
args = [ "puppet", "apply", debug_flag, "-e", manifest]

# exec puppet apply
subprocess.check_call(args)
