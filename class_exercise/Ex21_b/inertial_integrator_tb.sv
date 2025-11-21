module inertial_integrator_tb ();

    logic clk;
    logic rst_n;
    logic vld;              // Valid signal - inputs are used only when the valid signal is high
    logic [15:0] ptch_rt;   // Pitch rate from the gyro
    logic [15:0] AZ;        // Accelerometer's reading over the Z axis
    logic [15:0] ptch;      // Final computed pitch from sensor fusion

    // Instantiating the DUT
    inertial_integrator iDUT (
        .clk(clk),
        .rst_n(rst_n),
        .vld(vld),
        .ptch_rt(ptch_rt),
        .AZ(AZ),
        .ptch(ptch)
    );

    //clk generation - 50MHz 
    always #10 clk = ~clk;   // Time period is 20ns

    initial begin
        clk = 0;

        //reset
        rst_n = 0;
        @ (negedge clk);
        rst_n = 1;

        @ (posedge clk);
        vld = 1;                                // Maintaining vld as high always as we integrate only for valid inputs

        // Inputs 1: Testing for possitive ptch_rt value
        ptch_rt = 16'h1000 + 16'h0050;          
        AZ = 16'h0000;
        repeat (500) @ (posedge clk);           // Maintainig inputs 1 for 500 clocks
                                                // The ptch is expected to trend more and more negative 

        // Inputs 2: Testing for ptch_rt as zero
        ptch_rt = 16'h0050;                     // Setting the value of ptch_rt to the value of PTCH_RT_OFFSET to get a compensated pitch rate of 0 
        repeat (1000) @ (posedge clk);          // Maintainig inputs 2 for 1000 clocks
                                                // The ptch is expected to trend up (slowly back towards 0) - due to AZ reading (fusion)

        // Inputs 3: Testing for negative ptch_rt value
        ptch_rt = 16'h0050 - 16'h1000;          
        repeat (500) @ (posedge clk);           // Maintaining inputs 3 for 500 clock cycles
                                                // The ptch is expected to trend steeply into possitive territory

        // Inputs 4: Zero out ptch again
        ptch_rt = 16'h0050;                     // Setting the value of ptch_rt to the value of PTCH_RT_OFFSET to get a compensated pitch rate of 0 
        repeat (1000) @ (posedge clk);          // Maintainig inputs 4 for 1000 clocks
                                                // The ptch is expected to trend back to zero slowly

        // Inputs 5: AZ altered                                        
        AZ = 16'h0800;                          // Giving an input of AZ 
        repeat (1000) @ (posedge clk);          // Maintainig inputs 5 for 1000 clocks
                                                // Ptch is expected to level off after it gets about to 100, offset is expected to toggle back and forth from -1024 to +1024

        // Inputs 6: Testing when vld is 0
        vld = 0;                                // Setting vld to o
        ptch_rt = 16'h0050 - 16'h1000;          // setting compensated ptch_rt to a negative value
        repeat (1000) @ (posedge clk);          // Maintaining inputs 6 for 1000 clock cycles
                                                // These values of ptch_rt must not be considered - no effect is expected
        vld = 1;                                // Asserting vld back to 1


        $stop();
    end

endmodule