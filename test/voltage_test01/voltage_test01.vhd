library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.conv_integer;

--  
--   MOTO NES FPGA On DE0-CV Environment Virtual Cuicuit Board
--   All of the components are assembled and instanciated on this board.
--  

entity voltage_test01 is 
    port (
--logic analyzer reference clock
    signal dbg_base_clk: out std_logic;
    
--NES instance
        pi_base_clk 	: in std_logic;
        pi_sw          : out std_logic_vector(9 downto 0);
        pi_btn         : out std_logic_vector(3 downto 0);
        po_led_r       : out std_logic_vector(9 downto 0);
        po_led_g       : out std_logic_vector(7 downto 0)
         );
end voltage_test01;

architecture rtl of voltage_test01 is

begin

end rtl;
