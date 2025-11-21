module saturate_tb();	

reg [15:0] unsigned_err_test;
reg [9:0] unsigned_err_sat_test;
reg [15:0] signed_err_test;
reg [9:0] signed_err_sat_test;
reg [9:0] signed_D_diff_test;
reg [6:0] signed_D_diff_sat_test;	

/////// Instantiate DUT /////////
saturate iDUT(.unsigned_err(unsigned_err_test),.unsigned_err_sat(unsigned_err_sat_test),
              .signed_err(signed_err_test), .signed_err_sat(signed_err_sat_test),
              .signed_D_diff(signed_D_diff_test), .signed_D_diff_sat(signed_D_diff_sat_test)
);

always begin
	//Test1: Max negative of all
	unsigned_err_test=16'h8000; signed_err_test=16'h8000; signed_D_diff_test=10'h200;
  	#5
    $display("TEST 1");
	if (unsigned_err_sat_test != 10'h3FF) begin
    		$display("ERROR: unsigned_err_sat FAIL");
		$stop();
	end
    if (signed_err_sat_test != 10'h200 ) begin
    		$display("ERROR: signed_err_sat FAIL");
		$stop();
	end
    if (signed_D_diff_sat_test != 7'h40) begin
    		$display("ERROR: Check the sum & overflow");
		$stop();
	end

    //Test2: Max positive of all
	unsigned_err_test=16'h100; signed_err_test=16'h40; signed_D_diff_test=10'h100;
  	#5
    $display("TEST 2");
	if (unsigned_err_sat_test != 10'h100) begin
    		$display("ERROR: unsigned_err_sat FAIL");
		$stop();
	end
    if (signed_err_sat_test != 10'h40 ) begin
    		$display("ERROR: signed_err_sat FAIL");
		$stop();
	end
    if (signed_D_diff_sat_test != 7'h3F) begin
    		$display("ERROR: Check the sum & overflow");
		$stop();
	end

    //Test3: Max positive of all
	unsigned_err_test=16'h100; signed_err_test=16'h100; signed_D_diff_test=10'h10;
  	#5
    $display("TEST 3");
	if (unsigned_err_sat_test != 10'h100) begin
    		$display("ERROR: unsigned_err_sat FAIL");
		$stop();
	end
    if (signed_err_sat_test != 10'h100 ) begin
    		$display("ERROR: signed_err_sat FAIL");
		$stop();
	end
    if (signed_D_diff_sat_test != 7'h10) begin
    		$display("ERROR: Check the sum & overflow");
		$stop();
	end

    //Test4
	signed_err_test=16'hFF80; signed_D_diff_test=10'h3F0;
  	#5
    $display("TEST 4");
    if (signed_err_sat_test != 10'h380 ) begin
    		$display("ERROR: signed_err_sat FAIL");
		$stop();
	end
    if (signed_D_diff_sat_test != 7'h70) begin
    		$display("ERROR: Check the sum & overflow");
		$stop();
	end

	$display("YAHOO!! all tests passed!\n");
  	$stop();  
end
 
endmodule