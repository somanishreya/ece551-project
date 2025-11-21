module adder (a,b, cin , sum, co);

    localparam WIDTH = 4;
    input [WIDTH-1:0] a,b;
    input cin;
    output [WIDTH-1:0] sum;
    output co;

    assign {co, sum} = a + b + cin;
endmodule