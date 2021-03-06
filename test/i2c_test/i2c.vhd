library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.conv_integer;
use ieee.std_logic_arith.conv_std_logic_vector;
use ieee.std_logic_unsigned.all;


---po_i2c_status(0): '1' = bus transfering, '0' = stopped.
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
signal reg_bsyn_sda     : std_logic;
signal reg_bsyn_scl     : std_logic;

signal reg_cur_state      : i2c_bus_stat;
signal reg_next_state     : i2c_bus_stat;

signal reg_i2c_cmd_addr         : std_logic_vector(6 downto 0);
signal reg_i2c_cmd_r_nw         : std_logic;
signal reg_i2c_cmd_in_data      : std_logic_vector(6 downto 0);

begin

    --for metastability, synchronize with two stages intermediate FF.
    bsync_p : process (pi_rst_n, pi_base_clk)
    variable reg_temp_sda   : std_logic_vector(2 downto 0);
    variable reg_temp_scl   : std_logic_vector(2 downto 0);
    begin
        if (pi_rst_n = '0') then
            reg_temp_sda := (others => '0');
            reg_temp_scl := (others => '0');
        elsif (rising_edge(pi_base_clk)) then
            --shift two stage register.
            reg_temp_sda := pio_i2c_sda & reg_temp_sda(2 downto 1);
            reg_temp_scl := pi_i2c_scl & reg_temp_scl(2 downto 1);
            reg_bsyn_sda <= reg_temp_sda(0);
            reg_bsyn_scl <= reg_temp_scl(0);
        end if;--if (pi_rst_n = '0') then
    end process;

    --start/stop w/ edge detect.
    edge_detect_p : process (pi_rst_n, pi_base_clk)
    variable reg_temp_sda2  : std_logic;
    variable reg_temp_st    : i2c_sp_stat;
    begin
        if (pi_rst_n = '0') then
            reg_temp_sda2 := '0';
            reg_cur_sp <= stop;
            reg_temp_st := stop;
        elsif (rising_edge(pi_base_clk)) then
            if (reg_bsyn_scl = '1' and reg_bsyn_sda = '0' and reg_temp_sda2 = '1'
                and reg_cur_sp = stop) then
                reg_cur_sp <= start;
            elsif (reg_bsyn_scl = '1' and reg_bsyn_sda = '0' and reg_temp_sda2 = '1'
                and reg_cur_sp = start) then
                reg_cur_sp <= restart;
            elsif (reg_bsyn_scl = '1' and reg_bsyn_sda = '1' and reg_temp_sda2 = '0'
                and reg_cur_sp = start) then
                reg_cur_sp <= stop;
            elsif (reg_temp_st = restart) then
                reg_cur_sp <= start;
            end if;
            reg_temp_sda2 := reg_bsyn_sda;
            reg_temp_st := reg_cur_sp;
        end if;--if (pi_rst_n = '0') then
    end process;

    --i2c bus state machine (state transition)...
    set_stat_p : process (pi_rst_n, reg_cur_sp, pi_i2c_scl)
    begin
        if (pi_rst_n = '0') then
            reg_cur_state <= idle;
        elsif (reg_cur_sp = stop or reg_cur_sp = restart) then
            reg_cur_state <= idle;
        elsif (rising_edge(pi_i2c_scl)) then
            reg_cur_state <= reg_next_state;
        end if;--if (pi_rst_n = '0') then
    end process;

    --state change to next.
    next_stat_p : process (reg_cur_state, reg_i2c_cmd_r_nw, pio_i2c_sda)

procedure set_next_stat
(
    pi_stat    : in i2c_bus_stat
) is
begin
    reg_next_state <= pi_stat;
end;

    begin
        case reg_cur_state is
            when idle =>
                set_next_stat(a6);
            when a6 =>
                set_next_stat(a5);
            when a5 =>
                set_next_stat(a4);
            when a4 =>
                set_next_stat(a3);
            when a3 =>
                set_next_stat(a2);
            when a2 =>
                set_next_stat(a1);
            when a1 =>
                set_next_stat(a0);
            when a0 =>
                set_next_stat(rw);
            when rw =>
                set_next_stat(a_ack);
            when a_ack =>
                set_next_stat(d7);
            when d7 =>
                set_next_stat(d6);
            when d6 =>
                set_next_stat(d5);
            when d5 =>
                set_next_stat(d4);
            when d4 =>
                set_next_stat(d3);
            when d3 =>
                set_next_stat(d2);
            when d2 =>
                set_next_stat(d1);
            when d1 =>
                set_next_stat(d0);
            when d0 =>
                if (reg_i2c_cmd_r_nw = '0') then
                    set_next_stat(d_ack);
                else
                    --wait for ack.
                    if (pio_i2c_sda = '0') then
                        set_next_stat(d_ack);
                    else
                        set_next_stat(d0);
                    end if;
                end if;
            when d_ack =>
                set_next_stat(d7);
        end case;
    end process;

    --i2c addr/data set.
    set_addr : process (pi_rst_n, pi_i2c_scl)
    begin
        if (pi_rst_n = '0') then
            reg_i2c_cmd_addr <= (others => '0');
            reg_i2c_cmd_r_nw <= '1';
            reg_i2c_cmd_in_data <= (others => '0');
            po_slave_in_data <= (others => '0');
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
                reg_i2c_cmd_in_data (6) <= pio_i2c_sda;
            elsif (reg_cur_state = d7 and reg_i2c_cmd_r_nw = '0') then
                reg_i2c_cmd_in_data (5) <= pio_i2c_sda;
            elsif (reg_cur_state = d6 and reg_i2c_cmd_r_nw = '0') then
                reg_i2c_cmd_in_data (4) <= pio_i2c_sda;
            elsif (reg_cur_state = d5 and reg_i2c_cmd_r_nw = '0') then
                reg_i2c_cmd_in_data (3) <= pio_i2c_sda;
            elsif (reg_cur_state = d4 and reg_i2c_cmd_r_nw = '0') then
                reg_i2c_cmd_in_data (2) <= pio_i2c_sda;
            elsif (reg_cur_state = d3 and reg_i2c_cmd_r_nw = '0') then
                reg_i2c_cmd_in_data (1) <= pio_i2c_sda;
            elsif (reg_cur_state = d2 and reg_i2c_cmd_r_nw = '0') then
                reg_i2c_cmd_in_data (0) <= pio_i2c_sda;
            elsif (reg_cur_state = d1 and reg_i2c_cmd_r_nw = '0') then
                po_slave_in_data <= reg_i2c_cmd_in_data & pio_i2c_sda;
            end if;
        end if;--if (pi_rst_n = '0') then
    end process;

    --output status.
    out_stat : process (pi_rst_n, pi_i2c_scl)
    begin
        if (pi_rst_n = '0') then
            po_i2c_status <= (others => '0');
        elsif (rising_edge(pi_i2c_scl)) then
            if (reg_i2c_cmd_addr = pi_slave_addr) then
                if (reg_cur_state = d7 or
                    reg_cur_state = d6 or
                    reg_cur_state = d5 or
                    reg_cur_state = d4 or
                    reg_cur_state = d3 or
                    reg_cur_state = d2 or
                    reg_cur_state = d1 or
                    reg_cur_state = d0 or
                    reg_cur_state = d_ack) then
                    po_i2c_status(0) <= '1';
                else
                    po_i2c_status(0) <= '0';
                end if;

                po_i2c_status(2) <= reg_i2c_cmd_r_nw;
                
                if (reg_cur_state = d_ack and reg_i2c_cmd_r_nw = '0') then
                    --write
                    po_i2c_status(1) <= '1';
                elsif (reg_cur_state = d0 and reg_i2c_cmd_r_nw = '1') then
                    --read
                    po_i2c_status(1) <= not pio_i2c_sda;
                else
                    po_i2c_status(1) <= '0';
                end if;
            else
                po_i2c_status <= (others => '0');
            end if;--if (reg_i2c_cmd_addr = pi_slave_addr) then
        end if;--if (pi_rst_n = '0') then
    end process;

    --output (ack and read response: output) i2c bus.
    out_data : process (pi_rst_n, pi_i2c_scl)
    begin
        if (pi_rst_n = '0') then
            pio_i2c_sda <= 'Z';
        elsif (falling_edge(pi_i2c_scl)) then
            if (reg_i2c_cmd_addr = pi_slave_addr) then
                if (reg_cur_state = rw) then
                    --addr ack reply.
                    pio_i2c_sda <= '0';
                elsif (reg_cur_state = a_ack) then
                    --data input.
                    if (reg_i2c_cmd_r_nw = '0') then
                        pio_i2c_sda <= 'Z';
                    --data output.
                    else
                        pio_i2c_sda <= pi_slave_out_data(7);
                    end if;

                --data output.
                elsif (reg_cur_state = d7 and reg_i2c_cmd_r_nw = '1') then
                    pio_i2c_sda <= pi_slave_out_data(6);
                elsif (reg_cur_state = d6 and reg_i2c_cmd_r_nw = '1') then
                    pio_i2c_sda <= pi_slave_out_data(5);
                elsif (reg_cur_state = d5 and reg_i2c_cmd_r_nw = '1') then
                    pio_i2c_sda <= pi_slave_out_data(4);
                elsif (reg_cur_state = d4 and reg_i2c_cmd_r_nw = '1') then
                    pio_i2c_sda <= pi_slave_out_data(3);
                elsif (reg_cur_state = d3 and reg_i2c_cmd_r_nw = '1') then
                    pio_i2c_sda <= pi_slave_out_data(2);
                elsif (reg_cur_state = d2 and reg_i2c_cmd_r_nw = '1') then
                    pio_i2c_sda <= pi_slave_out_data(1);
                elsif (reg_cur_state = d1 and reg_i2c_cmd_r_nw = '1') then
                    pio_i2c_sda <= pi_slave_out_data(0);

                elsif (reg_cur_state = d0) then
                    --data ack reply.
                    if (reg_i2c_cmd_r_nw = '0') then
                        pio_i2c_sda <= '0';
                    else
                    --yield bus for incoming data.
                        pio_i2c_sda <= 'Z';
                    end if;

                elsif (reg_cur_state = d_ack) then
                    --data receive.
                    if (reg_i2c_cmd_r_nw = '0') then
                        pio_i2c_sda <= 'Z';
                    else
                        --data out.
                        pio_i2c_sda <= pi_slave_out_data(7);
                    end if;
                end if;
            else
                pio_i2c_sda <= 'Z';
            end if;--reg_i2c_cmd_addr = pi_slave_addr
        end if;--if (pi_rst_n = '0') then
    end process;

end rtl;
