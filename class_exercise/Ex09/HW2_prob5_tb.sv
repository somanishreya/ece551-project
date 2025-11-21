module HW2_prob5_tb();

logic d,clk, q, op;

latch iDUT (.d(d), .clk(clk), .q(q), .op(op));


initial begin
    clk = 0;
    d = 0;
end

initial begin
    @(posedge clk);
    #2 d=1;

    @(negedge clk);
    d=0;
    #2 d=1;

    @(posedge clk);
    d=0;

    @(negedge clk);
    #2 d=1;
    #2 d=0;
    #2 d=1;
    
    
    $stop();
end

always 
#5 clk <= ~clk;

endmodule