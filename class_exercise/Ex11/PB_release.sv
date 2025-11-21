module PB_release (
    input  logic PB,
    input  logic clk,
    input  logic rst_n,
    output logic released
);

    logic sync1_q, sync2_q, sync3_q;
    logic prn;

    assign prn = rst_n; // rst_n as preset for DFFs

    // First synchronizing DFF
    dff d1 (
        .D(PB),
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
    assign released = sync2_q & ~sync3_q;

endmodule