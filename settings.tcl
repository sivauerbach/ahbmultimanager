set last_compiled_file last_compiled.txt

set library_file_list [list \
    design_library [glob -nocomplain ./src/*.sv] \
    test_library   [glob -nocomplain ./tb/*.sv]
]

set top_module test_library.randtest
