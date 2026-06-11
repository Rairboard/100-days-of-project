module top_module(
    input clk,
    input areset,    // Freshly brainwashed Lemmings walk left.
    input bump_left,
    input bump_right,
    input ground,
    input dig,
    output walk_left,
    output walk_right,
    output aaah,
    output digging ); 
	
    // defining the possible state in the FSM
    parameter left = 0, right = 1, fall_left = 2, fall_right = 3, dig_left = 4, dig_right = 5, dead = 6;
    reg[2:0] state, next_state;
    reg [31:0] counter;
    
    // defining next_state logic
    always @(*)begin
        case(state)
            left: begin
                if(~ground) next_state = fall_left;
                else if(dig) next_state = dig_left;
                else if(bump_left) next_state = right;
                else next_state = state;
            end
            right: begin
                if(~ground) next_state = fall_right;
                else if(dig) next_state = dig_right;
                else if(bump_right) next_state = left;
                else next_state = state;
            end
            fall_left : next_state = ground ? (counter >= 20 ? dead : left) : state;
            fall_right : next_state = ground ? (counter >= 20 ? dead : right) : state;
            dig_left : next_state = ~ground ? fall_left : state;
            dig_right : next_state = ~ground ? fall_right : state;
            dead: next_state  =  dead;
        endcase
    end

    // updating new state and counter
    always @(posedge clk, posedge areset) begin
        if(areset) begin
            state <= left;
            counter <= 0;
        end
        else begin
            state <= next_state;
            counter <= state == fall_left | state == fall_right ? counter + 1 : 0;
        end
    end
    
    // assigning output for waveform simulation
    assign walk_left = state == left;
    assign walk_right = state == right;
    assign aaah = state == fall_left | state == fall_right;
    assign digging = state == dig_left | state == dig_right;
    
endmodule
