module Auth_blk_tb();

logic clk, rst_n;
logic RX;
logic rider_off;
logic pwr_up;
logic TX;
logic trmt;
logic [7:0] tx_data;
logic tx_done;


Auth_blk auth_tb (.clk(clk), .rst_n(rst_n), .RX(RX), .rider_off(rider_off),
                  .pwr_up(pwr_up));

/// Calling in UART_tx to get the transmitted value of 'S' & 'G' for verification

UART_tx tx_auth_tb (.clk(clk), .rst_n(rst_n), .TX(TX), .trmt(trmt),
                    .tx_data(tx_data), .tx_done(tx_done));



// Tx from UART_tx goes to RX line of Auth_blk
assign RX = TX;


//////////////////////////
//////test start ////////
/////////////////////////
initial begin

    clk = 0;
    rst_n = 0;
    trmt = 0;

    /////////////////////////////////////////////////////
    //////// A wrong transmission check /////////////////
    /////////////////////////////////////////////////////

    tx_data = 8'h30; //state should not change after this transmission

    repeat(2) @(negedge clk);
    //deassert rst_n after 2 clocks
    rst_n = 1'b1;
    @(posedge clk)
    // checking if state is in idle state after rst_n
    if (auth_tb.state != 2'b00) begin
        $display("State should be in IDLE state!");
        @(negedge clk);
        $stop();
    end
    //Starting transmission
    repeat(2) @(negedge clk);
    trmt = 1'b1;
    @(negedge clk);
    trmt = 1'b0;

    @(posedge auth_tb.rx_rdy);
    //$display("rdy set");
    if (auth_tb.state != 2'b00) begin
        $display("State should be in IDLE state!");
        @(negedge clk);
        $stop();
    end
    if (pwr_up !== 1'b0) begin
        $display("It's a wrong transmission, pwr_up shouldnt be high now,pwr_up = %b", pwr_up);
        @(negedge clk);
        $stop();
    end

    if (auth_tb.clr_rdy !== 1'b1) begin
        $display("It's a transmission complete, clr_rdy should be high now");
        @(negedge clk);
        $stop();
    end

    @(posedge tx_done);
    repeat(2) @(posedge clk);


    /////////////////////////////////////////////////////
    //////// Correct transmission check of 'S' //////////
    /////////////////////////////////////////////////////

    tx_data = 8'h47;
    @(negedge clk);
    trmt = 1'b1;
    @(negedge clk);
    trmt = 1'b0;

    @(posedge auth_tb.rx_rdy);
    @(posedge clk);
    //$display("rdy set");
    if (pwr_up !== 1'b1) begin
        $display("It's a correct transmission, pwr_up should be high now");
        @(negedge clk);
        $stop();
    end

    @(posedge tx_done);
    repeat(2) @(posedge clk);


    /////////////////////////////////////////////////////////////
    ///// Correct transmission check of 'G' with ridder off /////
    ////////////////////////////////////////////////////////////

    tx_data = 8'h53;
    rider_off = 1'b0;

    @(negedge clk);
    trmt = 1'b1;
    @(negedge clk);
    trmt = 1'b0;

    @(posedge auth_tb.rx_rdy);
    @(posedge clk);
    
    if (pwr_up !== 1'b1) begin
        $display("Someone must be on the segway, pwr_up should be high now");
        @(negedge clk);
        $stop();
    end

    @(posedge tx_done);
    repeat(10) @(posedge clk);


    /////////////////////////////////////////////
    ////////////  Ridder ON now /////////////////
    /////////////////////////////////////////////

    rider_off = 1'b1;
    @(posedge clk);
    
    if (pwr_up !== 1'b0) begin
        $display("No one is there on Segway now, pwr_up should be low now");
        @(negedge clk);
        $stop();
    end

    repeat(2) @(posedge clk);
    rider_off = 1'b0;


    ///////////////////////////////////////////////////
    ///////////// 2nd section of verification  ////////
    ///////////////////////////////////////////////////

    tx_data = 8'h47;
    @(negedge clk);
    trmt = 1'b1;
    @(negedge clk);
    trmt = 1'b0;

    @(posedge auth_tb.rx_rdy);
    
    /* Below Checks already made above 

    //$display("rdy set");
    //if (auth_tb.state != 2'b01) begin
    //    $display("State should be in Connected state!");
    //    @(negedge clk);
        $stop();
    end
    if (pwr_up !== 1'b1); begin
        $display("It's a correct transmission, pwr_up should be high now");
        @(negedge clk);
        $stop();
    end

    */
    @(posedge tx_done);
    repeat(2) @(posedge clk);

    ////// Going to Disconnected state from Connected state
    repeat(5) @(posedge clk);
    tx_data = 8'h53;
    rider_off = 1'b0;

    @(negedge clk);
    trmt = 1'b1;

    @(posedge auth_tb.rx_rdy);
    trmt = 1'b0;

    @(posedge tx_done);
    repeat(2) @(posedge clk);

    ////// Again in 'S' is tranmitted, it should pwr_up, given ridder_off is 0

    tx_data = 8'h47;
    @(negedge clk);
    trmt = 1'b1;

    @(posedge auth_tb.rx_rdy);
    trmt = 1'b0;
    
    if (pwr_up !== 1'b1) begin
        $display("It's a correct transmission, pwr_up should be high now");
        @(negedge clk);
        $stop();
    end

    @(posedge tx_done);
    repeat(2) @(posedge clk);

    /////// From this point if 'G' is passed & ridder off is 1, it should be back to idle state
    /////// pwr_up should be low

    rider_off = 1'b1;
    tx_data = 8'h53;

    @(negedge clk);
    trmt = 1'b1;
    @(negedge clk);
    trmt = 1'b0;

    @(posedge auth_tb.rx_rdy);
    @(posedge clk);

    if (pwr_up !== 1'b0) begin
        $display(" pwr_up should be low now");
        @(negedge clk);
        $stop();
    end

    @(posedge tx_done);
    repeat(2) @(posedge clk);


    //////////////////////////////////////////
    ////////// All path tested ///////////////
    //////////////////////////////////////////

    $display ("Success, all tests passed!");
    repeat(10) @(posedge clk);
    $stop();

end



//////clock logic/////
always 
    #5 clk = ~clk;


endmodule