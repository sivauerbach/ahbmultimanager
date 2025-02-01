# Dynamically recompile only the files that have changed
proc recompile_project {library_file_list last_compiled} {
    foreach {library file_list} $library_file_list {
        vlib $library
        vmap work $library
        foreach f $file_list {
            if {$last_compiled < [file mtime $f]} {
                vlog -lint $f
            }
        }
    }
    return [clock seconds]
}

# Get vopt library arguments
proc get_libraries {library_file_list} {
    set libs {}
    foreach {library file_list} $library_file_list {
        lappend libs -Lf $library
    }
    return $libs
}
