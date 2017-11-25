library ieee;
use ieee.std_logic_1164.all;

entity synchronizer is 
    port (
        pi_rst_n            : in    std_logic;
        pi_base_clk         : in    std_logic;
        pi_async_input      : in    std_logic;
        po_sync_output      : out   std_logic
    );
end synchronizer;

architecture rtl of synchronizer is

begin

    --for metastability, synchronize with two stages intermediate FF.
    sync_p : process (pi_rst_n, pi_base_clk)
    variable reg_temp   : std_logic_vector(2 downto 0);
    begin
        if (pi_rst_n = '0') then
            reg_temp := (others => '0');
        elsif (rising_edge(pi_base_clk)) then
            --shift two stage register.
            reg_temp := pi_async_input  & reg_temp(2 downto 1);
            po_sync_output <= reg_temp(0);
        end if;--if (pi_rst_n = '0') then
    end process;

end rtl;

----------------------------------------------
----------------------------------------------
----------------------------------------------
----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity synchronized_vector is
    generic (abus_size : integer := 8);
    port (
        pi_rst_n            : in    std_logic;
        pi_base_clk         : in    std_logic;
        pi_async_input      : in    std_logic_vector(abus_size - 1 downto 0);
        po_sync_output      : out   std_logic_vector(abus_size - 1 downto 0)
    );
end synchronized_vector;

architecture rtl of synchronized_vector is

subtype TMP_REG_T is std_logic_vector (2 downto 0);
type TMP_REG_ARRAY_T is array (0 to abus_size - 1) of TMP_REG_T;


begin

    sync_p : process (pi_rst_n, pi_base_clk)
    variable reg_temp   : TMP_REG_ARRAY_T;
    begin
        if (pi_rst_n = '0') then
            for i in 0 to abus_size -1 loop
                reg_temp(i) := (others => '0');
            end loop;

        elsif (rising_edge(pi_base_clk)) then
            for i in 0 to abus_size -1 loop
                --shift two stage register.
                reg_temp(i) := pi_async_input(i)  & reg_temp(i)(2 downto 1);
                po_sync_output(i) <= reg_temp(i)(0);
            end loop;
        end if;--if (pi_rst_n = '0') then
    end process;

end rtl;


