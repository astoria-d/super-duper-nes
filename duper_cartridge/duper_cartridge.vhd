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
--        pi_sw          : in std_logic_vector(9 downto 0);
--        pi_btn_n       : in std_logic_vector(3 downto 0);
--        po_led_r       : out std_logic_vector(9 downto 0);
--        po_led_g       : out std_logic_vector(7 downto 0);

        --nes side
        pi_phi2             : in std_logic;
        pi_prg_ce_n         : in std_logic;
        pi_prg_r_nw         : in std_logic;
        pi_prg_addr         : in std_logic_vector(14 downto 0);
        po_prg_data         : out std_logic_vector(7 downto 0);
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

component duper_prg_rom port (  
    pi_base_clk     : in std_logic;
    pi_ce_n         : in std_logic;
    pi_oe_n         : in std_logic;
    pi_we_n         : in std_logic;
    pi_addr         : in std_logic_vector (14 downto 0);
    pio_data        : out std_logic_vector (7 downto 0);

    po_push_fifo    : out std_logic_vector (7 downto 0);
    pi_pop_fifo     : in std_logic_vector (7 downto 0);
    pi_fifo_stat    : in std_logic_vector (7 downto 0)
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

component i2c_eeprom
    generic (abus_size : integer := 16);
    port (
        pi_rst_n        : in std_logic;
        pi_base_clk     : in std_logic;
        pi_bus_xfer     : in std_logic;
        pi_r_nw         : in std_logic;
        pi_bus_ack      : in std_logic;
        po_bus_ack      : out std_logic;
        pi_data         : in std_logic_vector (7 downto 0);
        po_data         : out std_logic_vector (7 downto 0)
    );
end component;

--signal wk_chr_ce_n  : std_logic;
--signal wk_phi2_n        : std_logic;
signal reg_reset_n      : std_logic;
signal reg_chr_addr     : std_logic_vector(11 downto 0);
signal reg_dbg_cnt      : std_logic_vector (63 downto 0);

--2, 4, 8, 16, 32 divide counter.
signal reg_divide_cnt      : std_logic_vector (4 downto 0);

--i2c registers.
signal reg_slave_in_data    : std_logic_vector (7 downto 0);
signal reg_slave_out_data   : std_logic_vector (7 downto 0);
signal reg_slave_status     : std_logic_vector (2 downto 0);
signal reg_slave_addr_ack   : std_logic;

signal reg_nr               : std_logic;
signal reg_to_bbb_fifo      : std_logic_vector (7 downto 0);
signal reg_from_bbb_fifo    : std_logic_vector (7 downto 0);
signal reg_fifo_status      : std_logic_vector (7 downto 0);

begin

--    wk_phi2_n <= not pi_phi2;

    divider_p : process (pi_phi2)
use ieee.std_logic_unsigned.all;
    begin
        if (rising_edge(pi_phi2)) then
            reg_divide_cnt <= reg_divide_cnt + 1;
        end if;
    end process;

    --program rom
    reg_nr <= not pi_prg_r_nw;
    reg_from_bbb_fifo <= "11110000";
    reg_fifo_status <= "11000100";
    prom_inst : duper_prg_rom port map (
        pi_base_clk,
        pi_prg_ce_n,
        reg_nr,
        pi_prg_r_nw,
        pi_prg_addr,
        po_prg_data,
        reg_to_bbb_fifo,
        reg_from_bbb_fifo,
        reg_fifo_status
    );

    --character rom
    crom_inst : chr_rom port map (
        pi_base_clk, 
        pi_chr_ce_n,
        pi_chr_oe_n,
        pi_chr_addr, 
        po_chr_data
    );

    i2c_slave_inst : i2c_slave
    port map (
        pi_reset_n,
        pi_base_clk,
        conv_std_logic_vector(16#44#, 7),
        pi_i2c_scl,
        pio_i2c_sda,
        reg_slave_status,
        reg_slave_in_data,
        reg_slave_out_data
    );

    i2c_eeprom_inst : i2c_eeprom generic map (8)
    port map (
        pi_reset_n,
        pi_base_clk,
        reg_slave_status(0),
        reg_slave_status(2),
        reg_slave_status(1),
        reg_slave_addr_ack,
        reg_slave_in_data,
        reg_slave_out_data
    );

    reset_p : process (pi_base_clk)
use ieee.std_logic_unsigned.all;
    variable cnt1, cnt2 : integer;
    begin
        if (rising_edge(pi_base_clk)) then
            -- case addr is 0x77fc
            if (pi_prg_addr = "111111111111100") then
            -- case addr is 0x77fd
                cnt1 := cnt1 + 1;
            elsif (pi_prg_addr = "111111111111101") then
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
