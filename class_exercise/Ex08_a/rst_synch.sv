module rst_synch(
    input clk,
    input rst_n,
    output rst_n
);

wire rst_n_inter;

always @(negedge clk, negedge RST_n)
    if (RST_n)
        rst_n <= 0;
        rst_n_inter <= 0;
    else 
        rst_n_inter <= 0;
        rst_n <= rst_n_inter;
endmodule