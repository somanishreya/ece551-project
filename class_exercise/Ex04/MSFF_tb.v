module MSFF_tb;

reg d_reg, clk;
wire d;
wire q;

assign d = d_reg; // Drive wire d from reg d_reg

MSFF dut (
    .d(d),
    .clk(clk),
    .q(q)
);

reg expected_q;

// Clock generation
initial begin
    clk = 0;
    d_reg = 0;
    expected_q = 1'bx;
end

// Test sequence
initial begin
    $display("Starting MSFF rising edge self-checking testbench...");

    // Test 1
    #2;
    if (q === 1'bx)
        $display("PASS1");
    else begin
        $display("FAIL1");
        $stop();
    end
    

    // Test 2
    @(posedge clk);
    #2;
    expected_q = 0;
    if (q == expected_q)
        $display("PASS2");
    else begin
        $display("FAIL2");
        $stop();
    end

    // Test 3: d=1, after negedge clk
    @(negedge clk);
    d_reg = 1;
    #2; // Wait for propagation
    expected_q = 0;
    if (q == expected_q)
        $display("PASS3");
    else begin
        $display("FAIL3");
        $stop();
    end

    // Test 4
    @(posedge clk);
    #2;
    expected_q = 1;
    if (q == expected_q)
        $display("PASS4");
    else begin
        $display("FAIL4");
        $stop();
    end

    $display("YAHOO!! all tests passed!\n");
    $stop();
end

always
  #5 clk <= ~clk;		// toggle clock every 10 time units
  
endmodule