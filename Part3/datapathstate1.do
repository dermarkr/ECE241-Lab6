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


force {dividend_in} 9'b000000101
force {divisor_in} 5'b00010

force {lShift} 0
force {sub} 0
force {copy} 0
force {add} 0
force {ld_r} 1

run 11 ns


force {lShift} 0
force {sub} 0
force {copy} 0
force {add} 0
force {ld_r} 0

run 10 ns

force {lShift} 1
force {sub} 0
force {copy} 0
force {add} 0
force {ld_r} 0

run 10 ns

force {lShift} 0
force {sub} 1
force {copy} 0
force {add} 0
force {ld_r} 0

run 10 ns

force {lShift} 0
force {sub} 0
force {copy} 1
force {add} 0
force {ld_r} 0

run 10 ns

force {lShift} 0
force {sub} 0
force {copy} 0
force {add} 1
force {ld_r} 0

run 10 ns

force {lShift} 0
force {sub} 0
force {copy} 1
force {add} 0
force {ld_r} 0

run 10 ns