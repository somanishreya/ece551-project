///Should I have the fast_sim control from the Testbench itself?
module piezoTest_tb();
    logic clk;
    logic en_steer;
    logic too_fast;
    logic batt_low;
    logic piezo;
    logic piezo_n;
    logic rst_n;

    //DUT Instantiations
    //piezo drv instantiation
    piezo_drv #(.fast_sim(1)) dut(
    .clk(clk), //50Mhz clock - //Connected to the testbench clock
    .rst_n(rst_n), // connected from the reset synchronizer
    .too_fast(too_fast),
    .batt_low(batt_low),
    .en_steer(en_steer),
    .piezo(piezo),
    .piezo_n(piezo_n)
    );

    always #10 clk = ~clk; //50 Mhz Clock

    initial begin
        clk = 0;
        rst_n = 0;
        @(negedge clk);
        rst_n = 1;

        en_steer = 0;
        too_fast = 1;
        batt_low = 0;

        repeat (1000000000) @(posedge clk);

        $finish;
    end

endmodule