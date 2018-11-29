# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in mux.v to working dir
# could also have multiple verilog files
vlog main.v

#load simulation using mux as the top level simulation module
vsim datapath

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}

force {clk} 0 0ns, 1 {5ns} -r 10ns

force {resetn} 0
run 10ns

force {resetn} 1
run 10ns


force {alu_select_a} 2'b00
force {alu_select_b} 2'b00
force {ld_alu_out} 0


force {data_in[0]} 0
force {data_in[1]} 1
force {data_in[2]} 1
force {data_in[3]} 0
force {data_in[4]} 0
force {data_in[5]} 0
force {data_in[6]} 0
force {data_in[7]} 0


force {ld_a} 1
force {ld_b} 0
force {ld_c} 0
force {ld_x} 0
force {ld_r} 0

#force {a} 8'b00000011
#force {b} 8'b00001001
#force {c} 8'b00000101
#force {x} 8'b00010001

run 20 ns

force {data_in[0]} 0
force {data_in[1]} 0
force {data_in[2]} 1
force {data_in[3]} 0
force {data_in[4]} 0
force {data_in[5]} 0
force {data_in[6]} 0
force {data_in[7]} 0

force {ld_a} 0
force {ld_b} 1
force {ld_c} 0
force {ld_x} 0
force {ld_r} 0
 run 20 ns

force {data_in[0]} 0
force {data_in[1]} 1
force {data_in[2]} 1
force {data_in[3]} 1
force {data_in[4]} 0
force {data_in[5]} 0
force {data_in[6]} 0
force {data_in[7]} 0

force {ld_a} 0
force {ld_b} 0
force {ld_c} 1
force {ld_x} 0
force {ld_r} 0
 run 20 ns

force {data_in[0]} 0
force {data_in[1]} 0
force {data_in[2]} 0
force {data_in[3]} 1
force {data_in[4]} 0
force {data_in[5]} 0
force {data_in[6]} 0
force {data_in[7]} 0

force {ld_a} 0
force {ld_b} 0
force {ld_c} 0
force {ld_x} 1
force {ld_r} 0
run 20 ns

force {alu_select_a} 2'b01
force {alu_select_b} 2'b10

run 20 ns

force {alu_select_a} 2'b00
force {alu_select_b} 2'b11

run 20 ns

force {alu_op} 0

run 20 ns

force {alu_op} 1

run 20 ns