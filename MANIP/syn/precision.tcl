new_project -name "demo" -folder "demo_folder" -force

set src_files [glob ../../src/*.sv]
set top_dir  $env(TOP_DIR)
set rom_file $top_dir/src/$env(ROM_FILE)

foreach my_file $src_files {
add_input_file $my_file
}

setup_design -search_path=\"../../src/\"
setup_design -frequency=100
setup_design -manufacturer Altera -family {Cyclone II} -part EP2C35F672C -speed 6
#setup_design -retiming=true
setup_design -addio=false 
setup_design -design adder
setup_design -define "+define+ROM_FILE=\"[list $rom_file]\""
#setup_design -overrides {{d_width 16} {a_width 8} {pipe_depth 4} {shift_depth 4} {num_out 4}}
compile
save_project

