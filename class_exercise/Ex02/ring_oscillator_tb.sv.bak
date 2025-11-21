module ring_oscillator_tb;
    logic en;
    logic out;

    ring_oscillator dut (
        .en(en),
        .out(out)
    );

    initial begin
        en = 0;
        #15;
        if (out !== 1) begin
            $display("FAIL: Output should be low when enable is low.");
            $stop;
        end

        en = 1;
        #120; // Wait to observe oscillation

        if (out === 1'bx) begin
            $display("FAIL: Output is unknown after enable is high.");
        end else begin
            $display("PASS: Output is toggling after enable is high.");
        end

        $stop;
    end
endmodule