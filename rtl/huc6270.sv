// Placeholder for HuC6270
//
// Implement enough of the chip to appease the BIOS.
//
// Copyright (c) 2025 David Hunter
//
// This program is GPL licensed. See COPYING for the full license.

module huc6270
    (
     input         CLK,
     input         CE,
     input         RESn,

     input         CSn,
     input         WRn,
     input         RDn,
     input         A2,
     input [15:0]  DI,
     output [15:0] DO,

     output        INT,

     input         PCE,
     input [8:0]   ROW,
     input [8:0]   COL
     );

logic [4:0]     rsel;
logic [8:0]     row, col;

logic [15:0]    dout;
logic           sr_rd;

// 'h00: Status Register
logic           vd;

// 'h05: Control Register
logic [3:0]     ie;

//////////////////////////////////////////////////////////////////////
// Register interface

always @(posedge CLK) if (CE) begin
    if (~RESn) begin
        rsel <= '0;
        ie <= '0;
    end
    else begin
        if (~CSn & ~WRn) begin
            case (A2)
                1'b0: begin
                    rsel <= DI[4:0];
                end
                1'b1: begin
                    case (rsel)
                        5'h05:  begin
                            ie <= DI[3:0];
                        end
                        default: ;
                    endcase
                end                
            endcase
        end
    end
end

always @(posedge CLK) if (CE) begin
    sr_rd <= '0;

    if (~CSn & ~RDn) begin
        sr_rd <= (A2 == 1'b0);
    end
end

always @* begin
    dout = '0;
    case (A2)
        1'b0: begin
            dout[5] = vd;
        end
        1'b1: begin
            case (rsel)
                5'h00:  begin
                    dout[5] = vd;
                end
                default: ;
            endcase
        end
    endcase
end

assign DO = (~CSn & ~RDn) ? dout : '0;


//////////////////////////////////////////////////////////////////////
// Interrupt generation

always @(posedge CLK) if (CE) begin
    if (~RESn) begin
        vd <= '0;
    end
    else begin
        if (PCE & ie[3] & (ROW == 9'd239) & (COL == 9'd0))
            vd <= '1;
        else if (sr_rd & RDn)   // read ended
            vd <= '0;
    end
end

assign INT = vd;

endmodule
