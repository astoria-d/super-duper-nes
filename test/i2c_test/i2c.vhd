library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.conv_integer;
use ieee.std_logic_arith.conv_std_logic_vector;
use ieee.std_logic_unsigned.all;

entity i2c_slave is 
    port (
        pi_i2c_scl      : in std_logic;
        pio_i2c_sda     : inout std_logic
    );
end i2c_slave;

architecture rtl of i2c_slave is

begin
    pio_i2c_sda <= 'Z';
end rtl;
