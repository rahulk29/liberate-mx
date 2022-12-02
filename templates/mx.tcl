### USER SETTINGS ####################################

# Set cell name and bitcell type (single-port, dual-port, rom)
set cell {{ cell_name }}
set words {{ num_words }}
set bits {{ data_width }}
set bitcell single_port

# Choose corner to run
# Choices: {ss, tt, ff}
set corner {{ corner }}

### DESIGN OPTIONS ####################################

# Hack existing netlist
# exec ./scripts/replace_primitives.sh src/$cell.spice

# Identify primitives (leafcells)
define_leafcell -element -type nmos { npass npd nshort nlowvt }
define_leafcell -element -type pmos { pshort ppu phighvt }
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

define_memory \
    -temp 25 \
    -rail {vdd 1.8 vss 0} \
    -template {{ template_path }} \
    -bitcell $bitcell \
    -number_of_ports 1 \
    -netlist {{ netlist_path }} \
    -netlist_format spice \
    -models {{ models_path }} \
    -models_leakage {{ models_leakage_path }} \
    -model_format spectre \
    -clock clk \
    -address addr \
    -data_in din \
    -data_out dout \
    -write_enable {we H} \
    {% if has_wmask -%}
    -bit_mask {wmask L} \
    {%- endif -%}
    -words $words \
    -bits $bits \
    -column_mux {{ mux_ratio }} \
    -debug 1 \
    $cell

char_memory

###WRITE MODELS##########################################

write_ldb -overwrite {{ ldb_path }}
write_library -sync_ldb -sdf_edges -si -overwrite -filename {{ lib_path }} $cell
read_library {{ lib_path }}
write_verilog -use_liberate_function {{ verilog_path }}

