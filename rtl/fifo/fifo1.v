// Borrowed from www.sunburst-design.com/papers/CummingsSNUG2002SJ_FIFO1.pdf

/* verilator lint_off WIDTHEXPAND */

module fifo1 #(parameter DSIZE=8, parameter ASIZE=4)
  (
   output [DSIZE-1:0] RDATA,
   output reg         WFULL,
   output reg         REMPTY,
   input [DSIZE-1:0]  WDATA,
   input              WINC, WCLK, WRST_N,
   input              RINC, RCLK, RRST_N
   );

wire [ASIZE-1:0] waddr, raddr;
reg  [ASIZE:0]   wptr, rptr, wq2_rptr, rq2_wptr;

//////////////////////////////////////////////////////////////////////
// fifomem

localparam DEPTH = 1 << ASIZE;
reg [DSIZE-1:0] mem [0:DEPTH-1];

assign RDATA = mem[raddr];

always @(posedge WCLK)
  if (WINC && !WFULL)
    mem[waddr] <= WDATA;

//////////////////////////////////////////////////////////////////////
// sync_r2w

reg [ASIZE:0] wq1_rptr;

always @(posedge WCLK or negedge WRST_N)
  if (!WRST_N) begin
    wq2_rptr <= 0;
    wq1_rptr <= 0;
  end
  else begin
    wq2_rptr <= wq1_rptr;
    wq1_rptr <= rptr;
  end

//////////////////////////////////////////////////////////////////////
// sync_w2r

reg [ASIZE:0] rq1_wptr;

always @(posedge RCLK or negedge RRST_N)
  if (!RRST_N) begin
    rq2_wptr <= 0;
    rq1_wptr <= 0;
  end
  else begin
    rq2_wptr <= rq1_wptr;
    rq1_wptr <= wptr;
  end

//////////////////////////////////////////////////////////////////////
// rptr_empty

reg [ASIZE:0] rbin;
wire [ASIZE:0] rgraynext, rbinnext;
wire           rempty_val;

always @(posedge RCLK or negedge RRST_N)
  if (!RRST_N) begin
    rbin <= 0;
    rptr <= 0;
  end
  else begin
    rbin <= rbinnext;
    rptr <= rgraynext;
  end

// Memory read-address pointer (okay to use binary to address memory)
assign raddr = rbin[ASIZE-1:0];

assign rbinnext = rbin + (RINC & ~REMPTY);
assign rgraynext = (rbinnext >> 1) ^ rbinnext;

// FIFO empty when the next rptr == synchronized wptr or on reset
assign rempty_val = (rgraynext == rq2_wptr);

always @(posedge RCLK or negedge RRST_N)
  if (!RRST_N)
    REMPTY <= 1'b1;
  else
    REMPTY <= rempty_val;

//////////////////////////////////////////////////////////////////////
// wptr_full

reg [ASIZE:0] wbin;
wire [ASIZE:0] wgraynext, wbinnext;
wire           wfull_val;

always @(posedge WCLK or negedge WRST_N)
  if (!WRST_N) begin
    wbin <= 0;
    wptr <= 0;
  end
  else begin
    wbin <= wbinnext;
    wptr <= wgraynext;
  end

assign waddr = wbin[ASIZE-1:0];

assign wbinnext = wbin + (WINC & ~WFULL);
assign wgraynext = (wbinnext >> 1) ^ wbinnext;

assign wfull_val = ((wgraynext[ASIZE]     != wq2_rptr[ASIZE]) &&
                    (wgraynext[ASIZE-1]   != wq2_rptr[ASIZE-1]) &&
                    (wgraynext[ASIZE-2:0] == wq2_rptr[ASIZE-2:0]));

always @(posedge WCLK or negedge WRST_N)
  if (!WRST_N)
    WFULL <= 1'b0;
  else
    WFULL <= wfull_val;

endmodule
