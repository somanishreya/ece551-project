module SR_FF(S, R, clk, rst_n, q);
    input S, R, clk, rst_n;
    output reg q;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            q <= 0;
        else if (R)
            q <= 0;
        else if (S) //S will be checked only if R is not 1, giving R priority of S
            q <= 1;
    end
endmodule


module PWM(
    input clk, rst_n,
    input [10:0] duty,
    output reg PWM1, PWM2,
    output PWM_synch,
    output ovr_I_blank
);

reg [10:0] cnt;
localparam NONOVERLAP = 11'h040;

always @(posedge clk, negedge rst_n) begin
    if (!rst_n)
        cnt <= 11'h0 ;
    else 
        cnt <= cnt + 1;
end

assign PWM_synch = ~(|cnt);

logic S_PWM1, S_PWM2;
logic R_PWM1, R_PWM2;

//S_PWM2 set if cnt >=(duty+NONOVERLAP)
//R_PWM2 set if &cnt 
//S_PWM1 set if cnt >=(NONOVERLAP)
//R_PWM1 set if cnt >=duty


always_comb begin
    R_PWM1 = 1'b0;
    R_PWM2 = 1'b0;
    S_PWM1 = 1'b0;
    S_PWM2 = 1'b0;

    if (&cnt)
        R_PWM2 = 1'b1;

    if (cnt >= duty + NONOVERLAP)
        S_PWM2 = 1'b1;

    if (cnt >= duty)
        R_PWM1 = 1'b1;

    if (cnt >= NONOVERLAP)
        S_PWM1 = 1'b1;

end


SR_FF FF1(.S(S_PWM1), .R(R_PWM1), .clk(clk), .rst_n(rst_n), .q(PWM1));
SR_FF FF2(.S(S_PWM2), .R(R_PWM2), .clk(clk), .rst_n(rst_n), .q(PWM2));

localparam BLANK_WIDTH = 8'h80;

assign ovr_I_blank = ((cnt > NONOVERLAP) && (cnt < NONOVERLAP + BLANK_WIDTH)) ||
                     ((cnt > NONOVERLAP + duty) && (cnt < NONOVERLAP + duty + BLANK_WIDTH));

endmodule    