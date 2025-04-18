onbreak {resume}

# create library
if [file exists work] {
    vdel -all
}
vlib work

# compile source files
vlog arbiter_tb.sv arbiter.sv fixedpriority.sv onehotdecoder.sv rotator.sv 

# start and run simulation
vsim -voptargs=+acc work.arbiter_tb

view list
view wave

-- display input and output signals as hexidecimal values
# Diplays All Signals recursively
add wave -binary /arbiter_tb/dut/*

add list -hex -r /arbiter_tb/*
add log -r /*

-- Set Wave Output Items 
TreeUpdate [SetDefaultTree]
WaveRestoreZoom {0 ps} {75 ns}
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2

-- Run the Simulation
run 150 ns
