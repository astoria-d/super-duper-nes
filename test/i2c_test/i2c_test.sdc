
#clock 50 MHz
create_clock -name pi_base_clk -period 20 [get_ports {pi_base_clk}]


#I2C clock 100 KHz
create_clock -name pi_i2c_scl -period 5000 [get_ports {pi_i2c_scl}]

#signal trap II ref clock.
#64 times slowed down from base clock.
create_clock -name st2_clk -period 1280 [get_ports {reg_dbg_cnt[5]}]

