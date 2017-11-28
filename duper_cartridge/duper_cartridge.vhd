library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.conv_integer;
use ieee.std_logic_arith.conv_std_logic_vector;
use ieee.std_logic_unsigned.all;

--entity rom_test01 is 
entity duper_cartridge is 
    port (
        pi_reset_n      : in std_logic;
        pi_base_clk     : in std_logic;

        --nes side
        pi_phi2             : in std_logic;

        --prgrom
        pi_prg_ce_n         : in std_logic;
        pi_prg_r_nw         : in std_logic;
        pi_prg_addr         : in std_logic_vector(14 downto 0);
        pio_prg_data        : inout std_logic_vector(7 downto 0);

        --chrrom
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
--end rom_test01;
end duper_cartridge;

--architecture rtl of rom_test01 is
architecture rtl of duper_cartridge is

-------------------------------------------
-------------------------------------------
------------- definitions.... -------------
-------------------------------------------
-------------------------------------------

component synchronizer port (
    pi_rst_n            : in    std_logic;
    pi_base_clk         : in    std_logic;
    pi_async_input      : in    std_logic;
    po_sync_output      : out   std_logic
    );
end component;

component synchronized_vector
    generic (abus_size : integer := 8);
    port (
        pi_rst_n            : in    std_logic;
        pi_base_clk         : in    std_logic;
        pi_async_input      : in    std_logic_vector(abus_size - 1 downto 0);
        po_sync_output      : out   std_logic_vector(abus_size - 1 downto 0)
    );
end component;

component prg_rom port (
    pi_base_clk     : in std_logic;
    pi_ce_n         : in std_logic;
    pi_oe_n         : in std_logic;
    pi_addr         : in std_logic_vector (14 downto 0);
    po_data         : out std_logic_vector (7 downto 0)
    );
end component ;

component chr_rom port (
    pi_base_clk 	: in std_logic;
    pi_ce_n         : in std_logic;
    pi_oe_n         : in std_logic;
    pi_addr         : in std_logic_vector (12 downto 0);
    po_data         : out std_logic_vector (7 downto 0)
    );
end component;

component i2c_slave
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
end component;

component fifo
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
end component;

---firo status register
---bit	
---0	write fifo empty
---1	write fifo full
---2	always 0
---3	always 0
---4	read fifo empty
---5	read fifo full
---6	always 0
---7	always 0
constant wfifo_empty_bit    : integer := 0;
constant wfifo_full_bit     : integer := 1;
constant rfifo_empty_bit    : integer := 4;
constant rfifo_full_bit     : integer := 5;


type duper_state_machine is (
    idle,
    rom_read,
    rom_read_ok,
    fifo_status_read,
    nes_fifo_read,
    nes_fifo_pop,
    nes_fifo_read_ok,
    nes_fifo_write,
    nes_fifo_push,
    nes_fifo_write_ok,
    bbb_fifo_read,
    bbb_fifo_write
    );

-------------------------------------------
-------------------------------------------
------------- declarations... -------------
-------------------------------------------
-------------------------------------------

--synchronized input.
--nes side
signal reg_phi2             : std_logic;
signal reg_prg_ce_n         : std_logic;
signal reg_prg_r_nw         : std_logic;
signal reg_prg_addr         : std_logic_vector(14 downto 0);
signal reg_prg_data_in      : std_logic_vector(7 downto 0);
signal reg_chr_ce_n         : std_logic;
signal reg_chr_oe_n         : std_logic;
signal reg_chr_we_n         : std_logic;
signal reg_chr_addr         : std_logic_vector(12 downto 0);

signal wr_prg_data_out      : std_logic_vector(7 downto 0);
signal reg_prg_data_out     : std_logic_vector(7 downto 0);

--duper state machine..
signal reg_cur_state        : duper_state_machine;
signal reg_next_state       : duper_state_machine;

--prgrom reg
signal reg_prom_oe_n        : std_logic;

--read fifo registers.
signal reg_fifo_ce_n        : std_logic;
signal reg_fifo_oe_n        : std_logic;
signal reg_fifo_we_n        : std_logic;
signal reg_fifo_status      : std_logic_vector (7 downto 0);
signal reg_rd_fifo_data     : std_logic_vector (7 downto 0);

signal tmp_rfifo_ce1 : std_logic;
signal tmp_rfifo_ce2 : std_logic;


signal wr_rd_fifo_empty     : std_logic;
signal wr_rd_fifo_full      : std_logic;
signal wr_rd_fifo_data      : std_logic_vector (7 downto 0);

--i2c registers.
signal reg_slave_out_data   : std_logic_vector (7 downto 0);
signal reg_slave_addr_ack   : std_logic;
signal wr_slave_in_data    : std_logic_vector (7 downto 0);
signal wr_slave_status     : std_logic_vector (2 downto 0);

------------misc regs.
signal reg_reset_n      : std_logic;
signal reg_dbg_cnt      : std_logic_vector (63 downto 0);

--2, 4, 8, 16, 32 divide counter.
signal reg_divide_cnt      : std_logic_vector (4 downto 0);

-------------------------------------------
-------------------------------------------
------------ implementations... -----------
-------------------------------------------
-------------------------------------------


begin

    --async input to be aligned to the base clock...
    sync00 : synchronizer port map (pi_reset_n, pi_base_clk, pi_phi2,        reg_phi2);
    sync01 : synchronizer port map (pi_reset_n, pi_base_clk, pi_prg_ce_n,    reg_prg_ce_n);
    sync02 : synchronizer port map (pi_reset_n, pi_base_clk, pi_prg_r_nw,    reg_prg_r_nw);
    sync03 : synchronizer port map (pi_reset_n, pi_base_clk, pi_chr_ce_n,    reg_chr_ce_n);
    sync04 : synchronizer port map (pi_reset_n, pi_base_clk, pi_chr_oe_n,    reg_chr_oe_n);
    sync05 : synchronizer port map (pi_reset_n, pi_base_clk, pi_chr_we_n,    reg_chr_we_n);

    sync10 : synchronized_vector generic map (15)    port map (pi_reset_n, pi_base_clk, pi_prg_addr,    reg_prg_addr);
    sync11 : synchronized_vector generic map (8)     port map (pi_reset_n, pi_base_clk, pio_prg_data,   reg_prg_data_in);
    sync12 : synchronized_vector generic map (13)    port map (pi_reset_n, pi_base_clk, pi_chr_addr,    reg_chr_addr);

    --base clock synchronized registers...
    reg_p : process (pi_base_clk, pi_reset_n)
    begin
        if (pi_reset_n = '0') then
            reg_prom_oe_n <= '1';
            reg_fifo_status <= "00010001";
            reg_rd_fifo_data <= (others => '0');
            reg_fifo_ce_n <= '1';
            reg_fifo_oe_n <= '1';
            reg_fifo_we_n <= '1';
            tmp_rfifo_ce1 <= '1';
            tmp_rfifo_ce2 <= '1';

        elsif (rising_edge(pi_base_clk)) then
            reg_prom_oe_n <= not reg_prg_r_nw;
            reg_fifo_status(wfifo_empty_bit)    <= '1';
            reg_fifo_status(wfifo_full_bit)     <= '0';
            reg_fifo_status(rfifo_empty_bit)    <= wr_rd_fifo_empty;
            reg_fifo_status(rfifo_full_bit)     <= wr_rd_fifo_full;
            reg_fifo_status(3 downto 2) <= (others => '0');
            reg_fifo_status(7 downto 6) <= (others => '0');
            reg_rd_fifo_data <= wr_rd_fifo_data;

---po_i2c_status(1): '1' = acknowleged, '0' = not acknowleged.
---po_i2c_status(2): '1' = read, '0' = write.
            reg_fifo_we_n <= not (wr_slave_status(1) and not wr_slave_status(2));

            --reg_fifo_ce_n is edge sense signal.
            tmp_rfifo_ce1 <= not (wr_slave_status(1) and not wr_slave_status(2));
            tmp_rfifo_ce2 <= tmp_rfifo_ce1;
            if ((tmp_rfifo_ce1 = '0' and tmp_rfifo_ce2 = '1')) then
                reg_fifo_ce_n <= '0';
            else
                reg_fifo_ce_n <= '1';
            end if;
        end if;
    end process;

    --state transition process...
    set_stat_p : process (pi_reset_n, pi_base_clk)
    begin
        if (pi_reset_n = '0') then
            reg_cur_state <= idle;
        elsif (rising_edge(pi_base_clk)) then
            reg_cur_state <= reg_next_state;
        end if;--if (pi_rst_n = '0') then
    end process;

    --state change to next.
    vac_next_stat_p : process (reg_cur_state, reg_prg_ce_n, reg_prg_r_nw, reg_prg_addr)
    begin
        case reg_cur_state is
            when idle =>
                --rom read 0x7ff9: fifo read.
                if (reg_prg_ce_n = '0' and reg_prg_r_nw = '1' and reg_prg_addr = "111111111111001") then
                    reg_next_state <= nes_fifo_read;

                --rom write 0x7ff9: fifo write.
                elsif (reg_prg_ce_n = '0' and reg_prg_r_nw = '0' and reg_prg_addr = "111111111111001") then
                    reg_next_state <= nes_fifo_write;

                --rom read 0x7ff8: fifo status read.
                elsif (reg_prg_ce_n = '0' and reg_prg_r_nw = '1' and reg_prg_addr = "111111111111000") then
                    reg_next_state <= fifo_status_read;

                --other rom read.
                elsif (reg_prg_ce_n = '0' and reg_prg_r_nw = '1') then
                    reg_next_state <= rom_read;

                else
                    reg_next_state <= idle;
                end if;

            when rom_read =>
                reg_next_state <= rom_read_ok;

            when rom_read_ok =>
                if (reg_prg_ce_n = '0' and reg_prg_r_nw = '1' and reg_prg_addr(14 downto 1) /= "11111111111100") then
                    reg_next_state <= rom_read_ok;
                else
                    reg_next_state <= idle;
                end if;

            when fifo_status_read =>
                if (reg_prg_ce_n = '0' and reg_prg_r_nw = '1' and reg_prg_addr = "111111111111000") then
                    reg_next_state <= fifo_status_read;
                else
                    reg_next_state <= idle;
                end if;

            when nes_fifo_read =>
                reg_next_state <= nes_fifo_pop;

            when nes_fifo_pop =>
                reg_next_state <= nes_fifo_read_ok;

            when nes_fifo_read_ok =>
                reg_next_state <= nes_fifo_read_ok;

            when nes_fifo_write =>
                reg_next_state <= idle;

            when nes_fifo_push =>
                reg_next_state <= idle;

            when nes_fifo_write_ok =>
                reg_next_state <= idle;

            when bbb_fifo_read =>
                reg_next_state <= idle;

            when bbb_fifo_write =>
                reg_next_state <= idle;
        end case;
    end process;

    --prg rom
    pio_prg_data <= reg_prg_data_out;

    set_nes_out_p : process (reg_cur_state)
    begin
        case reg_cur_state is
            when rom_read_ok =>
                reg_prg_data_out <= wr_prg_data_out;

            when fifo_status_read =>
                reg_prg_data_out <= reg_fifo_status;

            when nes_fifo_read_ok =>
                reg_prg_data_out <= wr_rd_fifo_data;

            when others =>
                reg_prg_data_out <= (others => 'Z');
        end case;
    end process;

    prom_inst : prg_rom port map (
        pi_base_clk,
        reg_prg_ce_n,
        reg_prom_oe_n,
        reg_prg_addr,
        wr_prg_data_out
    );

    --i2c incoming fifo.
    rd_fifo_inst : fifo generic map (8)
    port map (
        pi_reset_n,
        pi_base_clk,
        reg_fifo_ce_n,
        reg_fifo_oe_n,
        reg_fifo_we_n,
        wr_slave_in_data,
        wr_rd_fifo_data,
        wr_rd_fifo_empty,
        wr_rd_fifo_full
    );

    --i2c slave
    i2c_slave_inst : i2c_slave
    port map (
        pi_reset_n,
        pi_base_clk,
        conv_std_logic_vector(16#44#, 7),
        pi_i2c_scl,
        pio_i2c_sda,
        wr_slave_status,
        wr_slave_in_data,
        reg_slave_out_data
    );

    --character rom
    crom_inst : chr_rom port map (
        pi_base_clk, 
        reg_chr_ce_n,
        reg_chr_oe_n,
        reg_chr_addr, 
        po_chr_data
    );

    --nes reset signal emulation.
    reset_p : process (pi_base_clk)
use ieee.std_logic_unsigned.all;
    variable cnt1, cnt2 : integer;
    begin
        if (rising_edge(pi_base_clk)) then
            -- case addr is 0x77fc
            if (reg_prg_addr = "111111111111100") then
            -- case addr is 0x77fd
                cnt1 := cnt1 + 1;
            elsif (reg_prg_addr = "111111111111101") then
                cnt2 := cnt2 + 1;
            else
                cnt1 := 0;
                cnt2 := 0;
            end if;

            --condition:
            --reset vector is fetched.
            --cpu address is fixed at the reset vector addr for more than 50 clocks.
            --assume that reset happened.
            if (cnt1 + cnt2 > 50) then
                reg_reset_n <= '0';
            else
                reg_reset_n <= '1';
            end if;
        end if;
    end process;

--------------------------------------------------------------------
--------------------------------------------------------------------
------------------------ misc processes.... ------------------------
--------------------------------------------------------------------
--------------------------------------------------------------------

    divider_p : process (reg_phi2)
use ieee.std_logic_unsigned.all;
    begin
        if (rising_edge(reg_phi2)) then
            reg_divide_cnt <= reg_divide_cnt + 1;
        end if;
    end process;

    po_dbg_cnt <= reg_dbg_cnt;
    deb_cnt_p : process (pi_base_clk, pi_reset_n)
use ieee.std_logic_unsigned.all;
    begin
        if (reg_reset_n = '0') then
            reg_dbg_cnt <= (others => '0');
        elsif (rising_edge(pi_base_clk)) then
            reg_dbg_cnt <= reg_dbg_cnt + 1;
        end if;
    end process;
end rtl;
