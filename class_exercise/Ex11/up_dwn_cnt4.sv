module up_dwn_cnt4(
    input logic en,
    input logic dwn,
    input logic rst_n,
    input logic clk,
    output reg [3:0] cnt
);

always_ff @(posedge clk, negedge rst_n) begin 
        if (!rst_n)
            cnt <= 4'b0000;
        else if (en) begin
            if (!dwn)
                cnt <= cnt + 4'b0001;
            else 
                cnt <= cnt - 4'b0001;
        end
    end
endmodule