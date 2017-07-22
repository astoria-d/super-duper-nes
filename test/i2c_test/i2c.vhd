library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.conv_integer;
use ieee.std_logic_arith.conv_std_logic_vector;
use ieee.std_logic_unsigned.all;


---po_i2c_status(0): '1' = started, '0' = stopped.
---po_i2c_status(1): '1' = acknowleged, '0' = not acknowleged.
---po_i2c_status(2): '1' = read, '0' = write.
entity i2c_slave is 
    port (
        pi_rst_n            : in    std_logic;
        pi_base_clk         : in    std_logic;

        ---i2c bus lines...
        pi_slave_addr       : in    std_logic_vector (6 downto 0);
        pi_i2c_scl          : in    std_logic;
        pio_i2c_sda         : inout std_logic;

        ---i2c bus contoler internal lines...
        po_i2c_status       : out   std_logic_vector (2 downto 0);
        po_slave_in_data    : out   std_logic_vector (7 downto 0);
        pi_slave_out_data   : in    std_logic_vector (7 downto 0)
    );
end i2c_slave;

architecture rtl of i2c_slave is


type i2c_sp_stat is (
    stop, start, restart
    );

type i2c_bus_stat is (
    idle,
    a6, a5, a4, a3, a2, a1, a0, rw, a_ack,
    d7, d6, d5, d4, d3, d2, d1, d0, d_ack
    );

signal reg_cur_sp       : i2c_sp_stat;
signal reg_next_sp      : i2c_sp_stat;
signal reg_old_scl      : std_logic;
signal reg_old_sda      : std_logic;
signal reg_restarted    : boolean;


signal reg_cur_state      : i2c_bus_stat;
signal reg_next_state     : i2c_bus_stat;

signal reg_i2c_cmd_addr         : std_logic_vector(6 downto 0);
signal reg_i2c_cmd_r_nw         : std_logic;
signal reg_i2c_cmd_in_data      : std_logic_vector(7 downto 0);

begin

    --start/stop status.
    set_sp : process (pi_rst_n, pi_base_clk)
    begin
        if (pi_rst_n = '0') then
            reg_cur_sp <= stop;
            reg_old_scl <= '1';
            reg_old_sda <= '1';
        elsif (rising_edge(pi_base_clk)) then
            reg_cur_sp <= reg_next_sp;
            reg_old_scl <= pi_i2c_scl;
            reg_old_sda <= pio_i2c_sda;
        end if;--if (pi_rst_n = '0') then
    end process;

    next_sp : process (pi_rst_n, pi_base_clk)
    begin
        if (pi_rst_n = '0') then
            reg_next_sp <= stop;
            reg_restarted <= false;
        elsif (rising_edge(pi_base_clk)) then
            case reg_cur_sp is
                when stop =>
                    if (pi_i2c_scl = '1' and reg_old_sda = '1' and pio_i2c_sda = '0') then
                        reg_next_sp <= start;
                    end if;
                when start =>
                    if (pi_i2c_scl = '1' and reg_old_sda = '0' and pio_i2c_sda = '1') then
                        reg_next_sp <= stop;
                    elsif (pi_i2c_scl = '1' and reg_old_sda = '1' and pio_i2c_sda = '0') then
                        reg_next_sp <= restart;
                        reg_restarted <= true;
                    elsif (reg_restarted = true and reg_old_scl = '0' and pi_i2c_scl = '1') then
                        reg_restarted <= false;
                    end if;
                when restart =>
                    if (pi_i2c_scl = '0') then
                        reg_next_sp <= start;
                    end if;
            end case;
        end if;--if (pi_rst_n = '0') then
    end process;

    --i2c bus state machine (state transition)...
    set_stat_p : process (pi_rst_n, pi_i2c_scl)
    begin
        if (pi_rst_n = '0') then
            reg_cur_state <= idle;
        elsif (rising_edge(pi_i2c_scl)) then
            if (reg_cur_sp = start) then
                reg_cur_state <= reg_next_state;
            else
                reg_cur_state <= idle;
            end if;
        end if;--if (pi_rst_n = '0') then
    end process;

    --state change to next.
    next_stat_p : process (reg_cur_state, reg_i2c_cmd_r_nw, pio_i2c_sda, reg_restarted)
    begin
        case reg_cur_state is
            when idle =>
                reg_next_state <= a6;
            when a6 =>
                if (reg_restarted = true) then
                    reg_next_state <= a6;
                else
                    reg_next_state <= a5;
                end if;
            when a5 =>
                if (reg_restarted = true) then
                    reg_next_state <= a6;
                else
                    reg_next_state <= a4;
                end if;
            when a4 =>
                if (reg_restarted = true) then
                    reg_next_state <= a6;
                else
                    reg_next_state <= a3;
                end if;
            when a3 =>
                if (reg_restarted = true) then
                    reg_next_state <= a6;
                else
                    reg_next_state <= a2;
                end if;
            when a2 =>
                if (reg_restarted = true) then
                    reg_next_state <= a6;
                else
                    reg_next_state <= a1;
                end if;
            when a1 =>
                if (reg_restarted = true) then
                    reg_next_state <= a6;
                else
                    reg_next_state <= a0;
                end if;
            when a0 =>
                if (reg_restarted = true) then
                    reg_next_state <= a6;
                else
                end if;
                reg_next_state <= rw;
            when rw =>
                if (reg_restarted = true) then
                    reg_next_state <= a6;
                else
                    reg_next_state <= a_ack;
                end if;
            when a_ack =>
                if (reg_restarted = true) then
                    reg_next_state <= a6;
                else
                    reg_next_state <= d7;
                end if;
            when d7 =>
                if (reg_restarted = true) then
                    reg_next_state <= a6;
                else
                    reg_next_state <= d6;
                end if;
            when d6 =>
                if (reg_restarted = true) then
                    reg_next_state <= a6;
                else
                    reg_next_state <= d5;
                end if;
            when d5 =>
                if (reg_restarted = true) then
                    reg_next_state <= a6;
                else
                    reg_next_state <= d4;
                end if;
            when d4 =>
                if (reg_restarted = true) then
                    reg_next_state <= a6;
                else
                    reg_next_state <= d3;
                end if;
            when d3 =>
                if (reg_restarted = true) then
                    reg_next_state <= a6;
                else
                    reg_next_state <= d2;
                end if;
            when d2 =>
                if (reg_restarted = true) then
                    reg_next_state <= a6;
                else
                    reg_next_state <= d1;
                end if;
            when d1 =>
                if (reg_restarted = true) then
                    reg_next_state <= a6;
                else
                    reg_next_state <= d0;
                end if;
            when d0 =>
                if (reg_restarted = true) then
                    reg_next_state <= a6;
                else
                    reg_next_state <= d_ack;
                end if;
            when d_ack =>
                if (reg_restarted = true) then
                    reg_next_state <= a6;
                else
                    if (reg_i2c_cmd_r_nw = '0') then
                        reg_next_state <= d7;
                    else
                        --wait for ack.
                        if (pio_i2c_sda = '0') then
                            reg_next_state <= d7;
                        else
                            reg_next_state <= reg_cur_state;
                        end if;
                    end if;
                end if;
        end case;
    end process;

    --i2c addr/data set.
    po_slave_in_data <= reg_i2c_cmd_in_data;
    set_addr : process (pi_rst_n, pi_i2c_scl)
    begin
        if (pi_rst_n = '0') then
            reg_i2c_cmd_addr <= (others => '0');
            reg_i2c_cmd_r_nw <= '1';
            reg_i2c_cmd_in_data <= (others => '0');
        elsif (rising_edge(pi_i2c_scl)) then
            --address sequence.
            if (reg_cur_sp = start and reg_cur_state = idle) then
                reg_i2c_cmd_addr (6) <= pio_i2c_sda;
            elsif (reg_cur_state = a6) then
                reg_i2c_cmd_addr (5) <= pio_i2c_sda;
            elsif (reg_cur_state = a5) then
                reg_i2c_cmd_addr (4) <= pio_i2c_sda;
            elsif (reg_cur_state = a4) then
                reg_i2c_cmd_addr (3) <= pio_i2c_sda;
            elsif (reg_cur_state = a3) then
                reg_i2c_cmd_addr (2) <= pio_i2c_sda;
            elsif (reg_cur_state = a2) then
                reg_i2c_cmd_addr (1) <= pio_i2c_sda;
            elsif (reg_cur_state = a1) then
                reg_i2c_cmd_addr (0) <= pio_i2c_sda;
            elsif (reg_cur_state = a0) then
                reg_i2c_cmd_r_nw <= pio_i2c_sda;

            --data write sequence (input).
            elsif (reg_cur_state = a_ack and reg_i2c_cmd_r_nw = '0') then
                reg_i2c_cmd_in_data (7) <= pio_i2c_sda;
            elsif (reg_cur_state = d7 and reg_i2c_cmd_r_nw = '0') then
                reg_i2c_cmd_in_data (6) <= pio_i2c_sda;
            elsif (reg_cur_state = d6 and reg_i2c_cmd_r_nw = '0') then
                reg_i2c_cmd_in_data (5) <= pio_i2c_sda;
            elsif (reg_cur_state = d5 and reg_i2c_cmd_r_nw = '0') then
                reg_i2c_cmd_in_data (4) <= pio_i2c_sda;
            elsif (reg_cur_state = d4 and reg_i2c_cmd_r_nw = '0') then
                reg_i2c_cmd_in_data (3) <= pio_i2c_sda;
            elsif (reg_cur_state = d3 and reg_i2c_cmd_r_nw = '0') then
                reg_i2c_cmd_in_data (2) <= pio_i2c_sda;
            elsif (reg_cur_state = d2 and reg_i2c_cmd_r_nw = '0') then
                reg_i2c_cmd_in_data (1) <= pio_i2c_sda;
            elsif (reg_cur_state = d1 and reg_i2c_cmd_r_nw = '0') then
                reg_i2c_cmd_in_data (0) <= pio_i2c_sda;
            end if;
        end if;--if (pi_rst_n = '0') then
    end process;

    --output (ack and read response: output) i2c bus.
    out_data : process (pi_rst_n, pi_base_clk)
    begin
        if (pi_rst_n = '0') then
            pio_i2c_sda <= 'Z';
            po_i2c_status <= (others => '0');
        elsif (rising_edge(pi_base_clk)) then
            if (reg_i2c_cmd_addr = pi_slave_addr) then
                if (reg_cur_sp = start) then
                    po_i2c_status(0) <= '1';
                else
                    po_i2c_status(0) <= '0';
                end if;

                po_i2c_status(2) <= reg_i2c_cmd_r_nw;
                
                if (reg_cur_state = d_ack and pi_i2c_scl = '1') then
                    po_i2c_status(1) <= '1';
                else
                    po_i2c_status(1) <= '0';
                end if;

                --addr ack reply.
                if (reg_cur_state = rw and pi_i2c_scl = '0') then
                    pio_i2c_sda <= '0';
                elsif (reg_cur_state = a_ack and pi_i2c_scl = '0') then
                    if (reg_i2c_cmd_r_nw = '0') then
                        pio_i2c_sda <= 'Z';
                    elsif (pi_i2c_scl = '0') then
                        pio_i2c_sda <= pi_slave_out_data(7);
                    end if;
                
                elsif (reg_cur_state = d7 and reg_i2c_cmd_r_nw = '1') then
                    if (pi_i2c_scl = '0') then
                        pio_i2c_sda <= pi_slave_out_data(6);
                    end if;
                elsif (reg_cur_state = d6 and reg_i2c_cmd_r_nw = '1') then
                    if (pi_i2c_scl = '0') then
                        pio_i2c_sda <= pi_slave_out_data(5);
                    end if;
                elsif (reg_cur_state = d5 and reg_i2c_cmd_r_nw = '1') then
                    if (pi_i2c_scl = '0') then
                        pio_i2c_sda <= pi_slave_out_data(4);
                    end if;
                elsif (reg_cur_state = d4 and reg_i2c_cmd_r_nw = '1') then
                    if (pi_i2c_scl = '0') then
                        pio_i2c_sda <= pi_slave_out_data(3);
                    end if;
                elsif (reg_cur_state = d3 and reg_i2c_cmd_r_nw = '1') then
                    if (pi_i2c_scl = '0') then
                        pio_i2c_sda <= pi_slave_out_data(2);
                    end if;
                elsif (reg_cur_state = d2 and reg_i2c_cmd_r_nw = '1') then
                    if (pi_i2c_scl = '0') then
                        pio_i2c_sda <= pi_slave_out_data(1);
                    end if;
                elsif (reg_cur_state = d1 and reg_i2c_cmd_r_nw = '1') then
                    if (pi_i2c_scl = '0') then
                        pio_i2c_sda <= pi_slave_out_data(0);
                    end if;

                elsif (reg_cur_state = d0 and pi_i2c_scl = '0') then
                    --data ack reply.
                    if (reg_i2c_cmd_r_nw = '0') then
                        pio_i2c_sda <= '0';
                    else
                    --yield bus for incoming data.
                        pio_i2c_sda <= 'Z';
                    end if;
                elsif (reg_cur_state = d_ack and pi_i2c_scl = '0') then
                    pio_i2c_sda <= 'Z';

                end if;
            else
                po_i2c_status <= (others => '0');
                pio_i2c_sda <= 'Z';
            end if;--if (reg_cur_state = rw and pi_i2c_scl = '0') then

        end if;--if (pi_rst_n = '0') then
    end process;
end rtl;
