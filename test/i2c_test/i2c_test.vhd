library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.conv_integer;
use ieee.std_logic_arith.conv_std_logic_vector;
use ieee.std_logic_unsigned.all;

--entity rom_test01 is 
entity i2c_test is 
    port (
        pi_base_clk    : in std_logic;
        pi_reset_n	  : in std_logic;
        pi_key		  	  : in std_logic_vector(3 downto 0);
        po_led		  	  : out std_logic_vector(9 downto 0);

--        pi_sw          : in std_logic_vector(9 downto 0);
--        pi_btn_n       : in std_logic_vector(3 downto 0);
--        po_led_r       : out std_logic_vector(9 downto 0);
--        po_led_g       : out std_logic_vector(7 downto 0);
        pi_phi2             : in std_logic;
        pi_prg_ce_n         : in std_logic;
        pi_prg_r_nw         : in std_logic;
        pi_prg_addr         : in std_logic_vector(14 downto 0);
        po_prg_data         : out std_logic_vector(7 downto 0);
        pi_chr_ce_n         : in std_logic;
        pi_chr_oe_n         : in std_logic;
        pi_chr_we_n         : in std_logic;
        pi_chr_addr         : in std_logic_vector(12 downto 0);
        po_chr_data         : out std_logic_vector(7 downto 0);
        po_dbg_cnt          : out std_logic_vector (63 downto 0)
         );
--end rom_test01;
end i2c_test;

--architecture rtl of rom_test01 is
architecture rtl of i2c_test is

signal reg_dbg_cnt      : std_logic_vector (63 downto 0);

begin

	 po_led <= reg_dbg_cnt(12 downto 3);
    po_dbg_cnt <= reg_dbg_cnt;
    deb_cnt_p : process (pi_base_clk, pi_reset_n)
use ieee.std_logic_unsigned.all;
    variable cnt : integer;
    begin
        if (pi_reset_n = '0') then
            reg_dbg_cnt <= (others => '0');
            cnt := 0;
        elsif (rising_edge(pi_base_clk)) then
            if (cnt = 0) then
                --debug count is half cycle because too fast to capture in st ii.
                reg_dbg_cnt <= reg_dbg_cnt + 1;
                cnt := 1;
            else
                cnt := 0;
            end if;
        end if;
    end process;
end rtl;
