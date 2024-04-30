library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_bit.all;

use work.vga_common.all;
use work.vga_timing_configurations.all;

entity vga_timing_gen is
    generic (
        INPUT_CLK :  real
    );
    port(
        clk : std_logic;
        output : vga_signal
    );
end entity;

architecture rtl of vga_timing_gen is
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
begin

    

end architecture;