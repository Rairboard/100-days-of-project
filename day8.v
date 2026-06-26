/* 
Got really busy so to start getting back I implemented a factorial FSM to calculuate the factorial of a number N.
I also implemented a simple test bench to practice my test bench skills.
*/

module factorial(
  input clk,
  input reset,
  input [31:0] N,
  output [31:0] q
);
  
  reg [1:0] state, next_state;
  parameter start = 0, loop = 1, done = 2;
  reg [31:0] A, B;
  
  always @(*) begin
    case(state)
      start : next_state = loop;
      loop : next_state = B == 1 ? done : loop;
      done : next_state = done;
    endcase
  end
  
  always @(posedge clk) begin
    if(reset) begin
      state <= start;
      A <= 32'd1;
      B <= N;
    end
    else begin
      A <= A * B;
      B <= B - 1;
      state <= next_state;
    end
  end
  
  assign q = state == done ? A : {32{1'bX}};
endmodule

/*
The test bench below is simulate using iVerilog v12.0
*/

module tb;
  reg [31:0] N;
  wire [31:0] q;
  reg clk, reset;
  
  factorial dut(
    .clk(clk),
    .reset(reset),
    .N(N),
    .q(q)
  );
  
  initial clk = 0;
  always #5 clk = ~clk;
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);
    
    reset = 1;
    N = 32'd5;
    repeat(2) @(posedge clk);
    
    @(posedge clk) reset = 0;
    N = 32'd0;
    
    
    repeat(10) @(posedge clk);
    $display("5! = %0d", q);
    
    @(posedge clk);
    N = 32'd6;
    reset = 1;
    repeat(2) @(posedge clk);
    
    @(posedge clk) reset = 0;
    N = 0;
    repeat(10) @(posedge clk);
    $display("6! = %0d", q);
    $finish;
  end
    
endmodule
