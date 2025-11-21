module A2D_test(clk,RST_n,SEL,LED,SCLK,SS_n,MOSI,MISO);

  input clk,RST_n;		// clk and unsynched reset from PB
  input SEL;			// from 2nd PB, cycle through outputs
  input MISO;			// from A2D
  
  output [7:0] LED;
  output SS_n;			// active low slave select to A2D
  output SCLK;			// SCLK to A2D SPI
  output MOSI;
  
  ////////////////////////////////////////////////////////////
  // Declare any needed internal registers (like counters) //
  //////////////////////////////////////////////////////////
  reg [1:0] cnt_2bit;
  reg [18:0] cnt_19bit;
  ///////////////////////////////////////////////////////
  // Declare any needed internal signals as type wire //
  /////////////////////////////////////////////////////
  logic full;
  logic en_2bit;
  logic lft_load;
  logic rght_load;
  logic steer_pot;
  logic batt;
  logic rst_n;
  //////////////////////////////////////////////////
  // Infer 19-bit counter to set conversion rate //
  ////////////////////////////////////////////////
  always @ (posedge clk or negedge rst_n)
    if(!rst_n)
      cnt_19bit <= 0;
    else 
      cnt_19bit <= cnt_19bit + 1;
  assign full = &cnt_19bit;
  assign nxt = full;
  ////////////////////////////////////////////////////////////////
  // Infer 2-bit counter to select which output to map to LEDs //
  //////////////////////////////////////////////////////////////
  always @ (posedge clk or negedge rst_n)
    if(!rst_n)
      cnt_2bit <= 0;
    else if(en_2bit)
      cnt_2bit <= cnt_2bit + 1;
  //////////////////////////////////////////////////////
  // Infer Mux to select which output to map to LEDs //
  //////////////////////////////////////////////////// 
  assign LED =  (cnt_2bit == 2'b00) ? lft_load :
                (cnt_2bit == 2'b01) ? rght_load :
                (cnt_2bit == 2'b10) ? steer_pot :
                (cnt_2bit == 2'b11) ? batt : 8'h0; // TODO : Can I give 0????
  //////////////////////
  // Instantiate DUT //
  ////////////////////  
  A2D_intf iDUT(.clk(clk),.rst_n(rst_n),.nxt(nxt),.lft_load(lft_load),
                .rght_load(rght_load),.steer_pot(steer_pot),.batt(batt),
				.SS_n(SS_n),.SCLK(SCLK),.MOSI(MOSI),.MISO(MISO));
  ///////////////////////////////////////////////
  // Instantiate Push Button release detector //
  /////////////////////////////////////////////
  PB_release iPB(.clk(clk),.rst_n(rst_n),.PB(SEL),.released(en_2bit));
  /////////////////////////////////////
  // Instantiate reset synchronizer //
  ///////////////////////////////////
  rst_synch iRST(.clk(clk),.RST_n(RST_n),.rst_n(rst_n));   
	  
endmodule
  