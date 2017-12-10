create_clock -name pi_base_clk -period 20 [get_ports {pi_base_clk}]

#create_clock -name pi_phi2 -period 559 [get_ports {pi_phi2}]
##create_clock -name clkin2 -period 10 -waveform {2 7} [get_ports {clkin2}]

#signal trap II ref clock.
#64 times slowed down from base clock.
#create_clock -name st2_clk -period 1280 [get_ports {reg_dbg_cnt[5]}]
