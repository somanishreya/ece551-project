module SegwayMath(
    input logic signed [11:0] PID_cntrl,
    input logic [7:0] ss_tmr,
    input logic [11:0] steer_pot,
    input logic en_steer,
    input logic pwr_up,
    output logic signed [11:0] lft_spd,
    output logic signed [11:0] rght_spd,
    output logic too_fast
);

wire signed [19:0] PID_soft;
wire signed [11:0] PID_ss;
wire signed [12:0] PID_ss_extend;
wire signed [12:0] lft_torque;
wire signed [12:0] rght_torque;
wire [11:0] steer_pot_limit;
wire signed [11:0] steer_pot_sig;
wire signed [11:0] steering_input;
wire signed [12:0] steering_input_extend;
wire signed[12:0] lft_unit;
wire signed [12:0] rght_unit;

localparam MIN_DUTY = 13'h0A8;
localparam LOW_TORQUE_BAND = 7'h2A;
localparam GAIN_MULT = 4'h4;

assign PID_soft = PID_cntrl*($signed({1'b0,ss_tmr}));
assign PID_ss = PID_soft>>>8;


//deciding values of left & right torque- slide 2

assign steer_pot_limit = (steer_pot > 12'hE00) ? 12'hE00 :
                         (steer_pot < 12'h200) ? 12'h200 :
                         steer_pot;

assign steer_pot_sig= $signed(steer_pot_limit)-$signed(12'h7FF);

assign steering_input= (steer_pot_sig>>>3) + (steer_pot_sig>>>4); //3/16 calculation of steer_pot_sig

//assign steering_input = { {3{steer_pot_sig[11]}},steer_pot_sig[11:3]} + { {4{steer_pot_sig[11]}},steer_pot_sig[11:4]} ;
assign steering_input_extend = {steering_input[11],steering_input}; //extending steer_pot to 13 bit to match to output torque bits
assign PID_ss_extend = {PID_ss[11],PID_ss[11:0]}; //extending PID_ss to 13 bits for further addition
assign lft_unit = PID_ss_extend + steering_input_extend ;
assign rght_unit = PID_ss_extend - steering_input_extend ;

assign lft_torque = en_steer ? lft_unit : PID_ss_extend;
assign rght_torque = en_steer ? rght_unit : PID_ss_extend;

//deadzone shaping

wire signed [12:0] left_torque_comp;
wire signed [12:0] right_torque_comp;
wire [12:0] abs_torque_lft;
wire [12:0] abs_torque_rght;
wire signed [12:0] left_torque_inter;
wire signed [12:0] right_torque_inter;
wire signed [12:0] lft_shaped;
wire signed [12:0] rght_shaped;


assign left_torque_comp = lft_torque[12] ? lft_torque - MIN_DUTY : lft_torque + MIN_DUTY;
assign abs_torque_lft = lft_torque[12] ? -lft_torque : lft_torque;                                //getting absoulte value of lft_torque
assign left_torque_inter = (abs_torque_lft > LOW_TORQUE_BAND) ? left_torque_comp : lft_torque * $signed(GAIN_MULT);
assign lft_shaped = pwr_up ? left_torque_inter : 13'h0000;

assign right_torque_comp = rght_torque[12] ? rght_torque - MIN_DUTY : rght_torque + MIN_DUTY;
assign abs_torque_rght = rght_torque[12] ? -rght_torque : rght_torque;                                //getting absoulte value of lft_torque
assign right_torque_inter = (abs_torque_rght > LOW_TORQUE_BAND) ? right_torque_comp : rght_torque * $signed(GAIN_MULT);
assign rght_shaped = pwr_up ? right_torque_inter : 13'h0000;

//final saturation & over speed detect


assign lft_spd = (~lft_shaped[12] & lft_shaped[11]) ? 12'h7FF : 
                 (lft_shaped[12] & ~lft_shaped[11])  ? 12'h800 : 
                 lft_shaped[11:0];

assign rght_spd = (~rght_shaped[12] & rght_shaped[11]) ? 12'h7FF : 
                 (rght_shaped[12] & ~rght_shaped[11])  ? 12'h800 : 
                 rght_shaped[11:0];

assign too_fast = (lft_spd>$signed(12'd1536)) | (rght_spd>$signed(12'd1536));

endmodule