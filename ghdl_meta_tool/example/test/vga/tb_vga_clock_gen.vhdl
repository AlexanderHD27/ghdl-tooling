library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_bit.all;

entity tb_vga_clock_gen is
end entity;

architecture sim of tb_vga_clock_gen is
    component clock_emulator is
        generic (
            FREQ_MHZ : integer
        );
        port (
            clk : out std_logic;
            disable : in std_logic
        );
    end component;

    component vga_clock_gen is
        generic (
            IN_FREQ_MHZ  : real;
            VGA_FREQ_MHZ : real;
    
            VGA_VISABLE     : natural;
            VGA_FRONT_PORCH : natural;
            VGA_SYNC_PULSE  : natural;
            VGA_BACK_PORCH  : natural
        );
        port(
            clk_in  : in std_logic;
            clk_out : out std_logic;
    
            visiable    : out std_logic;
            front_proch : out std_logic;
            sync        : out std_logic;
            back_porch  : out std_logic;
            end_of_frame   : out std_logic
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

    dut: vga_clock_gen
        generic map(
            IN_FREQ_MHZ => 450.0,
            VGA_FREQ_MHZ => 25.175,

            VGA_VISABLE => 640,
            VGA_FRONT_PORCH => 16,
            VGA_SYNC_PULSE => 96,
            VGA_BACK_PORCH => 48
        )
        port map(
            clk_in => clk
        );

end architecture;