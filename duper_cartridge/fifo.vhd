library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.conv_integer;
use ieee.std_logic_unsigned.all;

entity fifo is 
    generic (abus_size : integer := 8);
    port (
        pi_rst_n        : in std_logic;
        pi_base_clk     : in std_logic;
        pi_ce_n         : in std_logic;
        pi_oe_n         : in std_logic;
        pi_we_n         : in std_logic;
        pi_data         : in std_logic_vector (7 downto 0);
        po_data         : out std_logic_vector (7 downto 0);
        po_stat_empty   : out std_logic;
        po_stat_full    : out std_logic
    );
end fifo;

architecture rtl of fifo is

subtype ram_data is std_logic_vector (7 downto 0);
type ram_array is array (0 to 2**abus_size - 1) of ram_data;

constant FIFO_MAX       : integer := 2 ** abus_size - 1;

---ram is initialized with 0.
signal work_ram : ram_array := (others => (others => '0'));

--fifo pointer registers.
signal reg_fifo_head : std_logic_vector(abus_size -1 downto 0);
signal reg_fifo_tail : std_logic_vector(abus_size -1 downto 0);
signal reg_fifo_size    : integer range 0 to 2 ** abus_size - 1;
signal reg_stat_empty   : std_logic;
signal reg_stat_full    : std_logic;

begin

    --push fifo
    p_write : process (pi_rst_n, pi_base_clk)
    begin
        if (pi_rst_n = '0') then
            work_ram <= (others => "11111111");
        elsif (rising_edge(pi_base_clk)) then
            if (pi_ce_n = '0' and pi_we_n = '0') then
                work_ram(conv_integer(reg_fifo_tail)) <= pi_data;
            end if;
        end if;
    end process;

    --pop fifo
    p_read : process (pi_base_clk)
    begin
        if (rising_edge(pi_base_clk)) then
            if (pi_ce_n = '0' and pi_oe_n = '0') then
                po_data <= work_ram(conv_integer(reg_fifo_head));
            else
                po_data <= (others => 'Z');
            end if;
        end if;
    end process;

    --fifo pointer...
    po_stat_empty   <= reg_stat_empty;
    po_stat_full    <= reg_stat_full;

    p_fifo_pointer : process (pi_rst_n, pi_base_clk)
    begin
        if (pi_rst_n = '0') then
            reg_fifo_tail <= (others => '0');
            reg_fifo_head <= (others => '0');
            reg_fifo_size <= 0;
            reg_stat_empty <= '1';
            reg_stat_full <= '0';

        elsif (rising_edge(pi_base_clk)) then

            if (reg_fifo_size > 0) then
                reg_stat_empty <= '0';
            else
                reg_stat_empty <= '1';
            end if;

            if (reg_fifo_size < FIFO_MAX) then
                reg_stat_full <= '0';
            else
                reg_stat_full <= '1';
            end if;

            if (pi_ce_n = '0' and pi_we_n = '0') then
                if (reg_fifo_size < FIFO_MAX) then
                    reg_fifo_tail <= reg_fifo_tail + 1;
                    reg_fifo_size <= reg_fifo_size + 1;
                end if;
            elsif (pi_ce_n = '0' and pi_oe_n = '0') then
                if (reg_fifo_size > 0) then
                    reg_fifo_head <= reg_fifo_head + 1;
                    reg_fifo_size <= reg_fifo_size - 1;
                end if;
            end if;
        end if;
    end process;

end rtl;

