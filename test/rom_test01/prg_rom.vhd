library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.conv_integer;

entity prg_rom_8k is 
    port (  
            pi_base_clk     : in std_logic;
--            pi_divide_cnt   : in std_logic_vector (4 downto 0);
            pi_ce_n         : in std_logic;
            pi_oe_n         : in std_logic;
            pi_addr         : in std_logic_vector (12 downto 0);
            po_data         : out std_logic_vector (7 downto 0)
        );
end prg_rom_8k;

architecture rtl of prg_rom_8k is

--PROG ROM is 32k
subtype rom_data is std_logic_vector (7 downto 0);
--type rom_array is array (0 to 2**15 - 1) of rom_data;
type rom_array is array (0 to 2**13 - 1) of rom_data;

--for Quartus II environment
signal p_rom : rom_array;
attribute ram_init_file : string;
attribute ram_init_file of p_rom : signal is "sample1-prg-8k.hex";

signal reg_out_n : std_logic;

begin

--    p : process (pi_base_clk)
--    begin
--    if (rising_edge(pi_base_clk)) then
--        if (pi_ce_n = '0' and pi_oe_n = '0' --and pi_divide_cnt(0) = '1'
--        ) then
--            reg_out_n <= '0';
--        else
--            reg_out_n <= '1';
--        end if;
--        if (reg_out_n = '0') then
--            po_data <= p_rom(conv_integer(pi_addr));
--        else
--            po_data <= (others => 'Z');
--        end if;
--    end if;
--    end process;

    p : process (pi_ce_n, pi_oe_n, pi_addr)
    begin
        if (pi_ce_n = '0' and pi_oe_n = '0') then
            po_data <= p_rom(conv_integer(pi_addr));
        else
            po_data <= (others => 'Z');
        end if;
    end process;
end rtl;



---------------------------------------------------
---------------------------------------------------
---------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.conv_integer;

entity chr_rom_4k is 
    port (  
            pi_base_clk     : in std_logic;
            pi_ce_n         : in std_logic;
            pi_oe_n         : in std_logic;
            pi_addr         : in std_logic_vector (11 downto 0);
            po_data         : out std_logic_vector (7 downto 0)
        );
end chr_rom_4k;

architecture rtl of chr_rom_4k is

subtype rom_data is std_logic_vector (7 downto 0);
type rom_array is array (0 to 2**12 - 1) of rom_data;

--for Quartus II environment
signal p_rom : rom_array;
attribute ram_init_file : string;
attribute ram_init_file of p_rom : signal is "sample1-chr-4k.hex";

begin

    p : process (pi_base_clk)
    begin
    if (rising_edge(pi_base_clk)) then
        if (pi_ce_n = '0' and pi_oe_n = '0') then
            po_data <= p_rom(conv_integer(pi_addr));
        else
            po_data <= (others => 'Z');
        end if;
    end if;
    end process;

--    p : process (pi_addr, pi_ce_n, pi_oe_n)
--    begin
--    if (pi_ce_n = '0' and pi_oe_n = '0') then
--        po_data <= p_rom(conv_integer(pi_addr));
--    else
--        po_data <= (others => 'Z');
--    end if;
--    end process;
end rtl;
