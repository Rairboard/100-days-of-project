/*
this module is the fsm implemented to model a timer with one input that:
1. is started when a particular input pattern (1101) is detected,
2. shifts in 4 more bits to determine the duration to delay,
3. waits for the counters to finish counting, and 
4. notifies the user and waits for the user to acknowledge the timer.

I will implement the actual timer Verilog code on day 5
*/ 

module top_module (
    input clk,
    input reset,      // Synchronous reset
    input data,
    output shift_ena,
    output counting,
    input done_counting,
    output done,
    input ack );
	
    parameter 
    search = 0, s1 = 1, s11 = 2, s110 = 3, // these are the states required to detect sequence 1101
    SE1 = 4, SE2 = 5, SE3 = 6, SE4 = 7, // these are the 4 states where shift_ena is high
    count = 8, // this state is high until done_counting is high 
    dun = 9; // this state is high until input pin ack is high
    
    // there are a total of 10 states so our states and next_states reg must be at least 4 bit
    reg [3:0] state, next_state;
    
    // defining out next_state definition based on our fsm
    always @(*) begin
        case (state)
            search: next_state = data ? s1 : search;
            s1: next_state = data ? s11: search;
            s11: next_state = data ? s11 : s110;
            s110: next_state = data ? SE1 : search;
            SE1: next_state = SE2;
            SE2: next_state = SE3;
            SE3: next_state = SE4;
            SE4: next_state = count;
            count: next_state = done_counting ? dun : count;
            dun: next_state = ack ? search : dun;
        endcase
    end
    
    // updating state or reset on clk cycle
    always @(posedge clk) begin
        if(reset) state <= search;
        else state <= next_state;
    end
    
    assign shift_ena = state == SE1 | state == SE2 | state == SE3 | state == SE4;
    assign counting = state == count;
    assign done = state == dun;
endmodule
