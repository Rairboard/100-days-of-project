/*
In this module, I implement a Branch History Register (BHR), a component of the Branch Predictor which is a hardware that
predicts the result of a branch based on the Program Counter (PC) address and the N-most recent Branch actions stored in 
the BHR. 

The BHR is implemented as a 32-bit shift register in which the most recent prediction will be shift in the LSB and the oldest
branch result is shifted out at the MSB.

The code below is incredible easy to implement, but I spent about 2 hours to understand the architecture of the Branch 
Predictor and its entire process. Lastly, I also utilized that time to understand the role of the BHR in the Branch Predictor
*/
module top_module(
    input clk,
    input areset,

    input predict_valid,
    input predict_taken,
    output [31:0] predict_history,

    input train_mispredicted,
    input train_taken,
    input [31:0] train_history
);
	
    always @(posedge clk, posedge areset) begin
        // asynchronous reset of the Branch History Register (BHR)
        if(areset) predict_history <= 0;
        else begin
            // if areset is low, then we have two options, either predicting, or restoring a misprediction
            
            // BHR = (BHR before prediction)[30:0] + correct result
            if(train_mispredicted) predict_history <= {train_history[30:0], train_taken};
            
            // BHR = BHR[30:0] + prediction
            else if(predict_valid) predict_history <= {predict_history[30:0], predict_taken};
            
            // otherwise, BHR maintain current values as a register
            else predict_history <= predict_history;
        end
    end
                
endmodule
