module PWM_tb();

reg clk, rst_n;
reg [10:0] duty;
logic PWM1, PWM2;
logic PWM_synch;
logic ovr_I_blank;

PWM iDUT(.clk(clk),.rst_n(rst_n),.duty(duty),.PWM1(PWM1), .PWM2(PWM2), .PWM_synch(PWM_synch), .ovr_I_blank(ovr_I_blank));

initial begin
    clk = 0;
    rst_n = 0;


    #10 rst_n=1;
    #10 duty = 11'h400;


    #8222;
    duty = 11'h200;

    #8222;

    $stop();
end

always #2 clk = ~clk;

endmodule
