module latch(d,clk,q);
    input d,clk;
    output reg q; //using reg because q needs to store itself when clk is low

    // always block should be triggered when there is change in clk or d 
    // if only clk is there in senstivity list and d changes, the always block will not be triggered 
    always @(clk or d) begin 
        if (clk) 
            q = d; //replacing non blocking statement here, latch should be immediately updated as d is updated, when clk is high
    end
endmodule

module D_FF_sync_rst(d, clk, rst, q);
    input d, clk, rst;
    output reg q;

    always @(posedge clk) begin
        if (rst)
            q <= 0;
        else
            q <= d;
    end
endmodule

module D_FF_async_rst_en(d, clk, rst_n, en, q);
    input d, clk, en, rst_n;
    output reg q;

    //adding rst_n to sensitivy list, implementation of asynchronous reset
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            q <= 0;
        else if (en)
            q <= d;
    end
endmodule


module SR_FF(S, R, clk, rst_n, q);
    input S, R, clk, rst_n;
    output reg q;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            q <= 0;
        else if (R)
            q <= 0;
        else if (S) //S will be checked only if R is not 1, giving R priority of S
            q <= 1;
    end
endmodule


//always_ff would enforce compiler to implement flop, 
//it will implement sequential only no combinational, no additional latch inference (which can happen in always_comb, always)
//For flip flop it is safe to use always_ff & for combinational is it good to use always_comb
//with proper sensitivity list (clk edge (if required reset)), always_ff will infer a flop

module SR_FF_update(S, R, clk, rst_n, q);
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



