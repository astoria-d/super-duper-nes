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
        pi_sw          : in std_logic_vector(9 downto 0);
        pi_btn_n       : in std_logic_vector(3 downto 0);
        po_led_r       : out std_logic_vector(9 downto 0);
        po_led_g       : out std_logic_vector(7 downto 0);
        pi_prg_ce_n         : in std_logic;
        pi_prg_r_nw         : in std_logic;
        pi_prg_addr         : in std_logic_vector(14 downto 0);
        po_prg_data         : out std_logic_vector(7 downto 0)
         );
end rom_test01;

architecture rtl of rom_test01 is

component prg_rom_8k port (
    pi_base_clk 	: in std_logic;
    pi_ce_n         : in std_logic;
    pi_oe_n         : in std_logic;
    pi_addr         : in std_logic_vector (13 downto 0);
    po_data         : out std_logic_vector (7 downto 0)
    );
end component;

signal reg_prg_addr     : std_logic_vector(14 downto 0);
signal wr_prg_data      : std_logic_vector(7 downto 0);
signal wr_rst_n         : std_logic;

begin

    wr_rst_n <= pi_btn_n(0);
    po_prg_data <= wr_prg_data;

    gpio_p : process (wr_rst_n, pi_base_clk)
    begin
        if (wr_rst_n = '0') then
            po_led_r <= (others => '0');
            po_led_g <= (others => '0');
            reg_prg_addr <= (others => '0');
        elsif (rising_edge(pi_base_clk)) then
            reg_prg_addr <= pi_prg_addr;
            po_led_r(7 downto 0) <= reg_prg_addr(7 downto 0);
            po_led_g <= wr_prg_data;
        end if;
    end process;

    --program rom
    prom_inst : prg_rom_8k port map (
        pi_base_clk, 
        pi_prg_ce_n,
        pi_prg_ce_n,
        pi_prg_addr(13 downto 0), 
        wr_prg_data
    );

end rtl;
