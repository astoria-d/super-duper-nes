library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.conv_integer;
use ieee.std_logic_unsigned.all;

----SRAM syncronous memory.
entity i2c_eeprom is 
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
end i2c_eeprom;

architecture rtl of i2c_eeprom is

--subtype ram_data is std_logic_vector (dbus_size -1 downto 0);
--type ram_array is array (0 to 2**abus_size - 1) of ram_data;
--
-----ram is initialized with 0.
--signal work_ram : ram_array := (others => (others => '0'));

signal reg_i2c_addr_set     : integer range 0 to 1;
signal reg_write_cnt        : std_logic_vector(15 downto 0);
signal reg_eeprom_addr      : std_logic_vector(15 downto 0);
signal reg_eeprom_data      : std_logic_vector(7 downto 0);

begin

    addr_set_p : process (pi_rst_n, pi_i2c_clk)
    begin
        if (pi_rst_n = '0') then
            reg_i2c_addr_set <= 0;
            reg_write_cnt <= (others => '0');
            reg_eeprom_addr <= (others => '0');
        elsif (falling_edge(pi_i2c_clk)) then
            if (pi_bus_ack = '1') then
                if (pi_r_nw = '0') then
                    if (reg_write_cnt = "00000000") then
                        reg_eeprom_addr(7 downto 0) <= pi_data;
                    elsif (reg_write_cnt = "00000001") then
                        reg_eeprom_addr(15 downto 8) <= pi_data;
                    end if;
                    reg_write_cnt <= reg_write_cnt + 1;
                else
                    reg_write_cnt <= (others => '0');
                end if;
            end if;
        end if;--if (pi_rst_n = '0') then
    end process;

--    p_write : process (clk)
--    begin
--    if (rising_edge(clk)) then
--        if (ce_n = '0' and we_n = '0') then
--            work_ram(conv_integer(addr)) <= d_io;
--        end if;
--    end if;
--    end process;
--
--    p_read : process (clk)
--    begin
--    if (rising_edge(clk)) then
--        if (ce_n= '0' and we_n = '1' and oe_n = '0') then
--            d_io <= work_ram(conv_integer(addr));
--        else
--            d_io <= (others => 'Z');
--        end if;
--    end if;
--    end process;
    
end rtl;

