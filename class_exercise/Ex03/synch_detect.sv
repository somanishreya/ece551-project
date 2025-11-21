//Creating a rising edge detector on a asyn input signal
//One additional flop is used to eliminate any metastability
//that can occur because of async input

module synch_detect (
    input  logic asynch_sig_in,
    input  logic clk,
    input  logic rst_n,
    output logic rise_edge
);

    logic sync1_q, sync2_q, sync3_q;
    logic prn;

    assign prn = rst_n; // rst_n as preset for DFFs

    // First synchronizing DFF
    dff d1 (
        .D(asynch_sig_in),
        .clk(clk),
        .Q(sync1_q),
        .PRN(prn)
    );

    // Second synchronizing DFF
    dff d2 (
        .D(sync1_q),
        .clk(clk),
        .Q(sync2_q),
        .PRN(prn)
    );

    // Third DFF for edge detection
    dff d3 (
        .D(sync2_q),
        .clk(clk),
        .Q(sync3_q),
        .PRN(prn)
    );

    // Rising edge detection
    assign rise_edge = sync2_q & ~sync3_q;

endmodule