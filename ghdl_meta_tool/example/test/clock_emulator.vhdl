library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_bit.all;

entity clock_emulator is
    generic (
        FREQ_MHZ : integer
    );
    port (
        clk : out std_logic;
        disable : in std_logic
    );
end entity;

architecture sim of clock_emulator is
    constant half_period : time := (0.5/(Real(FREQ_MHZ) * 1_000_000.0)) * 1_000_000_000 ns; 
    signal reg : std_logic := '0';
begin
    clk <= reg;

    process begin
        while not disable loop
            wait for half_period;
            reg <= '1';
            wait for half_period;
            reg <= '0';
        end loop;
        wait;
    end process;
end architecture;