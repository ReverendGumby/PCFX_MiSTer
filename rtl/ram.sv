module ram
  #(parameter AW,
    parameter DW)
  (
   input            CLK,
   input            nCE,
   input            nWE,
   input            nOE,
   input [DW/8-1:0] nBE,
   input [AW-1:0]   A,
   input [DW-1:0]   DI,
   output [DW-1:0]  DO
 );

localparam SIZE = 1 << AW;

bit [DW-1:0]    mem [0:SIZE-1];
bit [DW-1:0]    dor;

always @(posedge CLK) begin
    dor <= mem[A];
end

assign DO = ~(nCE | nOE) ? dor : {DW{1'bz}};

always @(posedge CLK) begin
    for (int i = 0; i < DW/8; i++)
        if (~(nCE | nWE | nBE[i]))
            mem[A][i*8+:8] <= DI[i*8+:8];
end

endmodule
