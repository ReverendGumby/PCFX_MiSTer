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

    input [20:0]  RAM_A,
    input [31:0]  RAM_DI,
    output [31:0] RAM_DO,
    input         RAM_CEn,
    input         RAM_WEn,
    input [3:0]   RAM_BEn,
    output        RAM_READYn,

    input         SDRAM_CLK,
    output        SDRAM_CLKREF,
    output [24:0] SDRAM_WADDR,
    output [31:0] SDRAM_DIN,
    output [3:0]  SDRAM_BE,
    output        SDRAM_WE,
    input         SDRAM_WE_RDY,
    output        SDRAM_RD,
    input         SDRAM_RD_RDY,
    output [24:0] SDRAM_RADDR,
    input [31:0]  SDRAM_DOUT
   );

// SDRAM_CLK is assumed to be N * CPU_CLK, where N > 1.

// With SDRAM_CLK = 100MHz and CPU_CLK/CE = 25MHz, ROM reads take 4
// CPU cycles or 2 wait states. Coincidentally, that's the correct
// timing for PC-FX.

logic           rom_start_req, ram_start_req, mem_start_req;
logic           ract = '0;
logic           wact = '0;
logic           rom_readyn = '1;
logic           ram_readyn = '1;
logic           mem_readyn;

logic           sdram_clkref;
logic [24:0]    sdram_waddr;
logic [31:0]    sdram_din;
logic [3:0]     sdram_be;
logic           sdram_we;
logic           sdram_rd;
logic [24:0]    sdram_raddr;

logic           sdram_rd_d = '0;
logic           sdram_we_d = '0;

assign rom_start_req = ~CPU_BCYSTn & ~ROM_CEn;
assign ram_start_req = ~CPU_BCYSTn & ~RAM_CEn;
assign mem_start_req = rom_start_req | ram_start_req;

assign mem_readyn = rom_readyn & ram_readyn;

always @(posedge SDRAM_CLK) begin
  sdram_rd_d <= SDRAM_RD;
  sdram_we_d <= SDRAM_WE;

  if (sdram_rd_d & ~SDRAM_RD)
    ract <= '1;
  else if (ract & SDRAM_RD_RDY & ~mem_readyn)
    ract <= '0;

  if (sdram_we_d & ~SDRAM_WE)
    wact <= '1;
  else if (wact & SDRAM_WE_RDY & ~mem_readyn)
    wact <= '0;
end

always @(posedge CPU_CLK) if (CPU_CE) begin
  rom_readyn <= ROM_CEn | ~(ract & SDRAM_RD_RDY);
  ram_readyn <= RAM_CEn | ~((ract & SDRAM_RD_RDY) | (wact & SDRAM_WE_RDY));
end

assign ROM_DO = SDRAM_DOUT[15:0];
assign ROM_READYn = rom_readyn;

assign RAM_DO = SDRAM_DOUT[31:0];
assign RAM_READYn = ram_readyn;

always @* begin
    sdram_waddr = 'X;
    sdram_din = 'X;
    sdram_be = 'X;
    sdram_we = '0;
    sdram_rd = '0;
    sdram_raddr = 'X;
    if (~ROM_CEn) begin
        sdram_rd = ~ract & SDRAM_RD_RDY & rom_start_req;
        sdram_raddr = {5'h00, ROM_A};
        sdram_be = '1;
    end
    else if (~RAM_CEn) begin
        sdram_din = RAM_DI;
        sdram_be = ~RAM_BEn;
        sdram_we = ~wact & SDRAM_WE_RDY & ram_start_req & ~RAM_WEn;
        sdram_rd = ~ract & SDRAM_RD_RDY & ram_start_req & RAM_WEn;
        sdram_raddr = {4'h8, RAM_A};
        sdram_waddr = sdram_raddr;
    end
end

assign SDRAM_CLKREF = mem_start_req;
assign SDRAM_WADDR = sdram_waddr;
assign SDRAM_DIN = sdram_din;
assign SDRAM_BE = sdram_be;
assign SDRAM_WE = sdram_we;
assign SDRAM_RD = sdram_rd;
assign SDRAM_RADDR = sdram_raddr;

endmodule
