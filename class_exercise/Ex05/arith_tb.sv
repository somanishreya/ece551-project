module arith_tb();	

reg [7:0] A,B;			
reg SUB;				
wire [7:0] SUM;	
wire OV;	

/////// Instantiate DUT /////////
arith iDUT(.A(A),.B(B),.SUB(SUB),.SUM(SUM),.OV(OV));

always begin
	//Test1: Two positive add, without overflow
	A=8'd10; B=8'd10; SUB=0;
  	#5
	if (SUM!==8'd20 && OV!=1'b0) begin
    		$display("ERROR: Check the sum & overflow");
		$stop();
	end
  	$display("Two positive add passed without overflow");

	//Test2: Two positive add, with overflow
	#5
	A=8'd64; B=8'd64; SUB=0;
  	#5
	if (SUM!==8'd128 && OV!=1'b1) begin
    		$display("ERROR: Check the sum & overflow");
		$stop();
	end
  	$display("Two positive add passed with overflow");


	//Test3: Two positive sub, without overflow
	#5
	A=8'd64; B=8'd54; SUB=1;
  	#5
	if (SUM!==8'd10 && OV!=1'b0) begin
    		$display("ERROR: Check the sum & overflow");
		$stop();
	end
  	$display("Two positive subtract passed without overflow");

	//Test4: Two positive sub, without overflow
	#5
	A=8'd54; B=8'd64; SUB=1;
  	#5
	if (SUM!==8'd246 && OV!=1'b0) begin
    		$display("ERROR: Check the sum & overflow");
		$stop();
	end
  	$display("Two positive subtract passed without overflow");

	//Test5: Two negative add, with overflow
	#5
	A=8'd128; B=8'd128; SUB=0;
  	#5
	if (SUM!==8'd0 && OV!=1'b1) begin
    		$display("ERROR: Check the sum & overflow");
		$stop();
	end
  	$display("Two negative add passed with overflow");

	//Test6: Two negative add, without overflow
	#5
	A=8'd192; B=8'd192; SUB=0;
  	#5
	if (SUM!==8'd128 && OV!=1'b0) begin
    		$display("ERROR: Check the sum & overflow");
		$stop();
	end
  	$display("Two negative add passed without overflow");

	//Test7: Two negative sub, without overflow
	#5
	A=8'd192; B=8'd192; SUB=1;
  	#5
	if (SUM!==8'd0 && OV!=1'b0) begin
    		$display("ERROR: Check the sum & overflow");
		$stop();
	end
  	$display("Two negative sub passed without overflow");

	//Test8: Positive &  negative sum
	#5
	A=8'd1; B=8'd128; SUB=0;
  	#5
	if (SUM!==8'd129 && OV!=1'b0) begin
    		$display("ERROR: Check the sum & overflow");
		$stop();
	end
  	$display("Positive &  negative sum pass");

	//Test9: Positive &  negative sub
	#5
	A=8'd1; B=8'd128; SUB=1;
  	#5
	if (SUM!==8'd129 && OV!=1'b1) begin
    		$display("ERROR: Check the sum & overflow");
		$stop();
	end
  	$display("Positive &  negative sum pass");



  
	//$display("YAHOO!! all tests passed!\n");
  	$stop();  
end
 
endmodule