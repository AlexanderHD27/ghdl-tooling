library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_bit.all;

entity tb_clock_emulator is 

end entity;

architecture sim of tb_clock_emulator is

    component clock_emulator is
        generic (
            FREQ_MHZ : integer
        );
        port (
            clk : out std_logic;
            disable : in std_logic
        );
    end component;

    signal output : std_logic;
    signal stop_all: std_logic := '0';

begin

    dut : clock_emulator
        generic map (
            FREQ_MHZ => 450
        )
        port map (
            clk => output,
            disable => stop_all
        );

    process begin
        wait for 10 us;
        stop_all <= '1';
        wait for 100 ns;
        wait;
    end process;

end;