library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_bit.all;

entity tb_clock_divider is

end entity;

architecture sim of tb_clock_divider is
    component clock_divider is
        generic (
            IN_FREQ_MHZ : real; 
            OUT_FREQ_MHZ : real
        );
        port (
            clk_in : in std_logic;
            clk_out : out std_logic
        );

    end component;

    component clock_emulator is
        generic (
            FREQ_MHZ : integer
        );
        port (
            clk : out std_logic;
            disable : in std_logic
        );
    end component;

    signal clk_in : std_logic;
    signal clk_out : std_logic;
    signal stop_all: std_logic := '0';

begin
    clk_src : clock_emulator
        generic map (
            FREQ_MHZ => 450
        )
        port map (
            clk => clk_in,
            disable => stop_all
        );

    dut : clock_divider
        generic map (
            IN_FREQ_MHZ => 450.0,
            OUT_FREQ_MHZ =>  1.0
        )
        port map (
            clk_in => clk_in,
            clk_out => clk_out
        );

    process begin
        wait for 100 us;
        stop_all <= '1';
        wait;
    end process;

end architecture;