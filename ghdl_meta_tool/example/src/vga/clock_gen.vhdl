library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_bit.all;

use work.vga_common.all;
use work.vga_timing_configurations.all;

entity vga_clock_gen is
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

        output : out vga_component_signal
    );
end entity;

architecture rtl of vga_clock_gen is 

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

    pure function calc_bit_length (x : natural) return natural is
    begin
        if x > 1 then
            return calc_bit_length(x / 2) + 1;
        else
            return 1;
        end if;
    end function;

    subtype vga_state_type is std_logic_vector(3 downto 0);
    constant VGA_STATE_NONE        : vga_state_type := b"0000";
    constant VGA_STATE_VISIABLE    : vga_state_type := b"0001";
    constant VGA_STATE_FRONT_PORCH : vga_state_type := b"0010";
    constant VGA_STATE_SYNC_PULSE  : vga_state_type := b"0100";
    constant VGA_STATE_BACK_PORCH  : vga_state_type := b"1000";
    signal vga_state: vga_state_type := VGA_STATE_NONE;

    constant TOTAL_COUNT : natural := VGA_VISABLE + VGA_FRONT_PORCH + VGA_SYNC_PULSE + VGA_BACK_PORCH;
    constant BITS : natural := calc_bit_length(TOTAL_COUNT);

    signal counter : unsigned(BITS-1 downto 0) := (others => '0');
    signal end_of_frame : std_logic := '0';
    signal clk : std_logic;
begin
    output.visiable <= vga_state(0);
    output.front_proch <= vga_state(1);
    output.sync <= vga_state(2);
    output.back_porch <= vga_state(3);
    output.end_of_frame <= end_of_frame;

    clk_div: clock_divider
        generic map (
            IN_FREQ_MHZ => IN_FREQ_MHZ,
            OUT_FREQ_MHZ => VGA_FREQ_MHZ
        )
        port map (
            clk_in => clk_in,
            clk_out => clk
        );

    clk_out <= clk;

    count_proc: process(clk) begin
        if(rising_edge(clk)) then
            if(counter = (TOTAL_COUNT - 1)) then
                counter <= (others => '0');
            else
                counter <= counter + 1;
            end if;
            
            end_of_frame <= '1' when (counter = TOTAL_COUNT - 1) else '0';
        end if;
    end process;

    

    set_outputs: process(counter) begin

        if(counter > (VGA_VISABLE + VGA_FRONT_PORCH + VGA_SYNC_PULSE - 1)) then 
            vga_state <= VGA_STATE_BACK_PORCH;
        elsif(counter > (VGA_VISABLE + VGA_FRONT_PORCH - 1)) then
            vga_state <= VGA_STATE_SYNC_PULSE;
        elsif(counter > (VGA_VISABLE - 1)) then
            vga_state <= VGA_STATE_FRONT_PORCH;
        else
            vga_state <= VGA_STATE_VISIABLE;
        end if;
    end process;

end architecture;