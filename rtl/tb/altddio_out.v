// Simulation stub for DDR I/O pad
//
// Copyright (c) 2025 David Hunter
//
// This program is GPL licensed. See COPYING for the full license.

// sdram.v uses this to slightly delay the clock output to SDRAM.

module altddio_out
    #(
      parameter extend_oe_disable,
      parameter intended_device_family,
      parameter invert_output,
      parameter lpm_hint,
      parameter lpm_type,
      parameter oe_reg,
      parameter power_up_high,
      parameter width
    )
    (
	 input datain_h,
	 input datain_l,
	 input outclock,
	 output dataout,
	 input aclr,
	 input aset,
	 input oe,
	 input outclocken,
	 input sclr,
	 input sset
);

assign dataout = outclock;

endmodule
