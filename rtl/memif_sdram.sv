// Use external MiSTer SDRAM as memory backing store
//
// Copyright (c) 2025 David Hunter
//
// This program is GPL licensed. See COPYING for the full license.

module memif_sdram
  (
    input         CPU_CLK,
    input         CPU_CE,
    input         CPU_RESn,
    input         CPU_BCYSTn,

    input [19:0]  ROM_A,
    output [15:0] ROM_DO,
    input         ROM_CEn,
    output        ROM_READYn,

    input         SDRAM_CLK,
    output        SDRAM_CLKREF,
    output        SDRAM_RD,
    input         SDRAM_RD_RDY,
    output [24:0] SDRAM_RADDR,
    input [15:0]  SDRAM_DOUT
   );

// SDRAM_CLK is assumed to be N * CPU_CLK, where N > 1.

// With SDRAM_CLK = 100MHz and CPU_CLK/CE = 25MHz, ROM reads take 4
// CPU cycles or 2 wait states. Coincidentally, that's the correct
// timing for PC-FX.

logic rom_start_req;
logic rom_ract = '0;
logic rom_readyn = '1;

logic sdram_rd_d = '0;

assign rom_start_req = ~CPU_BCYSTn & ~ROM_CEn;

always @(posedge SDRAM_CLK) begin
  sdram_rd_d <= SDRAM_RD;

  if (sdram_rd_d & ~SDRAM_RD)
    rom_ract <= '1;
  else if (rom_ract & SDRAM_RD_RDY & ~ROM_READYn)
    rom_ract <= '0;
end

always @(posedge CPU_CLK) if (CPU_CE) begin
  rom_readyn <= ROM_CEn | ~(rom_ract & SDRAM_RD_RDY);
end

assign ROM_DO = SDRAM_DOUT;
assign ROM_READYn = rom_readyn;

assign SDRAM_CLKREF = rom_start_req;
assign SDRAM_RD = ~rom_ract & SDRAM_RD_RDY & rom_start_req;
assign SDRAM_RADDR = {5'b0, ROM_A};

endmodule
