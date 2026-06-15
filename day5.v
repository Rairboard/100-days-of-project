/*
This is the completed timer based on the fsm module on day 4.

The timer essentially wait until the sequence 1101 is entered then move on to wait for data to be entered in 4 cycles with 
MSB first. The 4 bit data are called delay[3:0]. After data is entered, the timer will decrement delay every 1000 cycles
including when delay is 4'b0000. Afterward, the done output pin signal is set to high waiting for the user to acknowledge
that the timer completed counting through the input pin ack which reset the state of the timer to the initial state of
searching for the initialization sequence of 1101.
*/
module top_module (
    input clk,
    input reset,      // Synchronous reset
    input data,
    output [3:0] count,
    output counting,
    output done,
    input ack );
    
    parameter 
    search = 0, s1 = 1, s11 = 2, s110 = 3, // these are the states required to detect sequence 1101
    SE1 = 4, SE2 = 5, SE3 = 6, SE4 = 7, // these are the 4 states where shift_ena is high
    counting_state = 8, // this state is high until done_counting is high 
    dun = 9; // this state is high until input pin ack is high
    
    // there are a total of 10 states so our states and next_states reg must be at least 4 bit
    reg [3:0] state, next_state;
    wire shift_ena; // intermediate wires set to high denoting that our timer is counting down
    reg [3:0] delay; // counter to hold the delay
    reg [9:0] counter; // internal counter to count 1000 cycle for every delay value
    
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
            SE4: next_state = counting_state;
            counting_state: next_state = delay == 0 && counter == 999 ? dun : counting_state;
            dun: next_state = ack ? search : dun;
        endcase
    end
    
    // updating state or reset on clk cycle
    always @(posedge clk) begin
        if(reset) begin
            state <= search;
            counter <= 0;
        end
        else begin
            state <= next_state;
            if(shift_ena) delay <= {delay[2:0], data};
            else if(counting) begin
                if(counter == 999) begin
                    counter <= 0;
                    delay <= delay - 1;
                end
                else counter <= counter + 1;
            end
        end
    end
    
    assign shift_ena = state == SE1 | state == SE2 | state == SE3 | state == SE4;
    assign counting = state == counting_state;
    assign done = state == dun;
    assign count = state == counting_state ? delay : {4{1'bx}};
endmodule
