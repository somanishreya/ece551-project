module SegwayMath_tb();

logic signed [11:0] PID_cntrl;
logic [7:0] ss_tmr;
logic [11:0] steer_pot;
logic en_steer;
logic pwr_up;
logic signed [11:0] lft_spd;
logic signed [11:0] rght_spd;
logic too_fast;

///////// Instantiate DUT /////////
SegwayMath iDUT(.PID_cntrl(PID_cntrl),.ss_tmr(ss_tmr),
              .steer_pot(steer_pot), .en_steer(en_steer),
              .pwr_up(pwr_up),.lft_spd(lft_spd),
              .rght_spd(rght_spd),.too_fast(too_fast)
              );

initial begin
    PID_cntrl = 12'h5FF;
    ss_tmr = 8'h00;
    en_steer = 0;
    pwr_up = 1;

    repeat(255) begin
        #1;
        ss_tmr = ss_tmr + 8'h01;
    end


    //PID cntrl from 12'h5FF to 12'hE00
    repeat(2047) begin
        #1;
        PID_cntrl = PID_cntrl - 12'h001;
    end
    $stop();
end
endmodule