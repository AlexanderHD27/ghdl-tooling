library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_bit.all;

entity top_unit is
    port (
        led : out std_logic_vector(7 downto 0);
        sw : in std_logic_vector(7 downto 0);
        btnC : in std_logic;
        btnU : in std_logic
    );
end entity;


architecture rtl of top_unit is
    component lsrf is
        generic (
            BITS : integer
        );
        port (
            clk   : in std_logic;
            rst   : in std_logic;
            seed  : in std_logic_vector(BITS-1 downto 0);
            key   : in std_logic_vector(BITS-1 downto 0);
            state_out : out std_logic_vector(BITS-1 downto 0)
        );
    end component;
begin

    lsrf_unit: lsrf
        generic map (
            BITS => 8
        )
        port map (
            clk   => btnC,
            rst   => btnU,
            seed  => x"01",
            key   => sw
        );
    led <= x"aa";

end architecture;