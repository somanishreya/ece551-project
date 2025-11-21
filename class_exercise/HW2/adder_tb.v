module adder_tb();

localparam WIDTH = 4;
reg [WIDTH-1:0] a,b;
reg cin;
wire [WIDTH-1:0] sum;
wire co;

adder iDUT (.a(a), .b(b), .cin(cin), .sum(sum), .co(co));

reg [WIDTH:0] expected;
initial begin

    a=4'b0000; b=4'b0000; cin=1'b0; expected=5'b00000;
    #10;

    //1st loop with cin=0

    repeat (2**WIDTH) begin    //replacing 16 with 2**WIDTH to make it future scalable
        repeat (2**WIDTH) begin
            #5;
            if ({co, sum} !== expected) begin
                $display("Test failed for a=%b, b=%b, cin=%b: expected %b, got %b%b", a, b, cin, expected, co, sum);
                $stop();
            end
            #1 b = b + 1;
            expected = expected + 5'b00001; //incrementing expected linearly, as a and b are incremented linearly
        end
        #1 a = a + 1;
        b = 4'b0000;
        expected = a; //resetting expected to a, as b and cin are 0
    end

    //2nd loop with cin=1

    #10 a=4'b0000; b=4'b0000; cin=1'b1; expected=5'b00001;
    #10;

    repeat (2**WIDTH) begin    
        repeat (2**WIDTH) begin
            #5;
            if ({co, sum} !== expected) begin
                $display("Test failed for a=%b, b=%b, cin=%b: expected %b, got %b%b", a, b, cin, expected, co, sum);
                $stop();
            end
            #1 b = b + 1;
            expected = expected + 5'b00001; //incrementing expected linearly, as a and b are incremented linearly
        end
        #1 a = a + 1;
        b = 4'b0000;
        expected = a + 5'b00001; //adding 1 for cin
    end
    $display("Yahoo! All tests passed.");
    $stop();
end
endmodule