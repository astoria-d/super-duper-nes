create_clock -name pi_base_clk -period 20 [get_ports {pi_base_clk}]

create_clock -name pi_phi2 -period 559 [get_ports {pi_phi2}]
##create_clock -name clkin2 -period 10 -waveform {2 7} [get_ports {clkin2}]



