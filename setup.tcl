onbreak {resume}

# Variables 
source settings.tcl
source compile.tcl

# If this is the first time initializing this project
# Set this variable
if {![file exists $last_compiled_file]} {
    set last_compiled 0
} else {
    set fd [open $last_compiled_file r]
    gets $fd last_compiled
    close $fd
}

echo $library_file_list

# Initial compiling. If there are no changes since last project start
# this will do nothing but update the last_compiled variable
set fd [open $last_compiled_file w]
set last_compiled [recompile_project $library_file_list $last_compiled]
puts $fd $last_compiled
close $fd

vopt {*}[get_libraries $library_file_list] +acc $top_module -o testbenchopt
vsim -work work testbenchopt

add wave -r /*

run -all

# Functions for recompiling after project is loaded
proc r {} {
    global last_compiled_file library_file_list top_module

    # Get last_compiled time
    set fd [open $last_compiled_file r]
    gets $fd last_compiled
    close $fd

    # Recompile
    set last_compiled [recompile_project $library_file_list $last_compiled]

    # Write last_compiled time to file
    set fd [open $last_compiled_file w]
    puts $fd $last_compiled
    close $fd

    # Resimulate
    vopt {*}[get_libraries $library_file_list] +acc $top_module -o testbenchopt
    vsim testbenchopt

    run -all
}

proc q {} {
    quit -force
}
