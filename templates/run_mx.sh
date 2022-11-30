#!/bin/bash

set -efx -o pipefail

export ALTOSHOME=/tools/cadence/LIBERATE/LIBERATE217
export PATH=$ALTOSHOME/bin:$ALTOSHOME/tools.lnx86/spectre/bin:$PATH
export CDS_AUTO_64BIT=ALL

source /tools/B/rahulkumar/sky130/priv/drc/.bashrc

liberate_mx {{ mx_path }}
