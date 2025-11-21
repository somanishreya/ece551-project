module balance_cntrl_chk_tb();
logic clk, rst_n;
logic vld;
logic pwr_up, rider_off;
logic [15:0] ptch_rt, ptch;
logic [11:0] steer_pot;
logic en_steer;


logic signed [11:0] lft_spd;
logic signed [11:0] rght_spd;
logic too_fast;

localparam fast_sim = 1'b1;

reg [48:0] stim_mem [0:1499];
reg [24:0] resp_mem [0:1499];

reg [48:0] stim;
reg [24:0] resp;

//////////////////////
// Instantiate DUT //
////////////////////
balance_cntrl #(.fast_sim(fast_sim)) iDUT(.clk(clk),.rst_n(rst_n),.vld(vld),.ptch(ptch),.ptch_rt(ptch_rt),
		 .pwr_up(pwr_up),.rider_off(rider_off),.steer_pot(steer_pot),.en_steer(en_steer),
         .lft_spd(lft_spd),.rght_spd(rght_spd),.too_fast(too_fast));


initial begin
  //// Reading in the hex file ////
  $readmemh("balance_cntrl_stim.hex",stim_mem);
  $readmemh("balance_cntrl_resp.hex",resp_mem);

  force iDUT.ss_tmr = 8'hFF;

  clk = 0;
  rst_n = 0;

  repeat(2) @(negedge clk);
  rst_n = 1; //deassert rst_n

  repeat(2) @(negedge clk);


  //1500 loops, reading from memory & allocating corresponding values
  for(int i = 0;i<1500;i++) begin
    stim = stim_mem[i];

    rst_n = stim[48];
    vld   = stim[47];
    ptch  = stim[46:31];
    ptch_rt = stim[30:15];
    pwr_up = stim [14];
    rider_off = stim[13];
    steer_pot = stim[12:1];
    en_steer = stim[0];

    @(posedge clk);
    #1;

    resp = resp_mem[i];

    if (lft_spd !== resp[24:13]) begin
        $display("Left Speed not as expected at loop %d: lft_spd = 0x%h, expected = 0x%h",i,lft_spd,resp[24:13]);
        @(negedge clk);
        $stop();
    end 
    if (rght_spd !== resp[12:1]) begin
        $display("Right Speed not as expected at loop %d: rght_spd = 0x%h, expected = 0x%h",i,rght_spd,resp[12:1]);
        @(negedge clk);
        $stop();
    end 
    if (too_fast !== resp[0]) begin
        $display("Too fast is not as expected at loop %d: too_fast = %b, expected = %b",i,too_fast, resp[0]);
        @(negedge clk);
        $stop();
    end
  end
  $display("Sucess!");
  $stop();
end

always
  #5 clk = ~clk;
					

endmodule