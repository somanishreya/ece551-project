module A2D_tb();

logic clk;
logic rst_n;
logic nxt;
logic [11:0] lft_load;
logic [11:0] rght_load;
logic [11:0] steer_pot;
logic [11:0] batt;
logic SS_n;
logic SCLK;
logic MOSI;
logic MISO;

A2D_Intf A2D_Intf_inst(
.rst_n(rst_n),
.clk(clk),
.nxt(nxt), //Trigger to start sending out transctions from SPI to A2D
.lft_load(lft_load),
.rght_load(rght_load),
.steer_pot(steer_pot),
.batt(batt),
.SS_n(SS_n), //Active Low Signal - To tell which serf is selected - 
.SCLK(SCLK), // GENERATED SCLK that goes towards Serfs
.MOSI(MOSI), // from Monarch to Serf serial output
.MISO(MISO)  //from Serf to Monarch - Serial input
);

ADC128S ADC128S_inst(
.clk(clk),
.rst_n(rst_n),
.SS_n(SS_n),
.SCLK(SCLK),
.MISO(MISO),
.MOSI(MOSI)
);

always #10 clk = ~clk; //50Mhz clock

initial begin
    clk = 0;
    rst_n = 0;
    repeat (5) @ (posedge clk);
    rst_n = 1;
    repeat (5) @ (posedge clk);

    nxt = 1;
    repeat (5) @ (posedge clk);
    nxt = 0;
    repeat (1000) @ (posedge clk);


    nxt = 1;
    repeat (5) @ (posedge clk);
    nxt = 0;
    repeat (1000) @ (posedge clk);


    nxt = 1;
    repeat (5) @ (posedge clk);
    nxt = 0;
    repeat (1000) @ (posedge clk);


    nxt = 1;
    repeat (5) @ (posedge clk);
    nxt = 0;
    repeat (1000) @ (posedge clk);

    nxt = 1;
    repeat (5) @ (posedge clk);
    nxt = 0;
    repeat (1000) @ (posedge clk);


    $finish;

end

endmodule