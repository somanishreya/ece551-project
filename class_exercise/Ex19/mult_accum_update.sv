module mult_accum(clk,clr,en,A,B,accum);

input clk,clr,en;
input [15:0] A,B;
output reg [63:0] accum;

reg [31:0] prod_reg;
reg en_stg2;

wire en_latch;
reg Q_latch1, Q_latch2;
wire gclk1, gclk2;

assign en_latch = ~clk;

////////////////////////////////
////// Latch 1 /////////////////
////////////////////////////////

always @(en_latch or en) begin
    if (en_latch)
        Q_latch1 = en;          // Transparent when enabled
    // else Q holds its value (implicit latch behavior)
end

assign gclk1 = Q_latch1 && clk;


///////////////////////////////////////////
// Generate and flop product if enabled //
/////////////////////////////////////////
always @(posedge gclk1)
    prod_reg <= A*B;

/////////////////////////////////////////////////////
// Pipeline the enable signal to accumulate stage //
///////////////////////////////////////////////////
always_ff @(posedge clk)
    en_stg2 <= en;


////////////////////////////////
////// Latch 2 /////////////////
////////////////////////////////


always @(en_latch or en or clr) begin
    if (en_latch || clr)
        Q_latch2 = en_stg2;          // Transparent when enabled
    // else Q holds its value (implicit latch behavior)
end

assign gclk2 = Q_latch2 && clk;

always @(posedge gclk2)
    if (clr)
      accum <= 64'h0000000000000000;
    else
      accum <= accum + prod_reg;

endmodule
