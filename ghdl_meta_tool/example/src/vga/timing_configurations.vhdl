use work.vga_common.vga_configuration;

package vga_timing_configurations is
    constant VGA_640x350_70Hz : vga_configuration := (
        FREQ_HZ => 70.0,
        v_config => (
            VISABLE     => 350,
            FRONT_PORCH => 37,
            SYNC_PULSE  => 2,
            BACK_PORCH  => 60
        ),
        h_config => (
            VISABLE     => 640,
            FRONT_PORCH => 16,
            SYNC_PULSE  => 96,
            BACK_PORCH  => 48
        )
    );

    constant VGA_800x600_56Hz : vga_configuration := (
        FREQ_HZ => 56.0,
        v_config => (
            VISABLE     => 600,
            FRONT_PORCH => 1,
            SYNC_PULSE  => 2,
            BACK_PORCH  => 22
        ),
        h_config => (
            VISABLE     => 800,
            FRONT_PORCH => 24,
            SYNC_PULSE  => 72,
            BACK_PORCH  => 128
        )
    );
    
end package;