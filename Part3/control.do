# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in mux.v to working dir
# could also have multiple verilog files
vlog main.v

#load simulation using mux as the top level simulation module
vsim control

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}

force {clk} 0 0ns, 1 {5ns} -r 10ns

force {resetn} 0
run 10ns

force {resetn} 1
run 10ns

force {go} 1
run 11ns

force {go} 0
run 10ns

force {go} 1
run 11ns

force {go} 0
run 10ns

run 320ns