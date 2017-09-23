library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.conv_integer;
use ieee.std_logic_unsigned.all;

----SRAM syncronous memory.
entity i2c_eeprom is 
    generic (abus_size : integer := 16);
    port (
        pi_rst_n        : in std_logic;
        pi_base_clk     : in std_logic;
        pi_bus_xfer     : in std_logic;
        pi_r_nw         : in std_logic;
        pi_bus_ack      : in std_logic;
        po_bus_ack      : out std_logic;
        pi_data         : in std_logic_vector (7 downto 0);
        po_data         : out std_logic_vector (7 downto 0)
    );
end i2c_eeprom;

architecture rtl of i2c_eeprom is

signal reg_ack_edge         : std_logic;
signal reg_write_cnt        : std_logic_vector(15 downto 0);
signal reg_eeprom_addr      : std_logic_vector(15 downto 0);
signal reg_eeprom_data      : std_logic_vector(7 downto 0);

subtype ram_data is std_logic_vector (7 downto 0);
type ram_array is array (0 to 2**abus_size - 1) of ram_data;

---ram is initialized with 0.
signal work_ram : ram_array := (others => (others => '0'));

begin

    --synchronize and edge detect.
    ack_edge_p : process (pi_rst_n, pi_base_clk)
    variable tmp_b_ack : std_logic_vector (2 downto 0);
    begin
        if (pi_rst_n = '0') then
            tmp_b_ack := (others => '0');
            reg_ack_edge <= '0';
        elsif (rising_edge(pi_base_clk)) then
            tmp_b_ack := pi_bus_ack & tmp_b_ack(2 downto 1);
            reg_ack_edge <= tmp_b_ack(1) and (not tmp_b_ack(0));
        end if;
    end process;

    addr_set_p : process (pi_rst_n, pi_base_clk)
    begin
        if (pi_rst_n = '0') then
            reg_write_cnt <= (others => '0');
            reg_eeprom_addr <= (others => '0');
        elsif (rising_edge(pi_base_clk)) then
            if (pi_bus_xfer = '1') then
                if (reg_ack_edge = '1') then
                    if (pi_r_nw = '0') then
                        if (conv_integer(reg_write_cnt) = 0) then
                            --set eeprom addr low
                            reg_eeprom_addr(7 downto 0) <= pi_data;
                        elsif (conv_integer(reg_write_cnt) = 1) then
                            --set eeprom addr hi
                            reg_eeprom_addr(15 downto 8) <= reg_eeprom_addr(7 downto 0);
                            reg_eeprom_addr(7 downto 0) <= pi_data;
                        else
                            --addr auto increment
                            reg_eeprom_addr <= reg_eeprom_addr + 1;
                        end if;
                        reg_write_cnt <= reg_write_cnt + 1;
                    elsif (pi_r_nw = '1') then
                        --addr auto increment
                        reg_eeprom_addr <= reg_eeprom_addr + 1;
                        reg_write_cnt <= (others => '0');
                    end if;
                end if;--if (reg_ack_edge = '1') then
            else
                reg_write_cnt <= (others => '0');
            end if;--if (pi_bus_xfer = '1') then
        end if;--if (pi_rst_n = '0') then
    end process;

    p_write : process (pi_rst_n, pi_base_clk)
    begin
        if (pi_rst_n = '0') then
            work_ram <= (others => "11111111");
        elsif (rising_edge(pi_base_clk)) then
            if (reg_ack_edge = '1' and pi_r_nw = '0' and reg_write_cnt > 1) then
                work_ram(conv_integer(reg_eeprom_addr(abus_size -1 downto 0))) <= pi_data;
            end if;
        end if;
    end process;

    po_bus_ack <= '0';

    p_read : process (pi_base_clk)
    begin
        if (rising_edge(pi_base_clk)) then
            po_data <= work_ram(conv_integer(reg_eeprom_addr(abus_size -1 downto 0)));
--            if (pi_bus_xfer = '1' and pi_r_nw = '1') then
--            else
--                po_data <= (others => 'Z');
--            end if;
        end if;
    end process;
    
end rtl;

