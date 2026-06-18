/* 
In today module, I attempted to implemented the Branch Direction Predictor using the gshare algorithm

The algorithm utilize the XOR (^) of the Program Counter Address (PC) and the Branch History Register (BHR) N-most recent
branch actions to generate an index in the Pattern History Table (PHT) which is a table containing 2^N entries of 2-bit 
saturating counters that are used as prediction where (2'b00,2'b01 = non-taken / 2'b10,2'b11 = taken).

There are two interfaces to the Branch Direction Predictor: Prediction vs. Training

Prediction (occurs at Fetch stage): the BHR will use the current PC ^ BHR as index to the PHT and receive the value to 
predict taken or not then the speculative value (predict_taken) is shifted into the BHR assuming it was the correct 
prediction.

Training (occurs at Execute stage): the BHR utilizes the current PC ^ BHR before the prediction as index for the PHT to
retrieve the 2-bit saturaing counter. The counter will then be updated according to the actual outcome (train_taken) where
if train_taken = 0 (not taken) the counter is decremented and vice versa; incremented if taken (train_taken = 1)

In addition, the BHR as follows with training having precedent over prediction:

train_valid = 1:
- train_mispredicted = 1: BHR <= {train_history[5:0], train_taken} // updating correct BHR if mispredicted
- predict_valid = 1: BHR <= {BHR[5:0], predict_taken}; // if not mispredicted but predict is valid
- otherwise: BHR <= BHR;

predict_valid = 1:
- BHR <= {BHR[5:0], predict_taken};

otherwise: BHR <= BHR

Lastly, this code is not most optimized in my opinion as I spent majority of my time today understanding the Branch Direction
Predictor gshare algorithm and the architecture of how it fits into the CPU pipeline, the role of the mux and the PC regsiter.

I will most likely update this code on day 8 or a later date.

*/
module top_module(
    input clk,
    input areset,

    input  predict_valid,
    input  [6:0] predict_pc,
    output predict_taken,
    output [6:0] predict_history,

    input train_valid,
    input train_taken,
    input train_mispredicted,
    input [6:0] train_history,
    input [6:0] train_pc
);
    reg [1:0] PHT [127:0];
    reg [6:0] BHR;
    integer i;
    always @(posedge clk, posedge areset) begin
        if(areset) begin
            BHR <= 0;
            for(i = 0;i < 128;i = i + 1) begin
                PHT[i] <= 2'b01;
            end
        end
        else begin
            if(train_valid) begin
                if(train_mispredicted) BHR <= {train_history[5:0], train_taken};
                else if(predict_valid) BHR <= {BHR[5:0], predict_taken};
                case(train_taken)
                    1'b0: PHT[train_pc ^ train_history] <= PHT[train_pc ^ train_history] == 0 ? 0 : PHT[train_pc ^ train_history] - 1;
                    1'b1: PHT[train_pc ^ train_history] <= PHT[train_pc ^ train_history] == 3 ? 3 : PHT[train_pc ^ train_history] + 1;
                endcase
            end
            else if(predict_valid) begin
                BHR <= {BHR[5:0], predict_taken};
            end
            else BHR <= BHR;
        end
    end
    
    assign predict_taken = PHT[predict_pc ^ BHR][1];
    assign predict_history = BHR;
endmodule
