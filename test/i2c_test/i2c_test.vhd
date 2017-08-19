library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.conv_integer;
use ieee.std_logic_arith.conv_std_logic_vector;
use ieee.std_logic_unsigned.all;

entity i2c_test is 
    port (
        pi_base_clk     : in    std_logic;
        pi_reset_n      : in    std_logic;
        pi_key          : in    std_logic_vector(3 downto 0);
        pi_sw           : in    std_logic_vector(9 downto 0);
        po_led          : out   std_logic_vector(9 downto 0);

        pi_i2c_scl      : in    std_logic;
        pio_i2c_sda     : inout std_logic;

--        pi_phi2             : in std_logic;
--        pi_prg_ce_n         : in std_logic;
--        pi_prg_r_nw         : in std_logic;
--        pi_prg_addr         : in std_logic_vector(14 downto 0);
--        po_prg_data         : out std_logic_vector(7 downto 0);
--        pi_chr_ce_n         : in std_logic;
--        pi_chr_oe_n         : in std_logic;
--        pi_chr_we_n         : in std_logic;
--        pi_chr_addr         : in std_logic_vector(12 downto 0);
--        po_chr_data         : out std_logic_vector(7 downto 0);
        po_dbg_cnt          : out std_logic_vector (63 downto 0)
         );
end i2c_test;

architecture rtl of i2c_test is


component i2c_slave
port (
    pi_rst_n            : in    std_logic;
    pi_slave_addr       : in    std_logic_vector (6 downto 0);
    pi_i2c_scl          : in    std_logic;
    pio_i2c_sda         : inout std_logic;
    po_i2c_status       : out   std_logic_vector (2 downto 0);
    po_slave_in_data    : out   std_logic_vector (7 downto 0);
    pi_slave_out_data   : in    std_logic_vector (7 downto 0)
    );
end component;

component i2c_eeprom
    generic (abus_size : integer := 16);
    port (
        pi_rst_n        : in std_logic;
        pi_i2c_clk      : in std_logic;
        pi_bus_xfer     : in std_logic;
        pi_r_nw         : in std_logic;
        pi_bus_ack      : in std_logic;
        po_bus_ack      : out std_logic;
        pi_data         : in std_logic_vector (7 downto 0);
        po_data         : out std_logic_vector (7 downto 0)
    );
end component;

signal reg_dbg_cnt          : std_logic_vector (63 downto 0);
signal reg_slave_in_data    : std_logic_vector (7 downto 0);
signal reg_slave_out_data   : std_logic_vector (7 downto 0);
signal reg_slave_status     : std_logic_vector (2 downto 0);
signal reg_slave_addr_ack   : std_logic;


begin

    po_led <= reg_dbg_cnt(32 downto 23);
    po_dbg_cnt <= reg_dbg_cnt;
    --reg_slave_out_data <= conv_std_logic_vector(16#c3#, 8);
    
    i2c_slave_inst : i2c_slave
    port map (
        pi_reset_n,
        conv_std_logic_vector(16#44#, 7),
        pi_i2c_scl,
        pio_i2c_sda,
        reg_slave_status,
        reg_slave_in_data,
        reg_slave_out_data
    );

    i2c_eeprom_inst : i2c_eeprom generic map (4)
    port map (
        pi_reset_n,
        pi_i2c_scl,
        reg_slave_status(0),
        reg_slave_status(2),
        reg_slave_status(1),
        reg_slave_addr_ack,
        reg_slave_in_data,
        reg_slave_out_data
    );

    deb_cnt_p : process (pi_base_clk, pi_reset_n)
use ieee.std_logic_unsigned.all;
    variable cnt : integer;
    begin
        if (pi_reset_n = '0') then
            reg_dbg_cnt <= (others => '0');
            cnt := 0;
        elsif (rising_edge(pi_base_clk)) then
            if (cnt = 0) then
               if (pi_sw(0) = '1') then
                   --debug count is half cycle because too fast to capture in st ii.
                   reg_dbg_cnt <= reg_dbg_cnt + 1;
                   cnt := 1;
                end if;
            else
                cnt := 0;
            end if;
        end if;
    end process;
end rtl;
