module UART_tx_tb();

  // Testbench signals
  logic clk, rst_n;
  logic trmt;
  logic [7:0] tx_data;
  logic TX;
  logic tx_done;

  UART_tx dut (
    .clk(clk),
    .rst_n(rst_n),
    .trmt(trmt),
    .tx_data(tx_data),
    .TX(TX),
    .tx_done(tx_done));


initial begin
    clk = 0;
    #5 rst_n = 0;
    trmt = 0;
    tx_data = 8'b10101010;

    // Reset pulse
    #25 rst_n = 1;


    // Wait a few cycles
    #50;

    // Trigger transmission
    trmt = 1;
    #20 trmt = 0; // one-cycle pulse

    // Wait for transmission to complete
    wait (tx_done == 1);
    $display("Transmission complete at time %t", $time);

    // Hold for a few more cycles
    tx_data = 8'b11101011;
    #10000;
    // Trigger transmission
    trmt = 1;
    #20 trmt = 0; // one-cycle pulse
    wait (tx_done == 1);
    $display("Transmission complete at time %t", $time);
    #10000;

    $stop();
end


always #10 clk = ~clk;

endmodule