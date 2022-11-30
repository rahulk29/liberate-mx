define_memory \
    -temp 25 \
    -rail {vdd 1.8 vss 0} \
    -template scripts/template_$cell.tcl \
    -bitcell $bitcell \
    -number_of_ports 1 \
    -netlist src/$cell.spice \
    -netlist_format spice \
    -models [pwd]/src/include_tt \
    -models_leakage [pwd]/src/include_tt_leak \
    -model_format spectre \
    -clock clk \
    -address addr \
    -data_in din \
    -data_out dout \
    -write_enable {we H} \
    -bit_mask {wmask L} \
    -words $words \
    -bits $bits \
    -column_mux 4 \
    -debug 1 \
    $cell

char_memory

###WRITE MODELS##########################################

write_ldb -overwrite ${cell}_tt_025C_1v80.ldb
write_library -sync_ldb -sdf_edges -si -overwrite -filename ${cell}_tt_025C_1v80.lib $cell
read_library ${cell}_tt_025C_1v80.lib
write_verilog -use_liberate_function $cell.v

