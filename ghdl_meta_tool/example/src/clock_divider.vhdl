library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_bit.all;
use ieee.math_real.all;

entity clock_divider is
    generic (
        IN_FREQ_MHZ : real; 
        OUT_FREQ_MHZ : real
    );
    port (
        clk_in : in std_logic;
        clk_out : out std_logic
    );
end entity;

architecture rtl of clock_divider is
    pure function calc_bit_length (x : natural) return natural is
    begin
        if x > 1 then
            return calc_bit_length(x / 2) + 1;
        else
            return 1;
        end if;
    end function;

    constant MAX_COUNT : natural := natural(ceil((IN_FREQ_MHZ/OUT_FREQ_MHZ)) / 2.0);
    constant BITS : natural := calc_bit_length(MAX_COUNT);

    signal out_reg : std_logic := '0';
    signal counter : unsigned(BITS-1 downto 0) := (others => '0');
begin
    clk_out <= out_reg;

    process (clk_in) begin
        if(rising_edge(clk_in)) then
            if(counter = (MAX_COUNT - 1)) then
                counter <= (others => '0');
                out_reg <= not out_reg;
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;

end architecture;