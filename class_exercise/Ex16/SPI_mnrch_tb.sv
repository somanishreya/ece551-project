module SPI_mnrch_tb;

  // clock / reset
  logic clk;
  logic rst_n;

  // DUT I/Os
  logic SS_n;
  logic SCLK;
  logic MOSI;
  logic MISO;
  logic wrt;
  logic [15:0] wrt_data;
  logic done;
  logic [15:0] rd_data;
  logic INT;

  // instantiate DUT (ports named per your module)
  SPI_mnrch dut (
    .clk      (clk),
    .rst_n    (rst_n),
    .SS_N     (SS_n),
    .SCLK     (SCLK),
    .MOSI     (MOSI),
    .MISO     (MISO),
    .wrt      (wrt),
    .wrt_data (wrt_data),
    .done     (done),
    .rd_data  (rd_data)
  );

  SPI_iNEMO1 uut(
    .SS_n (SS_n),
    .SCLK (SCLK),
    .MOSI (MOSI),
    .MISO (MISO),
    .INT (INT)
  );

  // clock: 10ns period
  initial begin
    clk = 0;
    rst_n = 0;

    //Test 1: Read
    wrt_data = 16'h8F00; //MSB set for read
    @(negedge clk);
    rst_n = 1'b1;
    @(posedge clk);
    wrt = 1'b1;
    @(posedge clk);
    wrt = 1'b0;

    @(posedge done);
    //@(posedge clk);
    if (rd_data !== 16'h006A) begin
        $display("Read Failed");
        $stop();
    end
    else
        $display("Read Pass");
    
    //Test 2 : Write for INT to go high
    repeat(5) @(posedge clk);
    @(negedge clk);
    rst_n = 1'b0;
    wrt = 1'b1;
    wrt_data = 16'h0D02;
    @(negedge clk);
    rst_n = 1'b1;
    @(negedge clk);
    wrt = 1'b0;
    @(posedge uut.NEMO_setup);
    @(posedge clk);
    @(posedge INT);
    if (INT !== 1'b1) begin
        $display("Write Failed");
        $stop();
    end
    else
        $display("Write Pass, INIT is high");


    //Test 1: Read ptchL
    wrt_data = 16'hA200; //MSB set for read
    @(negedge clk);
    wrt = 1'b1;
    @(negedge clk);
    wrt = 1'b0;

    @(posedge done);
    @(posedge clk);
    if (rd_data !== 16'h0063) begin
        $display("Read Failed");
        $stop();
    end
    if (INT !== 1'b00) begin
        $display("Error: INT should be low");
        $stop();
    end
    repeat(10) @(posedge clk);
    $display("All test passed!");

  
    $stop();
  end

always
  #5 clk = ~clk;

endmodule