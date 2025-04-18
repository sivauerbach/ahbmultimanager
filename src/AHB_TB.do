onbreak {resume}

# create library
if [file exists work] {
    vdel -all
}
vlib work

# compile source files
# vlog ahb.sv AHB_TB.sv AHB_DUT.sv AHB_manager.sv AHB_subordinate.sv ahbmmgr.sv arbiter.sv fixedpriority.sv onehotdecoder.sv rotator.sv 
vlog *.sv

# start and run simulation
vsim -voptargs=+acc work.AHB_TB

# Enumerating Transmition states
radix define TRANS_states {
    2'b00 "IDLE",
    2'b01 "BUSY",
    2'b10 "NONSEQ",
    2'b11 "SEQ",
    -default binary
}

# Enumerating Transmition states
radix define HSIZE_states {
    3'b000 "BYTE",
    3'b001 "HALF",
    3'b010 "WORD",
    3'b011 "DW",
    3'b100 "4WORD",
    3'b101 "8WORD",
    -default binary
}

radix define HBURST_states {
    3'b000 "SINGLE",
    3'b001 "INCR",
    3'b010 "WRAP4",
    3'b011 "INCR4",
    3'b100 "WRAP8",
    3'b101 "INCR8",
    3'b110 "WRAP16",
    3'b111 "INCR16",
    -default binary
}

radix define HWRITE_states {
1'b0 "READ",
1'b1 "WRITE",
    -default binary
}

view wave

onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /AHB_TB/clk
add wave -noupdate /AHB_TB/rstn

add wave -noupdate -group Random TB /AHB_TB/start_0
add wave -noupdate -group Random TB -radix unsigned /AHB_TB/addr_rand_0
add wave -noupdate -group Random TB /AHB_TB/hready
add wave -noupdate -group Random TB /AHB_TB/data_out_m0
add wave -noupdate -group Master_0_outputs /AHB_TB/d0/hsel
add wave -noupdate -group Master_0_outputs -radix binary /AHB_TB/d0/mo/start_samp
add wave -noupdate -group Master_0_outputs -radix TRANS_states /AHB_TB/d0/mo/state
add wave -noupdate -group Master_0_outputs -radix TRANS_states /AHB_TB/d0/mo/next_state

add wave -noupdate -group Master_0_outputs -radix HBURST_states /AHB_TB/d0/mo/o_hburst
add wave -noupdate -group Master_0_outputs -radix unsigned -childformat {{{/AHB_TB/d0/mo/o_haddr[31]} -radix unsigned} {{/AHB_TB/d0/mo/o_haddr[30]} -radix unsigned} {{/AHB_TB/d0/mo/o_haddr[29]} -radix unsigned} {{/AHB_TB/d0/mo/o_haddr[28]} -radix unsigned} {{/AHB_TB/d0/mo/o_haddr[27]} -radix unsigned} {{/AHB_TB/d0/mo/o_haddr[26]} -radix unsigned} {{/AHB_TB/d0/mo/o_haddr[25]} -radix unsigned} {{/AHB_TB/d0/mo/o_haddr[24]} -radix unsigned} {{/AHB_TB/d0/mo/o_haddr[23]} -radix unsigned} {{/AHB_TB/d0/mo/o_haddr[22]} -radix unsigned} {{/AHB_TB/d0/mo/o_haddr[21]} -radix unsigned} {{/AHB_TB/d0/mo/o_haddr[20]} -radix unsigned} {{/AHB_TB/d0/mo/o_haddr[19]} -radix unsigned} {{/AHB_TB/d0/mo/o_haddr[18]} -radix unsigned} {{/AHB_TB/d0/mo/o_haddr[17]} -radix unsigned} {{/AHB_TB/d0/mo/o_haddr[16]} -radix unsigned} {{/AHB_TB/d0/mo/o_haddr[15]} -radix unsigned} {{/AHB_TB/d0/mo/o_haddr[14]} -radix unsigned} {{/AHB_TB/d0/mo/o_haddr[13]} -radix unsigned} {{/AHB_TB/d0/mo/o_haddr[12]} -radix unsigned} {{/AHB_TB/d0/mo/o_haddr[11]} -radix unsigned} {{/AHB_TB/d0/mo/o_haddr[10]} -radix unsigned} {{/AHB_TB/d0/mo/o_haddr[9]} -radix unsigned} {{/AHB_TB/d0/mo/o_haddr[8]} -radix unsigned} {{/AHB_TB/d0/mo/o_haddr[7]} -radix unsigned} {{/AHB_TB/d0/mo/o_haddr[6]} -radix unsigned} {{/AHB_TB/d0/mo/o_haddr[5]} -radix unsigned} {{/AHB_TB/d0/mo/o_haddr[4]} -radix unsigned} {{/AHB_TB/d0/mo/o_haddr[3]} -radix unsigned} {{/AHB_TB/d0/mo/o_haddr[2]} -radix unsigned} {{/AHB_TB/d0/mo/o_haddr[1]} -radix unsigned} {{/AHB_TB/d0/mo/o_haddr[0]} -radix unsigned}} -subitemconfig {{/AHB_TB/d0/mo/o_haddr[31]} {-height 15 -radix unsigned} {/AHB_TB/d0/mo/o_haddr[30]} {-height 15 -radix unsigned} {/AHB_TB/d0/mo/o_haddr[29]} {-height 15 -radix unsigned} {/AHB_TB/d0/mo/o_haddr[28]} {-height 15 -radix unsigned} {/AHB_TB/d0/mo/o_haddr[27]} {-height 15 -radix unsigned} {/AHB_TB/d0/mo/o_haddr[26]} {-height 15 -radix unsigned} {/AHB_TB/d0/mo/o_haddr[25]} {-height 15 -radix unsigned} {/AHB_TB/d0/mo/o_haddr[24]} {-height 15 -radix unsigned} {/AHB_TB/d0/mo/o_haddr[23]} {-height 15 -radix unsigned} {/AHB_TB/d0/mo/o_haddr[22]} {-height 15 -radix unsigned} {/AHB_TB/d0/mo/o_haddr[21]} {-height 15 -radix unsigned} {/AHB_TB/d0/mo/o_haddr[20]} {-height 15 -radix unsigned} {/AHB_TB/d0/mo/o_haddr[19]} {-height 15 -radix unsigned} {/AHB_TB/d0/mo/o_haddr[18]} {-height 15 -radix unsigned} {/AHB_TB/d0/mo/o_haddr[17]} {-height 15 -radix unsigned} {/AHB_TB/d0/mo/o_haddr[16]} {-height 15 -radix unsigned} {/AHB_TB/d0/mo/o_haddr[15]} {-height 15 -radix unsigned} {/AHB_TB/d0/mo/o_haddr[14]} {-height 15 -radix unsigned} {/AHB_TB/d0/mo/o_haddr[13]} {-height 15 -radix unsigned} {/AHB_TB/d0/mo/o_haddr[12]} {-height 15 -radix unsigned} {/AHB_TB/d0/mo/o_haddr[11]} {-height 15 -radix unsigned} {/AHB_TB/d0/mo/o_haddr[10]} {-height 15 -radix unsigned} {/AHB_TB/d0/mo/o_haddr[9]} {-height 15 -radix unsigned} {/AHB_TB/d0/mo/o_haddr[8]} {-height 15 -radix unsigned} {/AHB_TB/d0/mo/o_haddr[7]} {-height 15 -radix unsigned} {/AHB_TB/d0/mo/o_haddr[6]} {-height 15 -radix unsigned} {/AHB_TB/d0/mo/o_haddr[5]} {-height 15 -radix unsigned} {/AHB_TB/d0/mo/o_haddr[4]} {-height 15 -radix unsigned} {/AHB_TB/d0/mo/o_haddr[3]} {-height 15 -radix unsigned} {/AHB_TB/d0/mo/o_haddr[2]} {-height 15 -radix unsigned} {/AHB_TB/d0/mo/o_haddr[1]} {-height 15 -radix unsigned} {/AHB_TB/d0/mo/o_haddr[0]} {-height 15 -radix unsigned}} /AHB_TB/d0/mo/o_haddr
add wave -noupdate -group Master_0_outputs -radix hexadecimal /AHB_TB/d0/mo/o_hwdata
add wave -noupdate -group Master_0_outputs -radix HSIZE_states /AHB_TB/d0/mo/o_hsize
add wave -noupdate -group Master_0_outputs -radix TRANS_states /AHB_TB/d0/mo/o_htrans
add wave -noupdate -group Master_0_outputs -radix HWRITE_states /AHB_TB/d0/mo/o_hwrite
add wave -noupdate -group Master_0_outputs /AHB_TB/d0/mo/i_start

add wave -noupdate -group Manager_Cable /AHB_TB/d0/mast_mmgr/*
add wave -noupdate -group Subordinate_Cable /AHB_TB/d0/mmgr_sub/*
add wave -noupdate -group AHB_MMgr /AHB_TB/d0/my_mmgr/*
add wave -noupdate -group AHB_MMgr /AHB_TB/d0/my_mmgr/state
add wave -noupdate -group AHB_MMgr /AHB_TB/d0/my_mmgr/next_state

add wave -noupdate -group Arbiter /AHB_TB/d0/my_mmgr/arb/*


add wave -noupdate -group Subordinate_signals /AHB_TB/d0/so/*
add wave -noupdate /AHB_TB/mem

### Modifying Radices: 

radix signal sim:/AHB_TB/d0/mast_mmgr/HTRANS TRANS_states
radix signal sim:/AHB_TB/d0/mmgr_sub/HTRANS TRANS_states

radix signal sim:/AHB_TB/d0/mast_mmgr/HBURST HBURST_states
radix signal sim:/AHB_TB/d0/mmgr_sub/HBURST HBURST_states

radix signal sim:/AHB_TB/d0/mast_mmgr/HWRITE HWRITE_states
radix signal sim:/AHB_TB/d0/mmgr_sub/HWRITE HWRITE_states
radix signal sim:/AHB_TB/d0/mast_mmgr/HSIZE HSIZE_states
radix signal sim:/AHB_TB/d0/mmgr_sub/HSIZE HSIZE_states


TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {302565100 ps} 0} {{Cursor 2} {161830000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 213
configure wave -valuecolwidth 75
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
# WaveRestoreZoom {481262800 ps} {532565200 ps}

-- Run the Simulation
run 3000 ns
wave zoom full
