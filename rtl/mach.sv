module mach
  (
   input         CLK,
   input         CE,
   input         RESn,

   output [31:0] A
   );

logic [31:0]    dut_ia, dut_da;
logic [31:0]    dut_id;
logic           dut_ireq, dut_iack;
wire [31:0]     dut_dd_i, dut_dd_o;
wire [1:0]      dut_dbc;
wire [3:0]      dut_dbe;
wire            dut_dwr;
wire            dut_dmrq;
wire [1:0]      dut_dst;
wire            dut_dreq, dut_dack;

wire [31:0]     mem_a;
wor [31:0]      mem_d_i;
wire [31:0]     mem_d_o;
wire [3:0]      mem_ben;
wire            mem_dan;
wire            mem_mrqn;
wire            mem_rw;
wire            mem_bcystn;
wor             mem_readyn;
wand            mem_szrqn;

int             rom_ws, rom_dw;
logic           rom_cen;
logic [31:0]    rom_do;

initial begin
    $timeformat(-9, 0, " ns", 1);

    $dumpfile("bios_tb.vcd");
    $dumpvars();
end

v810_exec dut
  (
   .RESn(RESn),
   .CLK(CLK),
   .CE(CE),

   .IA(dut_ia),
   .ID(dut_id),
   .IREQ(dut_ireq),
   .IACK(dut_iack),

   .DA(dut_da),
   .DD_I(dut_dd_i),
   .DD_O(dut_dd_o),
   .DBC(dut_dbc),
   .DBE(dut_dbe),
   .DWR(dut_dwr),
   .DMRQ(dut_dmrq),
   .DST(dut_dst),
   .DREQ(dut_dreq),
   .DACK(dut_dack),

   .ST()
   );

v810_mem dut_mem
  (
   .RESn(RESn),
   .CLK(CLK),
   .CE(CE),

   .EUDA(dut_da),
   .EUDD_I(dut_dd_i),
   .EUDD_O(dut_dd_o),
   .EUDBC(dut_dbc),
   .EUDBE(dut_dbe),
   .EUDWR(dut_dwr),
   .EUDMRQ(dut_dmrq),
   .EUDST(dut_dst),
   .EUDREQ(dut_dreq),
   .EUDACK(dut_dack),

   .EUIA(dut_ia),
   .EUID(dut_id),
   .EUIREQ(dut_ireq),
   .EUIACK(dut_iack),

   .A(mem_a),
   .D_I(mem_d_i),
   .D_O(mem_d_o),
   .BEn(mem_ben),
   .DAn(mem_dan),
   .MRQn(mem_mrqn),
   .RW(mem_rw),
   .BCYSTn(mem_bcystn),
   .READYn(mem_readyn),
   .SZRQn(mem_szrqn)
   );

assign mem_d_i = '0;
assign mem_readyn = '0;
assign mem_szrqn = '1;

data_bus_resizer rom_dbr
  (
   .WS(rom_ws),
   .DW(rom_dw),
   .CLK(CLK),
   .CE(CE),
   .CTLR_DAn(mem_dan),
   .CTLR_BEn(mem_ben),
   .CTLR_READYn(mem_readyn),
   .CTLR_SZRQn(mem_szrqn),
   .CTLR_DI(mem_d_i),
   .CTLR_DO(),
   .MEM_nCE(rom_cen),
   .MEM_DI(),
   .MEM_DO(rom_do)
   );

ram #(4, 32) rombios
  (
   .CLK(CLK),
   .nCE(rom_cen),
   .nWE('1),
   .nOE('0),
   .nBE(mem_ben),
   .A(mem_a[5:2]),
   .DI('Z),
   .DO(rom_do)
   );

ram #(4, 32) dmem
  (
   .CLK(CLK),
   .nCE(ram_cen),
   .nWE(mem_rw),
   .nOE(~mem_rw),
   .nBE(mem_ben),
   .A(mem_a[5:2]),
   .DI(mem_d_o),
   .DO(mem_d_i)
   );

assign ram_cen = ~(~mem_mrqn & ~mem_a[31]);
assign rom_cen = ~(~mem_mrqn & (mem_a[31:20] == 12'hFFF));

initial #0 begin
    rom_ws = 0;
    rom_dw = 16;
    //rombios.load_hex16("pcfx.rom.hex");
end

assign A = mem_a;

endmodule
