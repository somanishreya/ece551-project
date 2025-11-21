module SPI_mnrch(
    input clk, rst_n,
    output reg SS_N, 
    output SCLK, MOSI,
    input MISO, wrt,
    input [15:0] wrt_data,
    output reg done,
    output [15:0] rd_data 
);

// Generating SCLK from system clk
// To give initial delay, using load of 4,b1011
// smpl will be on pos edge of SCLK, i.e 0111 to 1000 transition
// shft_im will be on negege of SCLK, i.e 1111 to 0000 transition
// SCLK to be the MSB of counter, it becomes 1/16 of system clk

logic smpl, shft_im;
logic ld_SCLK; //coming from SM
reg [3:0] SCLK_div;

always_ff @(posedge clk) begin
    if (ld_SCLK)
        SCLK_div <= 4'b1011;
    else   
        SCLK_div <= SCLK_div + 1;
end

assign SCLK = SCLK_div[3];
assign smpl = (SCLK_div == 4'b0111);
assign shft_im = &SCLK_div;

//counter to tell me where in 16 bit packet I am At
//counting till 15 because last bit we will do in next state,
// which will assume fall of SCLK

reg [3:0] bit_cntr;
logic done15; //consumed by SM
logic init; //coming from SM
logic shft;

always_ff @(posedge clk) begin
    if (init)
        bit_cntr <= 4'b0000;
    else if (shft)
        bit_cntr <= bit_cntr + 4'b0001;
end

assign done15 = &bit_cntr;

//MISO, MOSI assignments
//MOSI is evaluated on fall of SCLK
//MISO is sampled on rise of SCLK

reg MISO_smpl;

always_ff @(posedge clk) begin
    if (smpl)
        MISO_smpl <= MISO;
end

reg [15:0] shft_reg;

always_ff @(posedge clk) begin
    if (init)
        shft_reg <= wrt_data;
    else if (shft)
        shft_reg <= {shft_reg[14:0],MISO_smpl};
end

assign MOSI = shft_reg[15];

assign rd_data = shft_reg;

/*////////////////////////////////
/////////////state machine///////
////////////////////////////////*/

typedef enum reg [1:0] {IDLE, FRONTPRCH, SHIFTING, BACKPRCH} state_t;
state_t state, nxt_state;

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n)
        state <= IDLE;
    else
        state <= nxt_state;
end

//FRONTPRCH is introduced to drop start shift_imm
//BACKPRCH is there to let the shift of 16th bit continue
// set done is set when 15 shift complete 

logic set_done;

always_comb begin
    nxt_state = state;
    init = 1'b0;
    ld_SCLK = 1'b0;
    set_done = 1'b0;
    shft = 1'b0;

    case (state)

        FRONTPRCH: begin
            if (shft_im)
                nxt_state = SHIFTING;
        end

        SHIFTING : begin
            if (shft_im)
                shft = 1'b1;
            if (done15)
                nxt_state = BACKPRCH;
        end

        BACKPRCH : begin
            if (shft_im) begin
                nxt_state = IDLE;
                set_done = 1'b1;
                ld_SCLK = 1'b1;
                shft = 1'b1;
            end
        end

        //default as IDLE
        default : begin
            if (wrt) begin
                nxt_state = FRONTPRCH;
                init = 1'b1;
            end
            ld_SCLK = 1'b1;
        end

    endcase
end



//done & SS_N signals
//need to be synchronised, no glicth here allowed
//seperating both as SS_N will be preset with reset &
//done will be reset with reset


always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n)
        SS_N <= 1'b1; //preset
    else if (init)
        SS_N <= 1'b0;
    else if (set_done)
        SS_N <= 1'b1;
end

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n)
        done <= 1'b0;
    else if (init)
        done <= 1'b0;
    else if (set_done)
        done <= 1'b1;
end


endmodule