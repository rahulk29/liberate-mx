set_var slew_lower_rise 0.1
set_var slew_lower_fall 0.1
set_var slew_upper_rise 0.9
set_var slew_upper_fall 0.9

set_var measure_slew_lower_rise 0.1
set_var measure_slew_lower_fall 0.1
set_var measure_slew_upper_rise 0.9
set_var measure_slew_upper_fall 0.9

set_var delay_inp_rise 0.5
set_var delay_inp_fall 0.5
set_var delay_out_rise 0.5
set_var delay_out_fall 0.5

set_var def_arc_msg_level 0
set_var process_match_pins_to_ports 1
set_var max_transition 4e-11
set_var min_transition 1.25e-12
set_var min_output_cap 1.7225e-15

set cells { \
  sramgen_sram_8x128m4w2_simple \
}

define_template -type delay \
         -index_1 {0.00125 0.005 0.04 } \
         -index_2 {0.0017225 0.00689 0.02756 } \
         delay_template_3x3

define_template -type constraint \
         -index_1 {0.00125 0.005 0.04 } \
         -index_2 {0.00125 0.005 0.04 } \
         constraint_template_3x3

define_template -type power \
         -index_1 {0.00125 0.005 0.04 } \
         -index_2 {0.0017225 0.00689 0.02756 } \
         power_template_3x3

if {[ALAPI_active_cell "sramgen_sram_8x128m4w2_simple"]} {
define_cell \
       -clock { clk } \
       -input { din[7:0] addr[6:0] we wmask[3:0] } \
       -output { dout[7:0] } \
       -delay delay_template_3x3 \
       -power power_template_3x3 \
       -constraint constraint_template_3x3 \
       sramgen_sram_8x128m4w2_simple

# print out matched nodes
mx_match_node bitline sramgen_sram_8x128m4w2_simple
mx_match_node wordline sramgen_sram_8x128m4w2_simple
mx_match_node core sramgen_sram_8x128m4w2_simple
mx_match_node bitline_precharger sramgen_sram_8x128m4w2_simple
mx_match_node senseamp_precharger sramgen_sram_8x128m4w2_simple
mx_match_node senseamp_enable sramgen_sram_8x128m4w2_simple

define_leakage sramgen_sram_8x128m4w2_simple

# constraint arcs from clk => din[7:0]  hold_rising
define_arc \
       -type hold \
       -related_pin_dir R -pin_dir R  \
       -related_pin {clk} \
       -pin {din[7:0]} \
       sramgen_sram_8x128m4w2_simple

define_arc \
       -type hold \
       -related_pin_dir R -pin_dir F  \
       -related_pin {clk} \
       -pin {din[7:0]} \
       sramgen_sram_8x128m4w2_simple

# constraint arcs from clk => din[7:0]  setup_rising
define_arc \
       -type setup \
       -related_pin_dir R -pin_dir R  \
       -related_pin {clk} \
       -pin {din[7:0]} \
       sramgen_sram_8x128m4w2_simple

define_arc \
       -type setup \
       -related_pin_dir R -pin_dir F  \
       -related_pin {clk} \
       -pin {din[7:0]} \
       sramgen_sram_8x128m4w2_simple

# constraint arcs from clk => addr[6:0]  hold_rising
define_arc \
       -type hold \
       -related_pin_dir R -pin_dir R  \
       -related_pin {clk} \
       -pin {addr[6:0]} \
       sramgen_sram_8x128m4w2_simple

define_arc \
       -type hold \
       -related_pin_dir R -pin_dir F  \
       -related_pin {clk} \
       -pin {addr[6:0]} \
       sramgen_sram_8x128m4w2_simple

# constraint arcs from clk => addr[6:0]  setup_rising
define_arc \
       -type setup \
       -related_pin_dir R -pin_dir R  \
       -related_pin {clk} \
       -pin {addr[6:0]} \
       sramgen_sram_8x128m4w2_simple

define_arc \
       -type setup \
       -related_pin_dir R -pin_dir F  \
       -related_pin {clk} \
       -pin {addr[6:0]} \
       sramgen_sram_8x128m4w2_simple

# constraint arcs from clk => we  hold_rising
define_arc \
       -type hold \
       -related_pin_dir R -pin_dir R  \
       -related_pin {clk} \
       -pin {we} \
       sramgen_sram_8x128m4w2_simple

define_arc \
       -type hold \
       -related_pin_dir R -pin_dir F  \
       -related_pin {clk} \
       -pin {we} \
       sramgen_sram_8x128m4w2_simple

# constraint arcs from clk => we  setup_rising
define_arc \
       -type setup \
       -related_pin_dir R -pin_dir R  \
       -related_pin {clk} \
       -pin {we} \
       sramgen_sram_8x128m4w2_simple

define_arc \
       -type setup \
       -related_pin_dir R -pin_dir F  \
       -related_pin {clk} \
       -pin {we} \
       sramgen_sram_8x128m4w2_simple

# constraint arcs from clk => wmask[3:0]  hold_rising
define_arc \
       -type hold \
       -related_pin_dir R -pin_dir R  \
       -related_pin {clk} \
       -pin {wmask[3:0]} \
       sramgen_sram_8x128m4w2_simple

define_arc \
       -type hold \
       -related_pin_dir R -pin_dir F  \
       -related_pin {clk} \
       -pin {wmask[3:0]} \
       sramgen_sram_8x128m4w2_simple

# constraint arcs from clk => wmask[3:0]  setup_rising
define_arc \
       -type setup \
       -related_pin_dir R -pin_dir R  \
       -related_pin {clk} \
       -pin {wmask[3:0]} \
       sramgen_sram_8x128m4w2_simple

define_arc \
       -type setup \
       -related_pin_dir R -pin_dir F  \
       -related_pin {clk} \
       -pin {wmask[3:0]} \
       sramgen_sram_8x128m4w2_simple

# power arcs from  => clk  power
define_arc \
       -type power \
       -when "!we" \
       -pin_dir R  \
       -pin {clk} \
       sramgen_sram_8x128m4w2_simple

define_arc \
       -type power \
       -when "!we" \
       -pin_dir F  \
       -pin {clk} \
       sramgen_sram_8x128m4w2_simple

define_arc \
       -type power \
       -when "we" \
       -pin_dir R  \
       -pin {clk} \
       sramgen_sram_8x128m4w2_simple

define_arc \
       -type power \
       -when "we" \
       -pin_dir F  \
       -pin {clk} \
       sramgen_sram_8x128m4w2_simple

# constraint arcs from clk => clk  mpw
define_arc \
       -type mpw \
       -related_pin_dir F -pin_dir R  \
       -related_pin {clk} \
       -pin {clk} \
       sramgen_sram_8x128m4w2_simple

define_arc \
       -type mpw \
       -related_pin_dir R -pin_dir F  \
       -related_pin {clk} \
       -pin {clk} \
       sramgen_sram_8x128m4w2_simple

# constraint arcs from clk => clk  min_period
define_arc \
       -type min_period \
       -related_pin_dir R -pin_dir R  \
       -related_pin {clk} \
       -pin {clk} \
       sramgen_sram_8x128m4w2_simple

define_arc \
       -type min_period \
       -related_pin_dir F -pin_dir F  \
       -related_pin {clk} \
       -pin {clk} \
       sramgen_sram_8x128m4w2_simple

# delay arcs from clk => dout[7:0] non_unate combinational
define_arc \
       -related_pin_dir R -pin_dir R  \
       -related_pin {clk} \
       -pin {dout[7:0]} \
       sramgen_sram_8x128m4w2_simple

# delay arcs from clk => dout[7:0] non_unate combinational
define_arc \
       -related_pin_dir F -pin_dir F  \
       -related_pin {clk} \
       -pin {dout[7:0]} \
       sramgen_sram_8x128m4w2_simple

}

