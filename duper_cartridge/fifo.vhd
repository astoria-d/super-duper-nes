library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.conv_integer;
use ieee.std_logic_unsigned.all;

----SRAM syncronous memory.
entity fifo is 
    generic (abus_size : integer := 8);
    port (
        pi_rst_n        : in std_logic;
        pi_base_clk     : in std_logic;
        pi_r_nw         : in std_logic;
        pi_data         : in std_logic_vector (7 downto 0);
        po_data         : out std_logic_vector (7 downto 0);
        po_stat_empty   : in std_logic;
        po_stat_full    : in std_logic
    );
end fifo;

architecture rtl of fifo is

subtype ram_data is std_logic_vector (7 downto 0);
type ram_array is array (0 to 2**abus_size - 1) of ram_data;

---ram is initialized with 0.
signal work_ram : ram_array := (others => (others => '0'));

signal reg_eeprom_addr  : std_logic_vector(abus_size -1 downto 0);

begin

    p_write : process (pi_rst_n, pi_base_clk)
    begin
        if (pi_rst_n = '0') then
            work_ram <= (others => "11111111");
        elsif (rising_edge(pi_base_clk)) then
            work_ram(conv_integer(reg_eeprom_addr)) <= pi_data;
        end if;
    end process;

    p_read : process (pi_base_clk)
    begin
        if (rising_edge(pi_base_clk)) then
            po_data <= work_ram(conv_integer(reg_eeprom_addr));
        end if;
    end process;
    
end rtl;

