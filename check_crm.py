#!/usr/bin/env python3
import subprocess
import sys

# Nagios plugin return codes
OK = 0
WARNING = 1
CRITICAL = 2
UNKNOWN = 3

# Run the command and capture its output
try:
    output = subprocess.check_output(['crm_mon', '-1r'], stderr=subprocess.STDOUT, universal_newlines=True)
except subprocess.CalledProcessError as e:
    print(f'ERROR: {e.output}', end='')
    sys.exit(UNKNOWN)

# Check the output against the reference file
try:
    with open('./ref/crm_mon', 'r') as f:
        ref_output = f.read()
except FileNotFoundError:
    print('ERROR: Reference file not found')
    sys.exit(UNKNOWN)

if output.decode() == ref_output:
    print(f'OK: Output matches reference file')
    sys.exit(OK)
else:
    print(f'CRITICAL: Output does not match reference file')
    sys.exit(CRITICAL)
