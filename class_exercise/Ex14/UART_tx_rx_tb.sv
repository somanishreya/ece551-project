module UART_tx_rx_tb;

  // Clock and reset
  logic clk, rst_n;
  initial clk = 0;
  

  // DUT signals
  logic TX, RX;
  logic trmt, tx_done;
  logic [7:0] tx_data;

  logic clr_rdy, rdy;
  logic [7:0] rx_data;

  // Instantiate Transmitter
  UART_tx tx_inst (
    .clk(clk),
    .rst_n(rst_n),
    .TX(TX),
    .trmt(trmt),
    .tx_data(tx_data),
    .tx_done(tx_done)
  );

  // Instantiate Receiver
  UART_rx rx_inst (
    .clk(clk),
    .rst_n(rst_n),
    .RX(RX),
    .clr_rdy(clr_rdy),
    .rx_data(rx_data),
    .rdy(rdy)
  );

  //  TX to RX
  assign RX = TX;

  // sequence
  initial begin
    $display("Starting UART test...");
    rst_n = 0;
    trmt = 0;
    clr_rdy = 0;
    tx_data = 8'b11010101;

    #25 rst_n = 1;
    #50;

    // Trigger transmission 1
    trmt = 1;
    #20 trmt = 0;

    // Wait for reception to complete
    wait (rdy == 1);
    // Check result
    $display("rdy set");
    #5;
    if (rx_data === tx_data)
      $display("PASS: Received data matches transmitted data: %b", rx_data);
    else begin
      $display("FAIL: Mismatch! Sent: %b, Received: %b", tx_data, rx_data);
      $stop();
    end
    // Clear ready after rdy is set
    clr_rdy = 1;
    #20 clr_rdy = 0;
    #100;

    // Wait for transmission to complete
    wait (tx_done == 1);
    #5;
    $display("tx_done set");
    $display("Transmission 1 complete");
    #100000;

    

    // Trigger transmission 2
    tx_data = 8'b00110011;
    #10;
    trmt = 1;
    #20 trmt = 0;

    // Wait for reception to complete
    wait (rdy == 1);
    // Check result
    $display("rdy set");
    #5;
    if (rx_data === tx_data)
      $display("PASS: Received data matches transmitted data: %b", rx_data);
    else begin
      $display("FAIL: Mismatch! Sent: %b, Received: %b", tx_data, rx_data);
      $stop();
    end
    // Clear ready after some time of rdy is set
    clr_rdy = 1;
    #20 clr_rdy = 0;
    #100;

    // Wait for transmission to complete
    wait (tx_done == 1);
    #5;
    $display("tx_done set");
    $display("Transmission 2 complete");

    
    $display("Two transmission successfull");
    $stop();
  end

always #10 clk = ~clk; // 50 MHz

endmodule