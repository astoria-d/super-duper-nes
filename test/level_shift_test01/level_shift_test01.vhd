library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.conv_integer;
use ieee.std_logic_arith.conv_std_logic_vector;
use ieee.std_logic_unsigned.all;

--  
--   MOTO NES FPGA On DE0-CV Environment Virtual Cuicuit Board
--   All of the components are assembled and instanciated on this board.
--  

entity level_shift_test01 is 
    port (
        pi_base_clk    : in std_logic;
        pi_sw          : in std_logic_vector(9 downto 0);
        pi_btn_n       : in std_logic_vector(3 downto 0);
        po_led_r       : out std_logic_vector(9 downto 0);
        po_led_g       : out std_logic_vector(7 downto 0);
        pio_gpio0       : inout std_logic_vector(7 downto 0);
        pio_gpio1       : inout std_logic_vector(7 downto 0)
         );
end level_shift_test01;

architecture rtl of level_shift_test01 is

--slow down button update timing.
constant FREQ_DEVIDE    : integer := 1000000;
signal reg_cnt_devider      : integer range 0 to FREQ_DEVIDE;
signal reg_8bit_cnt     : std_logic_vector(7 downto 0);

signal wr_rst_n         : std_logic;
signal wr_direction     : std_logic;
signal wr_dvd           : std_logic;

begin

    wr_rst_n <= pi_btn_n(0);
    wr_direction <= pi_sw(9);
    wr_dvd <= pi_sw(8);


    gpio_p : process (wr_rst_n, pi_base_clk)
    begin
        if (wr_rst_n = '0') then
            pio_gpio0 <= (others => 'Z');
            pio_gpio1 <= (others => 'Z');
            po_led_r <= (others => '0');
            po_led_g <= (others => '0');
        elsif (rising_edge(pi_base_clk)) then
            if (wr_direction = '0') then
                --case off = cp gpio 1 to 0
                pio_gpio0 <= (others => 'Z');
                pio_gpio1 <= pi_sw(7 downto 0);
                po_led_r <= pi_sw;
                po_led_g <= pio_gpio0;
            else
                --on = cp gpio 0 to 1
                pio_gpio0 <= reg_8bit_cnt;
                pio_gpio1 <= (others => 'Z');
                po_led_r(7 downto 0) <= pio_gpio1;
                po_led_r(9 downto 8) <= pi_sw(9 downto 8);
                po_led_g <= reg_8bit_cnt;
            end if;
        end if;
    end process;

    --key3 button proc.
    key3_cnt_p : process (wr_rst_n, pi_base_clk)
    begin
        if (wr_rst_n = '0') then
            reg_8bit_cnt <= (others => '0');
        elsif (rising_edge(pi_base_clk)) then
            if (wr_dvd = '1') then
                --slow down count up
                if (pi_btn_n(3) = '0' and reg_cnt_devider = 0) then
                    reg_8bit_cnt <= reg_8bit_cnt + 1;
                end if;
            else
                --clock speed count up.
                if (pi_btn_n(3) = '0') then
                    reg_8bit_cnt <= reg_8bit_cnt + 1;
                end if;
            end if;
        end if;
    end process;

    --
    cnt_devide_p : process (wr_rst_n, pi_base_clk)
    begin
        if (wr_rst_n = '0') then
            reg_cnt_devider <= 0;
        elsif (rising_edge(pi_base_clk)) then
            reg_cnt_devider <= reg_cnt_devider + 1;
        end if;
    end process;

end rtl;
