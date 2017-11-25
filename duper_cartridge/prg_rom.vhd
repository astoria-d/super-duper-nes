library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.conv_integer;
use ieee.std_logic_arith.conv_std_logic_vector;

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

--PROG ROM is 32k
--constant PROM_SIZE   : integer := 15;

--prom size is reduced to 8kb.
constant PROM_SIZE   : integer := 13;

subtype rom_data is std_logic_vector (7 downto 0);
type rom_array is array (0 to 2**PROM_SIZE - 1) of rom_data;

--for ModelSim environment from here
impure function rom_fill return rom_array is 
type binary_file is file of character;
FILE nes_file : binary_file OPEN read_mode IS "../duper-rom.nes" ;
variable read_data : character;
variable i : integer;
variable ret : rom_array;
begin
    --skip first 16 bit data(NES cardridge header part.)
    for i in 0 to 15 loop
        read(nes_file, read_data);
    end loop;
    for i in ret'range loop
        read(nes_file, read_data);
        ret(i) :=
            conv_std_logic_vector(character'pos(read_data), 8);
    end loop;
    return ret;
end rom_fill;

--itinialize with the rom_fill function.
signal p_rom : rom_array := rom_fill;
--ModelSim environment ends here

--for Quartus II environment
--signal p_rom : rom_array;
--attribute ram_init_file : string;
--attribute ram_init_file of p_rom : signal is "sample1-prg-8k.hex";


signal reg_out_n : std_logic;
begin
    p : process (pi_base_clk)
    begin
        if (rising_edge(pi_base_clk)) then
            if (pi_ce_n = '0' and pi_oe_n = '0') then
                po_data <= p_rom(conv_integer(pi_addr(PROM_SIZE - 1 downto 0)));
--                po_data <= p_rom(0);
            else
                po_data <= (others => 'Z');
            end if;
        end if;
    end process;
end rtl;



---------------------------------------------------
---------------------------------------------------
---------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

entity duper_prg_rom is 
    port (  
            pi_base_clk     : in std_logic;
            pi_ce_n         : in std_logic;
            pi_oe_n         : in std_logic;
            pi_we_n         : in std_logic;
            pi_addr         : in std_logic_vector (14 downto 0);
            pio_data        : inout std_logic_vector (7 downto 0);
            po_push_fifo    : out std_logic_vector (7 downto 0);
            pi_pop_fifo     : in std_logic_vector (7 downto 0);
            pi_fifo_stat    : in std_logic_vector (7 downto 0)
        );
end duper_prg_rom;

architecture rtl of duper_prg_rom is

component prg_rom port (
    pi_base_clk 	: in std_logic;
    pi_ce_n         : in std_logic;
    pi_oe_n         : in std_logic;
    pi_addr         : in std_logic_vector (14 downto 0);
    po_data         : out std_logic_vector (7 downto 0)
    );
end component;

signal reg_rom_data     : std_logic_vector (7 downto 0);


begin

    prom_inst : prg_rom port map (
        pi_base_clk,
        pi_ce_n,
        pi_oe_n,
        pi_addr,
        reg_rom_data
    );

    p_read : process (pi_base_clk)
    begin
        if (rising_edge(pi_base_clk)) then
            if (pi_ce_n = '0' and pi_oe_n = '0') then
                if (pi_addr = "111111111111001") then
                    --read 0xfff9 is pop fifo
                    pio_data <= pi_pop_fifo;
                elsif (pi_addr = "111111111111000") then
                    --read 0xfff8 is fifo status
                    pio_data <= pi_fifo_stat;
                else
                    pio_data <= reg_rom_data;
                end if;
            else
                pio_data <= (others => 'Z');
            end if;
        end if;
    end process;

    p_write : process (pi_base_clk)
    begin
        if (rising_edge(pi_base_clk)) then
            if (pi_ce_n = '0' and pi_we_n = '0') then
                if (pi_addr = "111111111111001") then
                    --write 0xfff9 is push fifo
                    po_push_fifo <= pio_data;
                else
                    po_push_fifo <= (others => 'Z');
                end if;
            else
                po_push_fifo <= (others => 'Z');
            end if;
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
