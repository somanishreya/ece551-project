//////////////////////////////////////////////////////////////////////////////////////////
////////////////Synching & Edge Detecting a Push Button input/////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////
module PB_release(input clk, input rst_n, input PB, output released);
    reg PB_ff1, PB_ff2;
    reg PB_release_ff;
    always_ff @(posedge clk, negedge rst_n)
      if (!rst_n) begin
        PB_ff1 <= 1;
        PB_ff2 <= 1;
        PB_release_ff <= 1;
      end else begin
        PB_ff1 <= PB;
        PB_ff2 <= PB_ff1;
        PB_release_ff <= PB_ff1 & ~PB_ff2;//third flop for rising edge detector
      end
    assign released = PB_release_ff;
endmodule