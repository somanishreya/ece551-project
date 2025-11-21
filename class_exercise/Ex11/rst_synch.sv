module rst_synch(
    input logic clk,
    input logic RST_n,
    output logic rst_n
);

logic rst_n_inter;

always_ff @(negedge clk, @negedge RST_n) begin
    if (!RST_n) begin
        rst_n_inter <= 1'b0;
        rst_n <= 1'b0;
    end
    else begin
        rst_n_inter <= 1'b1;
        rst_n <= rst_n_inter;
    end
end
endmodule