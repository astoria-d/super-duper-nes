library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_arith.conv_std_logic_vector;
use ieee.std_logic_unsigned.all;


entity nes2bbb_testbench is
end nes2bbb_testbench;

architecture stimulus of nes2bbb_testbench is 

    constant powerup_time   : time := 1500 ns;
    constant reset_time     : time := 1800 ns;

    --DE1 base clock = 50 MHz
    constant base_clock_time : time := 20 ns;

    --i2c normal clock speed 100 KHz
    constant i2c_clock_time : time := 10 us;

    --i2c clock timing..
    constant i2c_clk_0 : std_logic_vector(1 downto 0) := "00";
    constant i2c_clk_1 : std_logic_vector(1 downto 0) := "01";
    constant i2c_clk_2 : std_logic_vector(1 downto 0) := "10";
    constant i2c_clk_3 : std_logic_vector(1 downto 0) := "11";

    ---https://wiki.nesdev.com/w/index.php/Clock_rate
    --nes cpu clock = 1.789773 MHz
    constant nes_clock_time : time := 558 ns;

    constant bus_cycle : integer := 3;


---fifo status register
---bit	
---7	always 0
---6	always 0
---5	read fifo full
---4	read fifo empty
---3	always 0
---2	always 0
---1	write fifo full
---0	write fifo empty
    constant wfifo_empty_bit    : integer := 0;
    constant wfifo_full_bit     : integer := 1;
    constant rfifo_empty_bit    : integer := 4;
    constant rfifo_full_bit     : integer := 5;

    constant i2c_read       : std_logic := '1';
    constant i2c_write      : std_logic := '0';

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

        --bbb gpio
        po_nes_f_full   : out   std_logic;
        po_bbb_f_empty  : out   std_logic;

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
    signal i2c_scl_x4       : std_logic;
    signal i2c_scl_type     : std_logic_vector(1 downto 0);
    signal i2c_sda          : std_logic;

    signal nes_f_full       : std_logic;
    signal bbb_f_empty      : std_logic;

    signal dbg_cnt          : std_logic_vector (63 downto 0);

    signal reg_rom_data     : std_logic_vector(7 downto 0);
    signal reg_bbb_recv     : std_logic_vector (7 downto 0);

    signal start_scl        : std_logic;
    signal step_cnt         : integer range 0 to 65535 := 0;
    signal stage_cnt        : integer range 0 to 65535 := 0;
    signal i2c_step_cnt     : integer range 0 to 65535 := 0;
    signal addr_index       : integer range 0 to 65535 := 0;
    signal data_index       : integer range 0 to 65535 := 0;

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

    nes_f_full,
    bbb_f_empty,

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

    --- phi clock.
    clock_phi : process
    begin
        phi2 <= '1';
        wait for nes_clock_time / 2;
        phi2 <= '0';
        wait for nes_clock_time / 2;
    end process;

    --- i2c base clock.
    clock_i2c_base : process
    begin
        i2c_scl_x4 <= '1';
        wait for i2c_clock_time / 8;
        i2c_scl_x4 <= '0';
        wait for i2c_clock_time / 8;
    end process;

    --- i2c clock.
    clock_i2c : process (reset_input, i2c_scl_x4)
    begin
        if (reset_input = '0') then
            i2c_scl_type <= i2c_clk_0;
            i2c_scl <= '1';
        elsif (rising_edge(i2c_scl_x4)) then
            i2c_scl_type <= i2c_scl_type + 1;

            if(start_scl = '1') then
                if (i2c_scl_type = i2c_clk_0) then
                    i2c_scl <= '1';
                elsif (i2c_scl_type = i2c_clk_2) then
                    i2c_scl <= '0';
                end if;
            else
                i2c_scl <= '1';
            end if;

        end if;
    end process;


    --- cpu bus emulation...
    emu_cpu : process (reset_input, phi2)

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

procedure bus_wait is
begin
    prg_ce_n  <= '1';
    prg_r_nw  <= 'Z';
    prg_addr  <= (others => 'Z');
    prg_data  <= (others => 'Z');
end;

    begin
        if (reset_input = '0') then
            stage_cnt <= 0;
            step_cnt <= 0;
        elsif (rising_edge(phi2)) then

            ---stage 0: initialize....
            if (stage_cnt = 0) then
                if (step_cnt = 10) then
                    stage_cnt <= stage_cnt + 1;
                    step_cnt <= 0;
                else
                    step_cnt <= step_cnt + 1;
                end if;

            ---stage 1: rom write.....
            elsif (stage_cnt = 1) then
                if (step_cnt < bus_cycle * 1000) then
                    if (step_cnt mod bus_cycle = 0) then
                        mem_write (conv_std_logic_vector(16#fff9#, 15), conv_std_logic_vector(16#de#, 8) + step_cnt);
                    else
                        bus_wait;
                    end if;
                    step_cnt <= step_cnt + 1;
                else
                    bus_wait;
                    step_cnt <= 0;
                    stage_cnt <= stage_cnt + 1;
                end if;
            end if;
        end if;
    end process;




    --- i2c bus emulation...
    i2c_cpu : process (reset_input, i2c_scl_x4)

procedure increment_cnt is
begin
    if (i2c_scl_type = i2c_clk_0) then
        i2c_step_cnt <= i2c_step_cnt + 1;
    end if;
end;

procedure start_seq is
begin
    if (i2c_scl_type = i2c_clk_1) then
        i2c_sda <= '0';
    end if;
end;

procedure output_addr
(
    i       : in integer;
    addr    : in std_logic_vector (6 downto 0)
) is
begin
    if (i2c_scl_type = i2c_clk_3) then
        i2c_sda <= addr(i);
    end if;
end;

procedure set_rw
(
    rw      : in std_logic
) is
begin
    if (i2c_scl_type = i2c_clk_3) then
        i2c_sda <= rw;
    end if;
end;

procedure ack_wait is
begin
    if (i2c_scl_type = i2c_clk_3) then
        i2c_sda <= 'Z';
    end if;
end;

procedure send_ack is
begin
    if (i2c_scl_type = i2c_clk_3) then
        i2c_sda <= '0';
    end if;
end;

procedure input_data
(
    i       : in integer
) is
begin
    if (i2c_scl_type = i2c_clk_0) then
        reg_bbb_recv(i) <= i2c_sda;
    end if;
end;

    begin
        if (reset_input = '0') then
            i2c_step_cnt <= 0;
            i2c_sda <= '1';
            start_scl <= '0';
            addr_index <= 0;
            data_index <= 0;

        elsif (rising_edge(i2c_scl_x4)) then

            ---stage 1: i2c read.....
            if (stage_cnt = 1) then
                increment_cnt;

                if (i2c_step_cnt < 3) then
                    start_scl <= '1';

                elsif (i2c_step_cnt = 3) then
                    addr_index <= i2c_step_cnt + 1;
                elsif (i2c_step_cnt = addr_index) then
                    --start up seq...
                    start_seq;

                    --set i2c addr...
                    --addr output with write.....
                    --0x44 = 100 0101.
                    output_addr(6 - i2c_step_cnt + addr_index, conv_std_logic_vector(16#44#, 7));

                elsif (i2c_step_cnt <= addr_index + 6) then
                    output_addr(6 - i2c_step_cnt + addr_index, conv_std_logic_vector(16#44#, 7));

                elsif (i2c_step_cnt = addr_index + 7) then
                    set_rw(i2c_read);

                elsif (i2c_step_cnt = addr_index + 8) then
                    --ack wait...
                    ack_wait;
                    data_index <= i2c_step_cnt + 1;

                elsif (i2c_step_cnt < data_index + 8) then
                    input_data(7 - i2c_step_cnt + data_index);

                elsif (i2c_step_cnt = data_index + 8) then
                    send_ack;

                end if;

            end if;
        end if;
    end process;

end stimulus;

