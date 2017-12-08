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
vcom -93 -work work {./nes2bbb_testbench.vhd}

vsim -t 1ps -L altera -L lpm -L sgate -L altera_mf -L altera_lnsim -L cyclonev -L rtl_work -L work -voptargs="ê "  nes2bbb_testbench

add wave -label stage_cnt   -radix unsigned        sim:/nes2bbb_testbench/stage_cnt
add wave -label step_cnt    -radix unsigned        sim:/nes2bbb_testbench/step_cnt

add wave -divider nes_cpu
add wave -label pi_reset_n              sim:/nes2bbb_testbench/sim_board/pi_reset_n
add wave -label phi2                    sim:/nes2bbb_testbench/sim_board/pi_phi2
add wave -label prg_ce_n                sim:/nes2bbb_testbench/sim_board/pi_prg_ce_n
add wave -label prg_r_nw                sim:/nes2bbb_testbench/sim_board/pi_prg_r_nw
add wave -label prg_addr    -radix hex  sim:/nes2bbb_testbench/sim_board/pi_prg_addr
add wave -label prg_data    -radix hex  sim:/nes2bbb_testbench/sim_board/pio_prg_data
#add wave -label reg_rom_data    -radix hex  sim:/nes2bbb_testbench/reg_rom_data

add wave -divider duper_regs
add wave -label cur_state               sim:/nes2bbb_testbench/sim_board/reg_cur_state


#add wave -divider prgrom
#add wave -label pi_ce_n     sim:/nes2bbb_testbench/sim_board/prom_inst/pi_ce_n
#add wave -label pi_oe_n     sim:/nes2bbb_testbench/sim_board/prom_inst/pi_oe_n
#add wave -label pi_addr     -radix hex  sim:/nes2bbb_testbench/sim_board/prom_inst/pi_addr
#add wave -label po_data     -radix hex  sim:/nes2bbb_testbench/sim_board/prom_inst/po_data


add wave -divider wr_fifo
add wave -label pi_ce_n     sim:/nes2bbb_testbench/sim_board/wr_fifo_inst/pi_ce_n
add wave -label pi_oe_n     sim:/nes2bbb_testbench/sim_board/wr_fifo_inst/pi_oe_n
add wave -label pi_push_n   sim:/nes2bbb_testbench/sim_board/wr_fifo_inst/pi_push_n
add wave -label pi_pop_n    sim:/nes2bbb_testbench/sim_board/wr_fifo_inst/pi_pop_n
add wave -label pi_data     -radix hex  sim:/nes2bbb_testbench/sim_board/wr_fifo_inst/pi_data
add wave -label po_data     -radix hex  sim:/nes2bbb_testbench/sim_board/wr_fifo_inst/po_data
add wave -label po_stat_empty   sim:/nes2bbb_testbench/sim_board/wr_fifo_inst/po_stat_empty
add wave -label po_stat_full    sim:/nes2bbb_testbench/sim_board/wr_fifo_inst/po_stat_full
add wave -label reg_fifo_size    -radix unsigned        sim:/nes2bbb_testbench/sim_board/wr_fifo_inst/reg_fifo_size


add wave -divider bbb
add wave -label reg_bbb_data        -radix hex  sim:/nes2bbb_testbench/reg_bbb_data
add wave -label reg_i2c_rd_done                 sim:/nes2bbb_testbench/sim_board/reg_i2c_rd_done
add wave -label wr_ofifo_data       -radix hex  sim:/nes2bbb_testbench/sim_board/wr_ofifo_data


add wave -divider i2c
add wave -label start_scl       sim:/nes2bbb_testbench/start_scl
add wave -label i2c_step_cnt    sim:/nes2bbb_testbench/i2c_step_cnt
#add wave -label i2c_scl_type    sim:/nes2bbb_testbench/i2c_scl_type
add wave -label pi_i2c_scl      sim:/nes2bbb_testbench/sim_board/pi_i2c_scl
add wave -label pio_i2c_sda     sim:/nes2bbb_testbench/sim_board/pio_i2c_sda


add wave -divider i2c_slave
#add wave -label reg_next_sp            sim:/nes2bbb_testbench/sim_board/i2c_slave_inst/reg_next_sp
add wave -label reg_cur_sp              sim:/nes2bbb_testbench/sim_board/i2c_slave_inst/reg_cur_sp
add wave -label reg_cur_state           sim:/nes2bbb_testbench/sim_board/i2c_slave_inst/reg_cur_state


add wave -label reg_i2c_cmd_addr        -radix hex  sim:/nes2bbb_testbench/sim_board/i2c_slave_inst/reg_i2c_cmd_addr
add wave -label reg_i2c_cmd_r_nw                    sim:/nes2bbb_testbench/sim_board/i2c_slave_inst/reg_i2c_cmd_r_nw
add wave -label reg_i2c_cmd_in_data     -radix hex  sim:/nes2bbb_testbench/sim_board/i2c_slave_inst/reg_i2c_cmd_in_data
add wave -label po_slave_in_data        -radix hex  sim:/nes2bbb_testbench/sim_board/i2c_slave_inst/po_slave_in_data
add wave -label pi_slave_out_data       -radix hex  sim:/nes2bbb_testbench/sim_board/i2c_slave_inst/pi_slave_out_data
add wave -label po_i2c_status                       sim:/nes2bbb_testbench/sim_board/i2c_slave_inst/po_i2c_status

#add wave -label rd_data                 -radix hex  sim:/nes2bbb_testbench/rd_data


view structure
view signals

#run -all

#step 1 rom write...
run 30 us
wave zoom full

#step 1 more rom write until fifo full...
#run 500 us
#wave zoom full

run 200 us
wave zoom full
