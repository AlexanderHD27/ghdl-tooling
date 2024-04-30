library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_bit.all;

package vga_common is
    type vga_component_signal is record
        visiable     : std_logic;
        front_proch  : std_logic;
        sync         : std_logic;
        back_porch   : std_logic;
        end_of_frame : std_logic;
    end record;

    type vga_component_configuration is record
        VISABLE     : natural;
        FRONT_PORCH : natural;
        SYNC_PULSE  : natural;
        BACK_PORCH  : natural;
    end record;

    type vga_signal is record
        v_signal : vga_component_signal;
        h_signal : vga_component_signal;
    end record;

    type vga_configuration is record
        FREQ_HZ : real;
        v_config : vga_component_configuration;
        h_config : vga_component_configuration;
    end record;

end;