library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.conv_integer;

entity prg_rom is 
    port (  
            pi_base_clk     : in std_logic;
            pi_ce_n         : in std_logic;
            pi_oe_n         : in std_logic;
            pi_addr         : in std_logic_vector (14 downto 0);
            po_data         : out std_logic_vector (7 downto 0)
        );
end prg_rom;

architecture rtl of prg_rom is

--constant PROM_SIZE   : integer := 15;
constant PROM_SIZE   : integer := 13;

--PROG ROM is 32k
subtype rom_data is std_logic_vector (7 downto 0);
type rom_array is array (0 to 2**PROM_SIZE - 1) of rom_data;

--for Quartus II environment
signal p_rom : rom_array;
attribute ram_init_file : string;

--attribute ram_init_file of p_rom : signal is "sample1-prg.hex";
attribute ram_init_file of p_rom : signal is "sample1-prg-8k.hex";

signal reg_out_n : std_logic;

begin

    p : process (pi_ce_n, pi_oe_n, pi_addr)
    begin
        if (pi_ce_n = '0' and pi_oe_n = '0') then
            po_data <= p_rom(conv_integer(pi_addr(PROM_SIZE - 1 downto 0)));
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

entity chr_rom is 
    port (  
            pi_base_clk     : in std_logic;
            pi_ce_n         : in std_logic;
            pi_oe_n         : in std_logic;
            pi_addr         : in std_logic_vector (12 downto 0);
            po_data         : out std_logic_vector (7 downto 0)
        );
end chr_rom;

architecture rtl of chr_rom is

--constant CROM_SIZE   : integer := 13;
constant CROM_SIZE   : integer := 12;

subtype rom_data is std_logic_vector (7 downto 0);
type rom_array is array (0 to 2**CROM_SIZE - 1) of rom_data;

--for Quartus II environment
signal p_rom : rom_array;
attribute ram_init_file : string;

--attribute ram_init_file of p_rom : signal is "sample1-chr.hex";
attribute ram_init_file of p_rom : signal is "sample1-chr-4k.hex";

begin

    p : process (pi_base_clk)
    begin
    if (rising_edge(pi_base_clk)) then
        if (pi_ce_n = '0' and pi_oe_n = '0') then
            po_data <= p_rom(conv_integer(pi_addr(CROM_SIZE - 1 downto 0)));
        else
            po_data <= (others => 'Z');
        end if;
    end if;
    end process;

end rtl;
