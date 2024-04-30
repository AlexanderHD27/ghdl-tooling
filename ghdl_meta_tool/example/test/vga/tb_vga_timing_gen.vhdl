library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_bit.all;

entity tb_vga_timing_gen is
end entity;

architecture sim of tb_vga_timing_gen is
    component clock_emulator is
        generic (
            FREQ_MHZ : integer
        );
        port (
            clk : out std_logic;
            disable : in std_logic
        );
    end component;

    signal clk : std_logic;
begin
    clock_gen: clock_emulator
        generic map (
            FREQ_MHZ => 450
        )
        port map (
            clk => clk,
            disable => '0'
        );


end architecture;