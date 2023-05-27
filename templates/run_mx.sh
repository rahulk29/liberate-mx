#!/usr/bin/bash

# --------------------------------------------------------------------------------
# This script was written and developed by the LIBERATE_MX PLUGIN at UC Berkeley;
# however, the underlying commands and reports are copyrighted by Cadence. We
# thank Cadence for granting permission to share our research to help promote and
# foster the next generation of innovators.
# --------------------------------------------------------------------------------


export ALTOSHOME=/tools/cadence/LIBERATE/LIBERATE217
export PATH=$ALTOSHOME/bin:$ALTOSHOME/tools.lnx86/spectre/bin:$PATH
export CDS_AUTO_64BIT=ALL

source /tools/B/rahulkumar/sky130/priv/drc/.bashrc

liberate_mx {{ mx_path }}
