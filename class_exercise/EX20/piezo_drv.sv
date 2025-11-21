//[Q] : the duration counter clock is based on the reference clock or the the new frequency clock? - 50Mhz ref clock
module piezo_drv #(parameter  fast_sim = 1) (
    input wire clk, //50Mhz clock
    input wire rst_n,
    input wire too_fast,
    input wire batt_low,
    input wire en_steer,
    output wire piezo, //GPIO Pin 
    output wire piezo_n //GPIO Pin
);

localparam CF_DUR_1 = 26'h080_0000;
localparam CF_DUR_2 = 26'h0C0_0000;
localparam CF_DUR_3 = 26'h040_0000;
localparam CF_DUR_4 = 26'h200_0000;

logic durtn_cnt_clr;
logic pzo_fqncy_cnt_clr;
logic [14:0]sm_frequency;

logic [14:0]add_term;
generate 
    if(fast_sim)
           assign add_term = 15'd64;
    else
           assign add_term = 15'd1;
endgenerate
/////////////////////////////////////////////////////////////////////
//////////////Duration Timer - How Long Each node has to be played///
/////////////////////////////////////////////////////////////////////
//count_value  = the the duration time the SM dictate
//Largest count is 2^25 clock cycles - 25bit counter
reg [25:0] duration_counter;
always @(posedge clk or negedge rst_n) 
    if(!rst_n)
        duration_counter <= 0;
    else if (durtn_cnt_clr) // Clear the counter at every state transition
        duration_counter <= 0;
    else begin
        duration_counter <= duration_counter + add_term;
    end
////////////////////////////////////////////////////////////////////////////////////////
//////////////Frequency / Period Timer - To generate the frequency of the node/////
////////////////////////////////////////////////////////////////////////////////////////
//Timer period = Period of the node coming from the state machine , it resets itself
// This counter should be resetting every time when each states completes??
// Also This control the piezo out - Once the timer reaches half its value piezo will go from high to low or low to high and also piezo_n vice versa
// The Least Frequency is for First Node in Charge Fanfare which is 1568 which will require the maximum counter value --> 50Mhz/3136 = 31888 closer to 2^ 15 - Hence a 16 bit counter
reg [14:0] piezo_frequency_cntr;
always @(posedge clk or negedge rst_n) 
    if(!rst_n)
        piezo_frequency_cntr <= 0;
    else if(piezo_frequency_cntr == sm_frequency)
        piezo_frequency_cntr <= 0;
    else if(pzo_fqncy_cnt_clr)
        piezo_frequency_cntr <= 0;
    else begin
        piezo_frequency_cntr <= piezo_frequency_cntr + add_term;
    end
///piezo should The half of the input Expected piezo frequency from the State machine (that particular state)))///
assign piezo   = (piezo_frequency_cntr >= (sm_frequency/2))? 1'b0 : 1'b1;
assign piezo_n = ~ piezo;
/////////////////////////////////////////////////////////////////////////////////
//////////////Repeat Timer - # 3  Seconds Repeat counter/////////////////////////
//This warning is for the outsiders to indicatethat we are on and moving/////////
////////28 bit counter - Counter value should be = 150,000,000 = 3s//////////////
/////////////////////////////////////////////////////////////////////////////////
reg [27:0] cnt_28bit;
reg cnt_3s_init;
logic cnt_3s_cmp;
logic clr_cnt_3s;
always @(posedge clk or negedge rst_n)
    if(!rst_n) begin
        cnt_28bit <= 0;
        cnt_3s_init <= 1'b1;
    end
    else if (clr_cnt_3s) begin     
        cnt_28bit <= 0;
        cnt_3s_init <= 1'b0;
    end
    else begin
        cnt_28bit <= cnt_28bit + add_term;
        cnt_3s_init <= 1'b0;
    end
///cnt_3s_cmp will go high which will trigger the statemachine during SILENT state to shift forward or backward
assign cnt_3s_cmp = (cnt_28bit == 28'd150000000); // Trigger For 3 Seconds - to restart this counter
///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////
logic forward;
reg reg_forward;
always @ (posedge clk or negedge rst_n)
    if(!rst_n) 
        reg_forward <= 0;
    else if ((cnt_3s_cmp | cnt_3s_init))
        reg_forward <= forward;

///////////////////////////////////////////////////////////////
/////////////State Machine - Charge Fanfare states/////////////
///////////////////////////////////////////////////////////////
typedef enum reg [2:0] {SILENT, CF_NOTE1 , CF_NOTE2 , CF_NOTE3 , CF_NOTE4 , CF_NOTE5 , CF_NOTE6} state_t;  //States to be filled
state_t state,nxt_state;
always @ (posedge clk or negedge rst_n)
    if(!rst_n) 
        state <= SILENT;
    else 
        state <= nxt_state;
always_comb begin
    nxt_state = state;
    pzo_fqncy_cnt_clr = 0;
    durtn_cnt_clr = 0;
    clr_cnt_3s = 0;
    forward = 0;
    case (state)
            SILENT : begin
                durtn_cnt_clr = 1;
                pzo_fqncy_cnt_clr = 1;
                if(too_fast)
                        nxt_state = CF_NOTE1; 
                else if (batt_low && (cnt_3s_cmp | cnt_3s_init)) begin
                        nxt_state = CF_NOTE6; 
                        forward = 0;
                        clr_cnt_3s = 1;
                end
                else if (en_steer && (cnt_3s_cmp | cnt_3s_init)) begin
                        nxt_state = CF_NOTE1; 
                        forward = 1;
                        clr_cnt_3s = 1;
                end
            end 
            CF_NOTE1 : begin
                sm_frequency = 15'h7C90; 
                if(too_fast && (duration_counter == CF_DUR_1)) begin
                        nxt_state = CF_NOTE2; 
                        durtn_cnt_clr = 1;
                        pzo_fqncy_cnt_clr = 1; 
                end
                else if (!reg_forward && (duration_counter == CF_DUR_1)) begin
                        nxt_state = SILENT;
                        durtn_cnt_clr = 1;
                        pzo_fqncy_cnt_clr = 1; 
                end
                else if (reg_forward && (duration_counter == CF_DUR_1)) begin
                        nxt_state = CF_NOTE2; 
                        durtn_cnt_clr = 1;
                        pzo_fqncy_cnt_clr = 1; 
                end
            end

            CF_NOTE2 : begin
                sm_frequency = 15'h5D52; // Half time of this piezo should transition
                if(too_fast && (duration_counter == CF_DUR_1)) begin
                        nxt_state = CF_NOTE3; 
                        durtn_cnt_clr = 1;
                        pzo_fqncy_cnt_clr = 1; 
                end
                else if (!reg_forward && (duration_counter == CF_DUR_1)) begin
                        nxt_state = CF_NOTE1;
                        durtn_cnt_clr = 1;
                        pzo_fqncy_cnt_clr = 1; 
                end
                else if (reg_forward && (duration_counter == CF_DUR_1)) begin
                        nxt_state = CF_NOTE3; 
                        durtn_cnt_clr = 1;
                        pzo_fqncy_cnt_clr = 1; 
                end           
            end

            CF_NOTE3 : begin
                sm_frequency = 15'h4A11; // Half time of this piezo should transition
                if(too_fast && (duration_counter == CF_DUR_1)) begin
                        nxt_state = CF_NOTE1; 
                        durtn_cnt_clr = 1;
                        pzo_fqncy_cnt_clr = 1; 
                end
                else if (!reg_forward && (duration_counter == CF_DUR_1)) begin
                        nxt_state = CF_NOTE2;
                        durtn_cnt_clr = 1;
                        pzo_fqncy_cnt_clr = 1; 
                end
                else if (reg_forward && (duration_counter == CF_DUR_1)) begin
                        nxt_state = CF_NOTE4; 
                        durtn_cnt_clr = 1;
                        pzo_fqncy_cnt_clr = 1; 
                end              
            end

            CF_NOTE4 : begin
                sm_frequency = 15'h3E48;
                if(too_fast && (duration_counter == CF_DUR_2)) begin
                        nxt_state = CF_NOTE1; 
                        durtn_cnt_clr = 1;
                        pzo_fqncy_cnt_clr = 1; 
                end
                else if (!reg_forward && (duration_counter == CF_DUR_2)) begin
                        nxt_state = CF_NOTE3;
                        durtn_cnt_clr = 1;
                        pzo_fqncy_cnt_clr = 1; 
                end
                else if (reg_forward && (duration_counter == CF_DUR_2)) begin
                        nxt_state = CF_NOTE5; 
                        durtn_cnt_clr = 1;
                        pzo_fqncy_cnt_clr = 1; 
                end 
            end

            CF_NOTE5 : begin
                sm_frequency = 15'h4A11; // Half time of this piezo should transition
                if(too_fast && (duration_counter == CF_DUR_3)) begin
                        nxt_state = CF_NOTE1; 
                        durtn_cnt_clr = 1;
                        pzo_fqncy_cnt_clr = 1; 
                end
                else if (!reg_forward && (duration_counter == CF_DUR_3)) begin
                        nxt_state = CF_NOTE4;
                        durtn_cnt_clr = 1;
                        pzo_fqncy_cnt_clr = 1; 
                end
                else if (reg_forward && (duration_counter == CF_DUR_3)) begin
                        nxt_state = CF_NOTE6; 
                        durtn_cnt_clr = 1;
                        pzo_fqncy_cnt_clr = 1; 
                end 
            end               
            CF_NOTE6 : begin
                sm_frequency = 15'h3E48; // Half time of this piezo should transition
                if(too_fast && (duration_counter == CF_DUR_4)) begin
                        nxt_state = CF_NOTE1; 
                        durtn_cnt_clr = 1;
                        pzo_fqncy_cnt_clr = 1; 
                end
                else if (!reg_forward && (duration_counter == CF_DUR_4)) begin
                        nxt_state = CF_NOTE5;
                        durtn_cnt_clr = 1;
                        pzo_fqncy_cnt_clr = 1; 
                end
                else if (reg_forward && (duration_counter == CF_DUR_4)) begin
                        nxt_state = SILENT; 
                        durtn_cnt_clr = 1;
                        pzo_fqncy_cnt_clr = 1; 
                end
            end
            default : begin
                nxt_state = SILENT;
            end
        endcase
end
endmodule
/// Duration counter increment - Synchronization with State machine
