library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_arith.conv_std_logic_vector;

entity testbench_i2c_test is
end testbench_i2c_test;

architecture stimulus of testbench_i2c_test is 

    constant powerup_time   : time := 200 ns;
    constant reset_time     : time := 800 ns;
    constant start_time     : time := 12 us;

    --DE1 base clock = 50 MHz
    constant base_clock_time : time := 20 ns;

    --i2c normal clock speed 100 KHz
    constant i2c_clock_time : time := 10 us;

    ---https://wiki.nesdev.com/w/index.php/Clock_rate
    --nes cpu clock = 1.789773 MHz
    constant nes_clock_time : time := 558 ns;

    component duper_cartridge
    port (
        pi_reset_n      : in std_logic;
        pi_base_clk     : in std_logic;

        --nes side
        pi_phi2             : in std_logic;
        pi_prg_ce_n         : in std_logic;
        pi_prg_r_nw         : in std_logic;
        pi_prg_addr         : in std_logic_vector(14 downto 0);
        pio_prg_data        : inout std_logic_vector(7 downto 0);
        pi_chr_ce_n         : in std_logic;
        pi_chr_oe_n         : in std_logic;
        pi_chr_we_n         : in std_logic;
        pi_chr_addr         : in std_logic_vector(12 downto 0);
        po_chr_data         : out std_logic_vector(7 downto 0);

        --i2c side
        pi_i2c_scl      : in    std_logic;
        pio_i2c_sda     : inout std_logic;

        po_dbg_cnt          : out std_logic_vector (63 downto 0)
    );
    end component ;

    signal reset_input      : std_logic;
    signal base_clk         : std_logic;

    signal phi2             : std_logic;
    signal prg_ce_n         : std_logic;
    signal prg_r_nw         : std_logic;
    signal prg_addr         : std_logic_vector(14 downto 0);
    signal prg_data         : std_logic_vector(7 downto 0);
    signal chr_ce_n         : std_logic;
    signal chr_oe_n         : std_logic;
    signal chr_we_n         : std_logic;
    signal chr_addr         : std_logic_vector(12 downto 0);
    signal chr_data         : std_logic_vector(7 downto 0);

    signal i2c_scl          : std_logic;
    signal i2c_sda          : std_logic;
    signal dbg_cnt          : std_logic_vector (63 downto 0);
    
    signal rd_data          : std_logic_vector (7 downto 0);
    signal start_scl        : std_logic;

begin

    ---chrrom side disabled..
    chr_ce_n <= 'Z';
    chr_oe_n <= 'Z';
    chr_we_n <= 'Z';
    chr_addr <= (others => 'Z');
    chr_data <= (others => 'Z');

    sim_board : duper_cartridge port map (
    reset_input,
    base_clk,

    phi2,
    prg_ce_n,
    prg_r_nw,
    prg_addr,
    prg_data,

    chr_ce_n,
    chr_oe_n,
    chr_we_n,
    chr_addr,
    chr_data,

    i2c_scl,
    i2c_sda,
    dbg_cnt);

    --- input reset.
    reset_p: process
    begin
        reset_input <= '1';
        wait for powerup_time;

        reset_input <= '0';
        wait for reset_time;

        reset_input <= '1';
        wait;
    end process;

    --- generate base clock.
    clock_p1 : process
    begin
        base_clk <= '1';
        wait for base_clock_time / 2;
        base_clk <= '0';
        wait for base_clock_time / 2;
    end process;

    --- nes clock.
    clock_p2 : process
    begin
        phi2 <= '1';
        wait for nes_clock_time / 2;
        phi2 <= '0';
        wait for nes_clock_time / 2;
    end process;

    --- cpu bus emulation...
    emu_cpu : process

procedure mem_write
(
    addr    : in std_logic_vector (14 downto 0);
    data    : in std_logic_vector (7 downto 0)
) is
begin
    prg_ce_n  <= '0';
    prg_r_nw  <= '0';
    prg_addr  <= addr;
    prg_data  <= data;
end;

procedure mem_read
(
    addr    : in std_logic_vector (14 downto 0)
) is
begin
    prg_ce_n  <= '0';
    prg_r_nw  <= '1';
    prg_addr  <= addr;
    prg_data  <= (others => 'Z');
end;

procedure bus_wait is
begin
    prg_ce_n  <= '1';
    prg_r_nw  <= 'Z';
    prg_addr  <= (others => 'Z');
    prg_data  <= (others => 'Z');
end;

    variable stage_cnt :    integer := 0;
    variable step_cnt :     integer := 0;
    constant bus_cycle : integer := 3;

    begin
        if (stage_cnt = 0) then
            wait for powerup_time + reset_time;
            stage_cnt := stage_cnt + 1;
        elsif (stage_cnt = 1) then
            if (step_cnt <= bus_cycle * 10) then
                if (step_cnt mod bus_cycle = 0) then
                    mem_read (conv_std_logic_vector(16#fff8#, 15));
                else
                    bus_wait;
                end if;
                step_cnt := step_cnt + 1;
            else
                step_cnt := 0;
                stage_cnt := stage_cnt + 1;
            end if;
        else
            stage_cnt := stage_cnt + 1;
        end if;
        wait for nes_clock_time;
    end process;


    --- i2c clock, clock generation under the condition
    scl_p : process
    begin
        if(start_scl = '1') then
            i2c_scl <= '1';
            wait for i2c_clock_time / 2;
            i2c_scl <= '0';
            wait for i2c_clock_time / 2;
        else
            i2c_scl <= '1';
            wait for i2c_clock_time / 2;
            i2c_scl <= '1';
            wait for i2c_clock_time / 2;
        end if;
    end process;

--    --- sda data generation....
--    sda_p : process
--
--procedure output_addr
--(
--    addr    : in std_logic_vector (6 downto 0);
--    rw      : in std_logic
--) is
--begin
--    i2c_sda <= addr(6);
--    wait for i2c_clock_time;
--    i2c_sda <= addr(5);
--    wait for i2c_clock_time;
--    i2c_sda <= addr(4);
--    wait for i2c_clock_time;
--    i2c_sda <= addr(3);
--    wait for i2c_clock_time;
--    i2c_sda <= addr(2);
--    wait for i2c_clock_time;
--    i2c_sda <= addr(1);
--    wait for i2c_clock_time;
--    i2c_sda <= addr(0);
--    wait for i2c_clock_time;
--    i2c_sda <= rw;
--    wait for i2c_clock_time / 2;
--end;
--
--procedure output_data
--(
--    data    : in std_logic_vector (7 downto 0)
--) is
--begin
--    i2c_sda <= data(7);
--    wait for i2c_clock_time;
--    i2c_sda <= data(6);
--    wait for i2c_clock_time;
--    i2c_sda <= data(5);
--    wait for i2c_clock_time;
--    i2c_sda <= data(4);
--    wait for i2c_clock_time;
--    i2c_sda <= data(3);
--    wait for i2c_clock_time;
--    i2c_sda <= data(2);
--    wait for i2c_clock_time;
--    i2c_sda <= data(1);
--    wait for i2c_clock_time;
--    i2c_sda <= data(0);
--    wait for i2c_clock_time / 2;
--end;
--
--procedure ack_wait is
--begin
--    i2c_sda <= 'Z';
--    wait until i2c_sda'event and i2c_sda='0';
--    wait for i2c_clock_time;
--end;
--
--
--procedure input_data is
--begin
--    wait for i2c_clock_time / 2;
--    rd_data(7) <= i2c_sda;
--    wait for i2c_clock_time;
--    rd_data(6) <= i2c_sda;
--    wait for i2c_clock_time;
--    rd_data(5) <= i2c_sda;
--    wait for i2c_clock_time;
--    rd_data(4) <= i2c_sda;
--    wait for i2c_clock_time;
--    rd_data(3) <= i2c_sda;
--    wait for i2c_clock_time;
--    rd_data(2) <= i2c_sda;
--    wait for i2c_clock_time;
--    rd_data(1) <= i2c_sda;
--    wait for i2c_clock_time;
--    rd_data(0) <= i2c_sda;
--    wait for i2c_clock_time / 2;
--end;
--
--procedure ack_respond is
--begin
--    i2c_sda <= '0';
--    wait for i2c_clock_time;
--end;
--
--    begin
--        rd_data <= (others => '0');
--        start_scl <= '0';
--

--        --pullup...
--        i2c_sda <= '1';
--        start_scl <= '1';
--        wait for start_time ;
--
--        --start up seq...
--        i2c_sda <= '0';
--        
--        wait for i2c_clock_time / 2;
--
--        --addr output with write.....
--        --0x44 = 100 0101.
--        output_addr(conv_std_logic_vector(16#44#, 7), '0');
--        --ack wait.
--        ack_wait;
--
--        --addr low
--        wait for i2c_clock_time / 4;
--        output_data(conv_std_logic_vector(16#00#, 8));
--        ack_wait;
--
--        --addr high
--        wait for i2c_clock_time / 4;
--        output_data(conv_std_logic_vector(16#00#, 8));
--        ack_wait;
--
--        --data set
--        wait for i2c_clock_time / 4;
--        output_data(conv_std_logic_vector(16#64#, 8));
--        ack_wait;
--
--        i2c_sda <= '0';
--        start_scl <= '0';
--
--        wait for i2c_clock_time;
--        i2c_sda <= '1';
--
--
--        wait for i2c_clock_time * 4;
--
--        --restart again..
--        i2c_sda <= '0';
--        start_scl <= '1';
--        wait for i2c_clock_time * 1.2;
--        output_addr(conv_std_logic_vector(16#44#, 7), '0');
--        ack_wait;
--
--        --addr low
--        wait for i2c_clock_time / 4;
--        output_data(conv_std_logic_vector(16#00#, 8));
--        ack_wait;
--
--        --addr high
--        wait for i2c_clock_time / 4;
--        output_data(conv_std_logic_vector(16#01#, 8));
--        ack_wait;
--
--        --data set
--        wait for i2c_clock_time / 4;
--        output_data(conv_std_logic_vector(16#75#, 8));
--        ack_wait;
--
--        start_scl <= '0';
--        i2c_sda <= '1';
--
----        --change direction...
----        start_scl <= '0';
----        i2c_sda <= '1';
----
----        wait for i2c_clock_time * 1.5;
----
----        --restart again..
----        i2c_sda <= '0';
----        start_scl <= '1';
----
----        wait for i2c_clock_time * 1.5;
----        wait for i2c_clock_time / 4;
----        output_addr(conv_std_logic_vector(16#44#, 7), '1');
----        ack_wait;
----
----        i2c_sda <= 'Z';
----        input_data;
----        ack_respond;
----        i2c_sda <= 'Z';
----
----        i2c_sda <= 'Z';
----        input_data;
----        ack_respond;
----        i2c_sda <= 'Z';
----
----        i2c_sda <= 'Z';
----        input_data;
----        ack_respond;
----        i2c_sda <= 'Z';
----
----        i2c_sda <= 'Z';
----        input_data;
----        ack_respond;
----        i2c_sda <= 'Z';
--
--        wait;
--
--    end process;

end stimulus;

