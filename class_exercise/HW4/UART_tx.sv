module UART_tx(
    input clk, rst_n,
    output TX,
    input trmt,
    input [7:0] tx_data,
    output reg tx_done
);

// Controller should pulse `trmt` for one cycle to initiate transmission
// `tx_done` goes high when transmission completes


logic load;
logic shift, transmitting;


//////////////////////////
//////baud counter///////
/////////////////////////

reg [12:0] baud_cnt;

// 5208 @ 50MHz → ~9600 baud
assign shift = (baud_cnt == 13'd5208) ? 1'b1 : 1'b0;

always_ff @(posedge clk) begin
    if (load || shift)
        baud_cnt <= 13'h000;
    else if (transmitting)
        baud_cnt <= baud_cnt + 1'b1 ;
end


//////////////////////////
//////number of bits/////
/////////////////////////

reg [3:0] bit_cnt;

always_ff @(posedge clk) begin
    if (load)
        bit_cnt <= 4'h0;
    else if (shift)
        bit_cnt <= bit_cnt + 1'b1 ;
end

logic set_done; 

//10 bits transmitting (start & stop bit included)

assign set_done = (bit_cnt == 4'd10) ? 1'b1 : 1'b0;


//////////////////////////
//////shift register/////
/////////////////////////

reg [8:0] tx_shift_reg;

always_ff @(posedge clk) begin
    if (load)
        tx_shift_reg <= {tx_data[7:0],1'b0};
    else if (shift) begin 
        tx_shift_reg <= {1'b1,tx_shift_reg[8:1]} ;
    end
end

assign TX = tx_shift_reg[0];

//////////////////////////
////////// FSM //////////
/////////////////////////

typedef enum reg {IDLE, TRANSMIT} state_t;

state_t state,nxt_state;

always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
        state <= IDLE;
    else 
        state <= nxt_state;

always_comb begin
    nxt_state = state;
    transmitting = 1'b0;
    load = trmt;

    //  At TRANSMIT, transmitting signal should be 1
    //  At IDLE/default, load should be 1 (keeping all in reset)

    case(state)
        TRANSMIT : begin
            transmitting = 1'b1;
            if (set_done)
                nxt_state = IDLE;
        end

        ////default IDLE////
        default: begin 
            if (trmt) 
                nxt_state = TRANSMIT; 
        end
    endcase
end

//////////////////////////
///////Final Output///////
/////////////////////////

always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
        tx_done <= 1'b0;
    else if ((state == TRANSMIT) && set_done)
        tx_done <= 1'b1;
    else if (trmt)
        tx_done <= 1'b0;

endmodule