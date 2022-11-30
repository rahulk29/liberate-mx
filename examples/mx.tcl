### USER SETTINGS ####################################

# Set cell name and bitcell type (single-port, dual-port, rom)
set cell sramgen_sram_8x128m4w2_simple
set words 128
set bits 8
set bitcell single_port

# Choose corner to run
# Choices: {ss, tt, ff}
set corner tt

### DESIGN OPTIONS ####################################

# Hack existing netlist
# exec ./scripts/replace_primitives.sh src/$cell.spice

# Identify primitives (leafcells)
define_leafcell -type nmos { npass npd nshort }
define_leafcell -type pmos { pshort ppu }
define_leafcell -type diode { nwdiode ndiode }

### TOOL OPTIONS ######################################

# reuse ldbs
# set_var mx_ldb_reuse 1
# exit on read_spice error
set_var mx_read_spice_exit_on_missing_file 1
# report user-specified arcs that will not be in the final library
set_var mx_check_arcs 1
# exit if 1+ user-specified arcs will not generate a partition
# set_var mx_check_arcs_exit_on_missing 1
# enable input/output checking for NOCHAR and NOLIB warning/errors
# set_var mx_check_nochar_nolib 1

# find and automatically set virtual rails for clock tree detection
set_var mx_find_virtual_rails 2
# use new virtual rail modeling method. must also turn off mx_reuse
# set_var mx_virtual_rail_modeling_mode 1
# set_var mx_fastsim_reuse 0
# allow for clk2clk constraint characterization
set_var mx_clock2clock_constraints 1
# generate clock tree report
set_var mx_clock_tree_rpt 1

### AUTO FLOW ##########################################

source scripts/mx_$corner.tcl

