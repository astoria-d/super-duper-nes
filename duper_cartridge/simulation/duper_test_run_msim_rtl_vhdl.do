transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vcom -93 -work work {../synchronizer.vhd}
vcom -93 -work work {../fifo.vhd}
vcom -93 -work work {../prg_rom.vhd}
vcom -93 -work work {../i2c.vhd}
vcom -93 -work work {../duper_cartridge.vhd}
vcom -93 -work work {./testbench_duper_cartridge.vhd}

vsim -t 1ps -L altera -L lpm -L sgate -L altera_mf -L altera_lnsim -L cyclonev -L rtl_work -L work -voptargs="ê "  testbench_i2c_test

add wave -label stage_cnt   -radix unsigned        sim:/testbench_i2c_test/stage_cnt
add wave -label step_cnt    -radix unsigned        sim:/testbench_i2c_test/step_cnt

add wave -divider nes_cpu
add wave -label phi2                    sim:/testbench_i2c_test/sim_board/pi_phi2
add wave -label prg_ce_n                sim:/testbench_i2c_test/sim_board/pi_prg_ce_n
add wave -label prg_r_nw                sim:/testbench_i2c_test/sim_board/pi_prg_r_nw
add wave -label prg_addr    -radix hex  sim:/testbench_i2c_test/sim_board/pi_prg_addr
add wave -label prg_data    -radix hex  sim:/testbench_i2c_test/sim_board/pio_prg_data
#add wave -label reg_rom_data    -radix hex  sim:/testbench_i2c_test/reg_rom_data

add wave -divider duper_regs
add wave -label cur_state               sim:/testbench_i2c_test/sim_board/reg_cur_state


#add wave -divider prgrom
#add wave -label pi_ce_n     sim:/testbench_i2c_test/sim_board/prom_inst/pi_ce_n
#add wave -label pi_oe_n     sim:/testbench_i2c_test/sim_board/prom_inst/pi_oe_n
#add wave -label pi_addr     -radix hex  sim:/testbench_i2c_test/sim_board/prom_inst/pi_addr
#add wave -label po_data     -radix hex  sim:/testbench_i2c_test/sim_board/prom_inst/po_data

add wave -divider rd_fifo
add wave -label pi_ce_n     sim:/testbench_i2c_test/sim_board/rd_fifo_inst/pi_ce_n
add wave -label pi_oe_n     sim:/testbench_i2c_test/sim_board/rd_fifo_inst/pi_oe_n
add wave -label pi_we_n     sim:/testbench_i2c_test/sim_board/rd_fifo_inst/pi_we_n
add wave -label pi_data     -radix hex  sim:/testbench_i2c_test/sim_board/rd_fifo_inst/pi_data
add wave -label po_data     -radix hex  sim:/testbench_i2c_test/sim_board/rd_fifo_inst/po_data
add wave -label po_stat_empty   sim:/testbench_i2c_test/sim_board/rd_fifo_inst/po_stat_empty
add wave -label po_stat_full    sim:/testbench_i2c_test/sim_board/rd_fifo_inst/po_stat_full
add wave -label reg_fifo_size    -radix unsigned        sim:/testbench_i2c_test/sim_board/rd_fifo_inst/reg_fifo_size


add wave -divider i2c

add wave -label start_scl       sim:/testbench_i2c_test/start_scl
#add wave -label i2c_scl         sim:/testbench_i2c_test/i2c_scl
add wave -label i2c_step_cnt    sim:/testbench_i2c_test/i2c_step_cnt


add wave -label pi_i2c_scl      sim:/testbench_i2c_test/sim_board/pi_i2c_scl
add wave -label pio_i2c_sda     sim:/testbench_i2c_test/sim_board/pio_i2c_sda


add wave -divider i2c_slave
#add wave -label reg_next_sp            sim:/testbench_i2c_test/sim_board/i2c_slave_inst/reg_next_sp
add wave -label reg_cur_sp              sim:/testbench_i2c_test/sim_board/i2c_slave_inst/reg_cur_sp
add wave -label reg_cur_state           sim:/testbench_i2c_test/sim_board/i2c_slave_inst/reg_cur_state


add wave -label reg_i2c_cmd_addr        -radix hex  sim:/testbench_i2c_test/sim_board/i2c_slave_inst/reg_i2c_cmd_addr
add wave -label reg_i2c_cmd_r_nw                    sim:/testbench_i2c_test/sim_board/i2c_slave_inst/reg_i2c_cmd_r_nw
add wave -label reg_i2c_cmd_in_data     -radix hex  sim:/testbench_i2c_test/sim_board/i2c_slave_inst/reg_i2c_cmd_in_data
add wave -label po_slave_in_data        -radix hex  sim:/testbench_i2c_test/sim_board/i2c_slave_inst/po_slave_in_data
add wave -label po_i2c_status                       sim:/testbench_i2c_test/sim_board/i2c_slave_inst/po_i2c_status

#add wave -label rd_data                 -radix hex  sim:/testbench_i2c_test/rd_data


view structure
view signals

#run -all

run 15 us
wave zoom full
run 250 us
wave zoom full

