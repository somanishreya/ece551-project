module Auth_blk(
    input clk, rst_n,
    input RX,
    input rider_off,
    output reg pwr_up
);

logic rx_rdy, clr_rdy;
logic [7:0] rx_data;

UART_rx rx_auth( .clk(clk), .rst_n(rst_n), .RX(RX), .clr_rdy(clr_rdy), .rx_data(rx_data), .rdy(rx_rdy));

typedef enum reg [1:0] {IDLE, CONNECTED, DISCONNECTED} state_t;

localparam byte CMD_DISCONNECT = 8'h53; // 'S'
localparam byte CMD_CONNECT    = 8'h47; // 'G'


state_t state, nxt_state;

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n)
        state <= IDLE;
    else
        state <= nxt_state;
end

always_comb begin
    nxt_state = state;
    clr_rdy = 1'b0;
    pwr_up = 1'b1;

    case (state)

    CONNECTED : 
        //pwr_up = 1'b1; //already defined above
        if (rx_rdy && (rx_data==CMD_DISCONNECT) && rider_off) begin
            clr_rdy = 1'b1;
            pwr_up = 1'b0;
            nxt_state = IDLE;
        end
        else if (rx_rdy && (rx_data==CMD_DISCONNECT)) begin
            //pwr_up = 1'b1; //already defined above
            clr_rdy = 1'b1;
            nxt_state = DISCONNECTED;
        end
    
    DISCONNECTED :
        if (rx_rdy && (rx_data==CMD_CONNECT)) begin
            clr_rdy = 1'b1;
            //pwr_up = 1'b1; //already defined above
            nxt_state = CONNECTED;
        end
        else if (rider_off) begin
            pwr_up = 1'b0;
            nxt_state = IDLE;
        end

    ///////default IDLE/////////
    default : begin
        pwr_up = 1'b0;
        if (rx_rdy && (rx_data==CMD_CONNECT)) begin
            clr_rdy = 1'b1;
            pwr_up = 1'b1;
            nxt_state = CONNECTED;
        end
        else if (rx_rdy) begin
            clr_rdy = 1'b1;
        end
    end
    endcase
end
endmodule

