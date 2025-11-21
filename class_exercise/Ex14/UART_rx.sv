module UART_rx(
    input clk, rst_n,
    input RX,
    input clr_rdy,
    output [7:0] rx_data,
    output reg rdy
);

// recieving only starts when 0 is seen on double flopped RX signal
// `rdy` goes high when recieving completes


logic start;
logic shift, recieving;


//////////////////////////
//////double flop////////
/////////////////////////

//since clk of rx & tx will be different, need to double flop RX signal

logic RX_ff1, RX_final, P_set;


//preset since in IDLE RX will be 1
assign P_set = rst_n;

always_ff @(posedge clk, negedge rst_n) begin
    if (!P_set)
        RX_ff1 <= 1'b1;
    else
        RX_ff1 <= RX;
end

always_ff @(posedge clk, negedge rst_n) begin
    if (!P_set)
        RX_final <= 1'b1;
    else
        RX_final <= RX_ff1;
end


//RX_final will only be used ahead

//////////////////////////
//////baud counter///////
/////////////////////////

reg [12:0] baud_cnt;
assign shift = (baud_cnt == 13'd0);

//down counter
always_ff @(posedge clk) begin
    //initially will start at half baud rate for start bit then every time full baud rate
    if (start)
        baud_cnt <= 13'd2604;
    else if (shift)
        baud_cnt <= 13'd5208;
    else if (recieving)
        baud_cnt <= baud_cnt - 1'b1 ;
end


//////////////////////////
//////number of bits/////
/////////////////////////

reg [3:0] bit_cnt;

always_ff @(posedge clk) begin
    if (start)
        bit_cnt <= 4'h0;
    else if (shift)
        bit_cnt <= bit_cnt + 1'b1 ;
end

logic set_rdy; 

//10 bits transmitting (start & stop bit included)

assign set_rdy = (bit_cnt == 4'd10);


//////////////////////////
//////shift register/////
/////////////////////////

reg [8:0] rx_shift_reg;

always_ff @(posedge clk) begin
    if (shift) begin 
        rx_shift_reg <= {RX_final,rx_shift_reg[8:1]} ;
    end
end

assign rx_data = rx_shift_reg[7:0];

//////////////////////////
////////// FSM //////////
/////////////////////////

typedef enum reg {IDLE, RECEIVE} state_t;

state_t state,nxt_state;

always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
        state <= IDLE;
    else 
        state <= nxt_state;

always_comb begin
    nxt_state = state;
    recieving = 1'b0;
    start = 1'b0;

    //  At RECEIVE, recieving signal should be 1
    //  At IDLE/default, load should be 1 (keeping all in reset)

    case(state)
        RECEIVE : begin
            recieving = 1'b1;
            if (set_rdy)
                nxt_state = IDLE;
        end

        ////default IDLE////
        default: begin 
            if (RX_final==1'b0) begin
                nxt_state = RECEIVE; 
                start = 1'b1;  
            end    
        end
    endcase
end

//////////////////////////
///////Final Output///////
/////////////////////////

always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
        rdy <= 1'b0;
    else if ((state == RECEIVE) && set_rdy)
        rdy <= 1'b1;
    else if (start || clr_rdy)
        rdy <= 1'b0;

endmodule