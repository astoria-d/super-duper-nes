library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.conv_integer;
use ieee.std_logic_arith.conv_std_logic_vector;
use ieee.std_logic_unsigned.all;

entity i2c_slave is 
    port (
        pi_rst_n        : in    std_logic;
        pi_base_clk     : in    std_logic;
        pi_i2c_scl      : in std_logic;
        pio_i2c_sda     : inout std_logic
    );
end i2c_slave;

architecture rtl of i2c_slave is


type i2c_bus_stat is (idle, start,
    a6, a5, a4, a3, a2, a1, a0, rw, a_ack,
    d7, d6, d5, d4, d3, d2, d1, d0, d_ack,
    stop);

signal reg_cur_state      : i2c_bus_stat;
signal reg_next_state     : i2c_bus_stat;

begin

    --i2c bus state machine (state transition)...
    set_stat_p : process (pi_rst_n, pi_base_clk)
    begin
        if (pi_rst_n = '0') then
            reg_cur_state <= idle;
        elsif (rising_edge(pi_base_clk)) then
            reg_cur_state <= reg_next_state;
        end if;--if (pi_rst_n = '0') then
    end process;

    --state change to next.
    next_stat_p : process (reg_cur_state, pi_i2c_scl, pio_i2c_sda)
    begin
        case reg_cur_state is
            when idle =>
                if (pi_i2c_scl = '1' and pio_i2c_sda = '0') then
                    reg_next_state <= start;
                else
                    reg_next_state <= reg_cur_state;
                end if;
            when start =>
                if (pi_i2c_scl = '1') then
                    reg_next_state <= a6;
                else
                    reg_next_state <= reg_cur_state;
                end if;
            when a6 =>
                if (pi_i2c_scl = '1') then
                    reg_next_state <= a5;
                else
                    reg_next_state <= reg_cur_state;
                end if;
            when a5 =>
                if (pi_i2c_scl = '1') then
                    reg_next_state <= a4;
                else
                    reg_next_state <= reg_cur_state;
                end if;
            when a4 =>
                if (pi_i2c_scl = '1') then
                    reg_next_state <= a3;
                else
                    reg_next_state <= reg_cur_state;
                end if;
            when a3 =>
                if (pi_i2c_scl = '1') then
                    reg_next_state <= a2;
                else
                    reg_next_state <= reg_cur_state;
                end if;
            when a2 =>
                if (pi_i2c_scl = '1') then
                    reg_next_state <= a1;
                else
                    reg_next_state <= reg_cur_state;
                end if;
            when a1 =>
                if (pi_i2c_scl = '1') then
                    reg_next_state <= a0;
                else
                    reg_next_state <= reg_cur_state;
                end if;
            when a0 =>
                if (pi_i2c_scl = '1') then
                    reg_next_state <= rw;
                else
                    reg_next_state <= reg_cur_state;
                end if;
            when rw =>
                if (pi_i2c_scl = '1') then
                    reg_next_state <= a_ack;
                else
                    reg_next_state <= reg_cur_state;
                end if;
            when a_ack =>
                if (pi_i2c_scl = '1') then
                    reg_next_state <= d7;
                else
                    reg_next_state <= reg_cur_state;
                end if;
            when d7 =>
                if (pi_i2c_scl = '1') then
                    reg_next_state <= d6;
                else
                    reg_next_state <= reg_cur_state;
                end if;
            when d6 =>
                if (pi_i2c_scl = '1') then
                    reg_next_state <= d5;
                else
                    reg_next_state <= reg_cur_state;
                end if;
            when d5 =>
                if (pi_i2c_scl = '1') then
                    reg_next_state <= d4;
                else
                    reg_next_state <= reg_cur_state;
                end if;
            when d4 =>
                if (pi_i2c_scl = '1') then
                    reg_next_state <= d3;
                else
                    reg_next_state <= reg_cur_state;
                end if;
            when d3 =>
                if (pi_i2c_scl = '1') then
                    reg_next_state <= d2;
                else
                    reg_next_state <= reg_cur_state;
                end if;
            when d2 =>
                if (pi_i2c_scl = '1') then
                    reg_next_state <= d1;
                else
                    reg_next_state <= reg_cur_state;
                end if;
            when d1 =>
                if (pi_i2c_scl = '1') then
                    reg_next_state <= d0;
                else
                    reg_next_state <= reg_cur_state;
                end if;
            when d0 =>
                if (pi_i2c_scl = '1') then
                    reg_next_state <= d_ack;
                else
                    reg_next_state <= reg_cur_state;
                end if;
            when d_ack =>
                if (pi_i2c_scl = '1') then
                    reg_next_state <= stop;
                else
                    reg_next_state <= reg_cur_state;
                end if;
            when stop =>
                if (pi_i2c_scl = '1') then
                    reg_next_state <= idle;
                else
                    reg_next_state <= reg_cur_state;
                end if;
        end case;
    end process;

    pio_i2c_sda <= 'Z';
end rtl;
