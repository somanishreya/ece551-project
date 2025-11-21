
///Should I have the fast_sim control from the Testbench itself?
module piezoTest(
    input logic clk,
    input logic RST_n,
    input logic en_steer,
    input logic too_fast,
    input logic batt_low,
    output logic piezo,
    output logic piezo_n
);

    logic rst_n;

    //DUT Instantiations
    //piezo drv instantiation
    piezo_drv #(.fast_sim(0))(
    .clk(clk), //50Mhz clock - //Connected to the testbench clock
    .rst_n(rst_n), // connected from the reset synchronizer
    .too_fast(too_fast),
    .batt_low(batt_low),
    .en_steer(en_steer),
    .piezo(piezo),
    .piezo_n(piezo_n)
    );

    //reset synchronizer instantiation
    rst_synch(.RST_n(RST_n),
              .clk(clk), //50Mhz clock - //Connected to the testbench clock
              .rst_n(rst_n)
              ); 

//3 Second

endmodule