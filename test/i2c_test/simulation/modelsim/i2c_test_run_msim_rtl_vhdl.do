transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vcom -93 -work work {D:/daisuke/nes/repo/super-duper-nes/test/i2c_test/i2c.vhd}
vcom -93 -work work {D:/daisuke/nes/repo/super-duper-nes/test/i2c_test/i2c_test.vhd}

vcom -93 -work work {D:/daisuke/nes/repo/super-duper-nes/test/i2c_test/simulation/modelsim/testbench_i2c_test.vhd}

vsim -t 1ps -L altera -L lpm -L sgate -L altera_mf -L altera_lnsim -L cyclonev -L rtl_work -L work -voptargs="ê "  testbench_i2c_test

#add wave *
add wave -label pi_reset_n      sim:/testbench_i2c_test/sim_board/pi_reset_n
#add wave -label pi_base_clk    sim:/testbench_i2c_test/sim_board/pi_base_clk

add wave -label pi_i2c_scl      sim:/testbench_i2c_test/sim_board/pi_i2c_scl

add wave -label pio_i2c_sda     sim:/testbench_i2c_test/sim_board/pio_i2c_sda
#add wave -label reg_old_sda     sim:/testbench_i2c_test/sim_board/i2c_slave_inst/reg_old_sda


add wave -divider i2c_slave
#add wave -label reg_next_sp            sim:/testbench_i2c_test/sim_board/i2c_slave_inst/reg_next_sp
add wave -label reg_cur_sp              sim:/testbench_i2c_test/sim_board/i2c_slave_inst/reg_cur_sp
add wave -label reg_cur_state           sim:/testbench_i2c_test/sim_board/i2c_slave_inst/reg_cur_state


add wave -label reg_i2c_cmd_addr        -radix hex  sim:/testbench_i2c_test/sim_board/i2c_slave_inst/reg_i2c_cmd_addr
add wave -label reg_i2c_cmd_r_nw                    sim:/testbench_i2c_test/sim_board/i2c_slave_inst/reg_i2c_cmd_r_nw
add wave -label reg_i2c_cmd_in_data     -radix hex  sim:/testbench_i2c_test/sim_board/i2c_slave_inst/reg_i2c_cmd_in_data
add wave -label reg_ack_in_data         -radix hex  sim:/testbench_i2c_test/sim_board/i2c_slave_inst/reg_ack_in_data

add wave -label rd_data                 -radix hex  sim:/testbench_i2c_test/rd_data

view structure
view signals

#run -all

run 350 us
wave zoom full
run 550 us

