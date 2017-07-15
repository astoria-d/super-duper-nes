library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity testbench_i2c_test is
end testbench_i2c_test;

architecture stimulus of testbench_i2c_test is 

    constant powerup_time   : time := 2 us;
    constant reset_time     : time := 890 ns;

    constant start_time     : time := 12 us;

    ---clock frequency = 21,477,270 (21 MHz)
    --constant base_clock_time : time := 46 ns;

    --DE1 base clock = 50 MHz
    constant base_clock_time : time := 20 ns;

    --i2c normal clock speed 100 KHz
    constant i2c_clock_time : time := 10 us;

    constant test_addr1 : std_logic_vector(6 downto 0) := "0101100";

    component i2c_test 
    port (
        pi_base_clk     : in    std_logic;
        pi_reset_n      : in    std_logic;
        pi_key          : in    std_logic_vector(3 downto 0);
        pi_sw           : in    std_logic_vector(9 downto 0);
        po_led          : out   std_logic_vector(9 downto 0);

        pi_i2c_scl      : in    std_logic;
        pio_i2c_sda     : inout std_logic;

        po_dbg_cnt          : out std_logic_vector (63 downto 0)
         );
    end component;

    signal base_clk         : std_logic;
    signal reset_input      : std_logic;
    signal key              : std_logic_vector(3 downto 0);
    signal sw               : std_logic_vector(9 downto 0);
    signal led              : std_logic_vector(9 downto 0);
    signal i2c_scl          : std_logic;
    signal i2c_sda          : std_logic;
    signal dbg_cnt          : std_logic_vector (63 downto 0);

begin


    sim_board : i2c_test port map (
    base_clk, 
    reset_input, 
    key,
    sw,
    led,
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
    clock_p: process
    begin
        base_clk <= '1';
        wait for base_clock_time / 2;
        base_clk <= '0';
        wait for base_clock_time / 2;
    end process;


    --- step1. start seq.
    start_p1 : process

procedure output_addr 
(
    addr    : in std_logic_vector (6 downto 0);
    rw      : in std_logic
) is
begin
    i2c_sda <= addr(6);
    wait for i2c_clock_time;
    i2c_sda <= addr(5);
    wait for i2c_clock_time;
    i2c_sda <= addr(4);
    wait for i2c_clock_time;
    i2c_sda <= addr(3);
    wait for i2c_clock_time;
    i2c_sda <= addr(2);
    wait for i2c_clock_time;
    i2c_sda <= addr(1);
    wait for i2c_clock_time;
    i2c_sda <= addr(0);
    wait for i2c_clock_time;
    i2c_sda <= rw;
    wait for i2c_clock_time;
end;

    begin
        --pullup...
        i2c_sda <= '1';
        wait for start_time ;

        --start up seq...
        i2c_sda <= '0';
        
        wait for i2c_clock_time / 2;

        --addr output with write.....
        output_addr(test_addr1, '1');

        --ack wait.
        i2c_sda <= 'Z';
        wait until i2c_sda'event and i2c_sda='0' for i2c_clock_time * 10;


        --stop seq...
        wait for i2c_clock_time;
        i2c_sda <= '0';
        wait for i2c_clock_time / 2;
        i2c_sda <= '1';
        wait;
    end process;

    start_p2 : process
    begin
            i2c_scl <= '1';
            wait for i2c_clock_time / 2;
            i2c_scl <= '0';
            wait for i2c_clock_time / 2;
    end process;

end stimulus;

