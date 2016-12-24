library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.conv_integer;
use ieee.std_logic_arith.conv_std_logic_vector;
use ieee.std_logic_unsigned.all;

--  
--   MOTO NES FPGA On DE0-CV Environment Virtual Cuicuit Board
--   All of the components are assembled and instanciated on this board.
--  

entity voltage_test01 is 
    port (
        pi_base_clk    : in std_logic;
        pi_sw          : in std_logic_vector(9 downto 0);
        pi_btn_n       : in std_logic_vector(3 downto 0);
        po_led_r       : out std_logic_vector(9 downto 0);
        po_led_g       : out std_logic_vector(7 downto 0);
        po_gpio0       : out std_logic_vector(3 downto 0);
        po_gpio1       : out std_logic_vector(9 downto 0)
         );
end voltage_test01;

architecture rtl of voltage_test01 is

--slow down button update timing.
constant FREQ_DEVIDE    : integer := 1000000;
signal reg_btn_flg      : integer range 0 to FREQ_DEVIDE;

signal reg_key3_cnt     : std_logic_vector(7 downto 0);
signal wr_rst_n         : std_logic;

begin

    wr_rst_n <= pi_btn_n(0);
    po_led_g <= reg_key3_cnt;
    po_led_r <= pi_sw;
    po_gpio0 <= pi_btn_n;
    po_gpio1 <= pi_sw;

    --key3 button proc.
    key3_cnt_p : process (wr_rst_n, pi_base_clk)
    begin
        if (wr_rst_n = '0') then
            reg_key3_cnt <= (others => '0');
        elsif (rising_edge(pi_base_clk)) then
            if (pi_btn_n(3) = '0' and reg_btn_flg = 0) then
                reg_key3_cnt <= reg_key3_cnt + 1;
            end if;
        end if;
    end process;

    --
    led_flg_p : process (wr_rst_n, pi_base_clk)
    begin
        if (wr_rst_n = '0') then
            reg_btn_flg <= 0;
        elsif (rising_edge(pi_base_clk)) then
            reg_btn_flg <= reg_btn_flg + 1;
        end if;
    end process;

end rtl;
