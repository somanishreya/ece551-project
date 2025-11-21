module pid_math_tb();

logic signed [15:0] ptch;
logic signed [15:0] ptch_rt;
logic signed [17:0] integrator;
logic signed [11:0] PID_cntrl;

/////// Instantiate DUT /////////
pid_math iDUT(.ptch(ptch),.ptch_rt(ptch_rt),
              .integrator(integrator), .PID_cntrl(PID_cntrl));

initial begin
    ptch = 16'hFF00;
    ptch_rt = 16'h0FFF;
    integrator = 18'h3C000;

    repeat(64) begin
    ptch = ptch + 16'h0001;
    ptch_rt = ptch_rt - 16'h0100;
    integrator = integrator + 18'h00080;
    #2;
    end

    repeat(64) begin
    ptch = ptch + 16'h0001;
    ptch_rt = ptch_rt + 16'h0100;
    integrator = integrator + 18'h00080;
    #2;
    end

    repeat(64) begin
    ptch = ptch + 16'h0001;
    ptch_rt = ptch_rt - 16'h0100;
    integrator = integrator - 18'h00080;
    #2;
    end

    repeat(64) begin
    ptch = ptch + 16'h0001;
    ptch_rt = ptch_rt + 16'h0100;
    integrator = integrator - 18'h00080;
    #2;
    end

    repeat(64) begin
    ptch = ptch + 16'h0001;
    ptch_rt = ptch_rt - 16'h0100;
    integrator = integrator + 18'h00080;
    #2;
    end

    repeat(64) begin
    ptch = ptch + 16'h0001;
    ptch_rt = ptch_rt + 16'h0100;
    integrator = integrator + 18'h00080;
    #2;
    end

    repeat(64) begin
    ptch = ptch + 16'h0001;
    ptch_rt = ptch_rt - 16'h0100;
    integrator = integrator - 18'h00080;
    #2;
    end

    repeat(64) begin
    ptch = ptch + 16'h0001;
    ptch_rt = ptch_rt + 16'h0100;
    integrator = integrator - 18'h00080;
    #2;
    end
    #10;
    $stop();
end
endmodule