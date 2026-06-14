/*
this is a serial 2's complementer implemented using a Mealy FSM to allow me to learn the difference between Mealy vs. Moore
*/
module top_module (
    input clk,
    input areset,
    input x,
    output z
); 
    // defining two states A & B
    parameter A = 0, B = 1;
    reg [1:0] state, next_state;
    
    // using one-hot encoding to define next state defintion
    always @(*) begin
        next_state[A] = state[A] & ~x; // we're staying at the first state until we hit a 1
        next_state[B] = state[A] & x | state[B]; // we get to the 2nd state by hitting a 1 from 1st state or if we're already at state 2
    end
    
    // setting trasition and flip flop logic
    always @(posedge clk, posedge areset) begin
        if(areset) state <= 2'b01;
        else begin
            state <= next_state;
        end
    end
    
    /* 
    output a 1 if we get a 1 input from 1st state
    and if we in 2nd state we output the opposite of the input bit so only if a 0 in state 2
    */
    assign z = state[A] & x | (state[B] & ~x);
endmodule
