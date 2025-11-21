module PID(
input clk, rst_n, 
input vld, pwr_up, rider_off,
input logic signed [15:0] ptch,
input logic signed [15:0] ptch_rt,
output logic signed [11:0] PID_cntrl,
output logic [7:0] ss_tmr 
);

wire signed [9:0]  ptch_err_sat;
wire signed [12:0] differential_err;
wire signed [14:0] P_term;
wire signed [14:0] I_term;
wire signed [12:0] D_term;
wire signed [15:0] PID_sum;
reg signed [17:0] integrator;
wire signed [17:0] ptch_err_sat_extend;
wire signed [17:0] sum_integrator;
wire signed [17:0] integrator_in;
wire ov;

localparam P_COEFF = 5'h09;



////////////////////////////////////////////////////
/////////////////proportial term///////////////////
//////////////////////////////////////////////////

assign ptch_err_sat = (!ptch[15] && |ptch[14:9]) ? 10'h1FF : 
                      (ptch[15] && !( &ptch[14:9])) ? 10'h200 : 
                        ptch[9:0];

assign P_term = ptch_err_sat*$signed(P_COEFF);



////////////////////////////////////////////////////
/////////////////integrator term///////////////////
//////////////////////////////////////////////////

assign ptch_err_sat_extend = {{8{ptch_err_sat[9]}},ptch_err_sat[9:0]};
assign sum_integrator = ptch_err_sat_extend[17:0] + integrator[17:0];
assign ov = (integrator[17] ^ ptch_err_sat_extend[17]) ? 0 : integrator[17] ^ sum_integrator[17];

assign integrator_in = rider_off ? 18'h00000 : 
                       (vld & ~(ov)) ? sum_integrator : 
                       integrator;
 
always_ff @(posedge clk, negedge rst_n) begin
  if (!rst_n)
    integrator <= 18'h00000;
  else
    integrator <= integrator_in;
end

assign I_term={{3{integrator[17]}},integrator[17:6]};


////////////////////////////////////////////////////
/////////////////differential term/////////////////
//////////////////////////////////////////////////

assign differential_err={{3{ptch_rt[15]}},ptch_rt[15:6]};

assign D_term = ~differential_err+1'b1;


assign PID_sum = {{1{P_term[14]}},P_term[14:0]} + 
                 {{1{I_term[14]}},I_term[14:0]} +
                 {{3{D_term[12]}},D_term[12:0]};

assign PID_cntrl = (!PID_sum[15] && |PID_sum[14:11]) ? 12'h7FF : 
                    (PID_sum[15] && !( &PID_sum[14:11])) ? 12'h800 : 
                    PID_sum[11:0]; 


////////////////////////////////////////////////////
/////////////////////ss timer//////////////////////
//////////////////////////////////////////////////

reg [26:0] long_tmr;


always_ff @(posedge clk, negedge rst_n) begin
  if (!rst_n)
    long_tmr <= 27'h0000000;
  else 
    long_tmr <= ~(pwr_up) ? 27'h0000000 :
                &(long_tmr[26:19]) ? long_tmr [26:0] : 
                long_tmr + 1;
end
assign ss_tmr = long_tmr[26:19];

endmodule