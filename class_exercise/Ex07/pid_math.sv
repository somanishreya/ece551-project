module pid_math(
input logic signed [15:0] ptch,
input logic signed [15:0] ptch_rt,
input logic signed [17:0] integrator,
output logic signed [11:0] PID_cntrl
);

wire signed [9:0]  ptch_err_sat;
wire signed [12:0] differential_err;
wire signed [14:0] P_term;
wire signed [14:0] I_term;
wire signed [12:0] D_term;
wire signed [15:0] PID_sum;

localparam P_COEFF = 5'h09;


//proportial term
assign ptch_err_sat = (!ptch[15] && |ptch[14:9]) ? 10'h1FF : 
                      (ptch[15] && !( &ptch[14:9])) ? 10'h200 : 
                        ptch[9:0];

assign P_term = ptch_err_sat*$signed(P_COEFF);

//integrator term
assign I_term={{3{integrator[17]}},integrator[17:6]};

//differential term
assign differential_err={{3{ptch_rt[15]}},ptch_rt[15:6]};

assign D_term = ~differential_err+1'b1;


assign PID_sum = {{1{P_term[14]}},P_term[14:0]} + 
                 {{1{I_term[14]}},I_term[14:0]} +
                 {{3{D_term[12]}},D_term[12:0]};

assign PID_cntrl = (!PID_sum[15] && |PID_sum[14:11]) ? 12'h7FF : 
                    (PID_sum[15] && !( &PID_sum[14:11])) ? 12'h800 : 
                    PID_sum[11:0]; 

endmodule