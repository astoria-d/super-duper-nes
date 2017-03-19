library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.conv_integer;
use ieee.std_logic_arith.conv_std_logic_vector;
use ieee.std_logic_unsigned.all;

--  
--   MOTO NES FPGA On DE0-CV Environment Virtual Cuicuit Board
--   All of the components are assembled and instanciated on this board.
--  

entity rom_test01 is 
    port (
        pi_base_clk    : in std_logic;
--        pi_sw          : in std_logic_vector(9 downto 0);
--        pi_btn_n       : in std_logic_vector(3 downto 0);
--        po_led_r       : out std_logic_vector(9 downto 0);
--        po_led_g       : out std_logic_vector(7 downto 0);
        pi_prg_ce_n         : in std_logic;
        pi_prg_r_nw         : in std_logic;
        pi_prg_addr         : in std_logic_vector(14 downto 0);
        po_prg_data         : out std_logic_vector(7 downto 0);
        pi_chr_ce_n         : in std_logic;
        pi_chr_oe_n         : in std_logic;
        pi_chr_we_n         : in std_logic;
        pi_chr_addr         : in std_logic_vector(12 downto 0);
        po_chr_data         : out std_logic_vector(7 downto 0)
         );
end rom_test01;

architecture rtl of rom_test01 is

component prg_rom_8k port (
    pi_base_clk 	: in std_logic;
    pi_ce_n         : in std_logic;
    pi_oe_n         : in std_logic;
    pi_addr         : in std_logic_vector (12 downto 0);
    po_data         : out std_logic_vector (7 downto 0)
    );
end component;

component chr_rom_4k port (
    pi_base_clk 	: in std_logic;
    pi_ce_n         : in std_logic;
    pi_oe_n         : in std_logic;
    pi_addr         : in std_logic_vector (11 downto 0);
    po_data         : out std_logic_vector (7 downto 0)
    );
end component;

signal wk_chr_ce_n  : std_logic;

begin

    --program rom
    prom_inst : prg_rom_8k port map (
        pi_base_clk, 
        pi_prg_ce_n,
        pi_prg_ce_n,
        pi_prg_addr(12 downto 0), 
        po_prg_data
    );

--    wk_chr_ce_n <= not pi_chr_addr(13);
    --character rom
    crom_inst : chr_rom_4k port map (
        pi_base_clk, 
        --wk_chr_ce_n,
        pi_chr_ce_n,
        pi_chr_oe_n,
        pi_chr_addr(11 downto 0), 
        po_chr_data
    );

end rtl;
