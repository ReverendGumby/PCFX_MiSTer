
module mycore
(
	input         sys_clk,
	input         reset,
	
    input         cpu_clk,

	input         pal,
	input         scandouble,

	output reg    ce_pix,

	output reg    HBlank,
	output reg    HSync,
	output reg    VBlank,
	output reg    VSync,

	output  [7:0] R,
	output  [7:0] G,
	output  [7:0] B
);

reg         cpu_ce;
reg [31:0]  a;

reg   [9:0] hc;
reg   [9:0] vc;
reg   [9:0] vvc;
reg [31:0]  pix;

initial cpu_ce = 0;

always @(posedge cpu_clk) begin
  cpu_ce <= ~cpu_ce;
  reset_cpu <= reset | VBlank;
end

mach mach
  (
   .CLK(cpu_clk),
   .CE(cpu_ce),
   .RESn(~reset_cpu),

   .A(a)
   );

always @(posedge sys_clk) begin
	if(scandouble) ce_pix <= 1;
		else ce_pix <= ~ce_pix;

	if(reset) begin
		hc <= 0;
		vc <= 0;
	end
	else if(ce_pix) begin
		if(hc == 637) begin
			hc <= 0;
			if(vc == (pal ? (scandouble ? 623 : 311) : (scandouble ? 523 : 261))) begin 
				vc <= 0;
				vvc <= vvc + 9'd6;
			end else begin
				vc <= vc + 1'd1;
			end
		end else begin
			hc <= hc + 1'd1;
		end
	end
end

always @(posedge sys_clk) begin
	if (hc == 529) HBlank <= 1;
		else if (hc == 0) HBlank <= 0;

	if (hc == 544) begin
		HSync <= 1;

		if(pal) begin
			if(vc == (scandouble ? 609 : 304)) VSync <= 1;
				else if (vc == (scandouble ? 617 : 308)) VSync <= 0;

			if(vc == (scandouble ? 601 : 300)) VBlank <= 1;
				else if (vc == 0) VBlank <= 0;
		end
		else begin
			if(vc == (scandouble ? 490 : 245)) VSync <= 1;
				else if (vc == (scandouble ? 496 : 248)) VSync <= 0;

			if(vc == (scandouble ? 480 : 240)) VBlank <= 1;
				else if (vc == 0) VBlank <= 0;
		end
	end
	
	if (hc == 590) HSync <= 0;
end

always @(posedge sys_clk) begin
  pix <= a;
end

assign R = pix[31:24];
assign G = pix[15:8];
assign B = pix[7:0];

endmodule
