module balance_cntrl
# (parameter fast_sim=1)
(
input clk, rst_n, 
input vld, pwr_up, rider_off,
input logic signed [15:0] ptch,
input logic signed [15:0] ptch_rt,
input logic [11:0] steer_pot,
input logic en_steer,
output logic signed [11:0] lft_spd,
output logic signed [11:0] rght_spd,
output logic too_fast

);

logic signed [11:0] PID_cntrl,
logic [7:0] ss_tmr 

PID #(.fast_sim(fast_sim)) iDUT ( .clk (clk), .rst_n(rst_n), .vld(vld), .pwr_up(pwr_up), .rider_off(rider_off),
           .ptch(ptch), .ptch_rt(ptch_rt), .PID_cntrl(PID_cntrl), ss_tmr(ss_tmr) );

SegwayMath iUUT ( .PID_cntrl(PID_cntrl), .ss_tmr(ss_tmr), .steer_pot(steer_pot), .en_steer(en_steer),
                  .pwr_up(pwr_up), .lft_spd(lft_spd), .rght_spd(rght_spd),.too_fast(too_fast));

endmodule