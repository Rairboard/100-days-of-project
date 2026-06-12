/*

PS/2 Packet Receiver (FSM + Datapath)
A Verilog module that detects 3-byte PS/2 packets and captures their contents.
FSM: Identifies packet boundaries using bit 3 of the first byte (always 1 in valid PS/2 packets) as a synchronization marker. States: search, byte2, byte3, dun.
Datapath: A 24-bit register captures each incoming byte on the clock edge corresponding to the transition into the next state, using the next_state value to time the capture correctly.
Output: out_bytes[23:16] = first byte, out_bytes[15:8] = second byte, out_bytes[7:0] = third byte. Valid only when done is asserted; don't-care otherwise.
Key design point: Storage is timed using next_state rather than state, so each byte is captured on the same cycle it appears on in, avoiding a one-cycle lag.

*/

module top_module(
    input clk,
    input [7:0] in,
    input reset,    // Synchronous reset
    output [23:0] out_bytes,
    output done); //

	// defining the states    
    reg[1:0] state, next_state;
    reg[23:0] data;
    parameter search = 0, byte2 = 1, byte3 = 2, dun = 3;
    
    
    // defining next state defintion
    always @(*) begin
        case (state)
            search: next_state = in[3] ? byte2 : search;
            byte2: next_state = byte3;
            byte3: next_state = dun;
            dun: next_state = in[3] ? byte2 : search;
        endcase
    end
    
    // updates states and datapath 
    always @(posedge clk) begin
        if(reset) begin
            state <= search;
        end
        else begin
            state <= next_state;
            case(next_state)
                byte2: data[23:16] <= in;
                byte3: data[15:8] <= in;
                dun : data[7:0] <= in;
            endcase
        end
    end
    
    // assigning output
    assign done = state == dun;
    assign out_bytes = state == dun ? data : {24{1'bx}};

endmodule

