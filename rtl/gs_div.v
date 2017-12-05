`include "first_guess.v"
`include "MULT.v"
`include "error_check.v"

module top;

reg [63:0] A, B;
reg clk, rst;
reg [63:0] counter;
reg [63:0] realC;
wire [63:0] C;
wire done;
integer i;
integer max;

always begin
  #5 clk = ~clk; 
end

initial begin
  clk = 0;
  counter = 0;
  max = 0;
  for (i = 0; i < 99999; i = i + 1) begin
    A[62:32] = $random;
    A[63] = 0;
    A[31:0] = 0;
    B[62:32] = $random % (A[62:32] >> 15);
    B[63] = 0;
    B[31:0] = 0; 
    rst = 1;
    #20
    rst = 0;
    while (!done) begin
      #100
      rst = 0;
    end
    realC = A/B;
    if ((C >> 32) != realC) begin
      $display ("failed: A = %h, B = %h, C = %h, Actual C = %h\n", A, B, C, realC); 
      counter = counter + 1;
      if(realC-C > max) begin
        max = realC-C;    
      end
      $display ("max: %h", max);
    end
  end
  $display ("99999 tests, %h errors\n", counter);
  $finish;
end

gs_div div(clk, rst, A,B,C, done);

endmodule

//module lut_f(D, F);
//  input [63:0] D;
//  output [32:0] F;
//
//  assign F = 33'h010000000;
//endmodule
//
//module mult97_64x33(A, B, C);
//  input [63:0] A;
//  input [32:0] B;
//  output [96:0] C;
//
//  assign C = A * B;
//endmodule

module gs_div(clk, rst, N, D, Q, done);

input clk , rst;
input [63:0] N, D;
wire[32:0] F;
output reg [63:0] Q;
output reg done;
reg [3:0] state, next_state;
reg [3:0] counter, next_counter;

// first guess F
assign F[32] = 1'b0;
FirstGuess get_f(D[63:32], F[31:0]);

// multipliers
reg [63:0] A0, A1;
reg [32:0] B0, B1;
wire [96:0] C0, C1; 
MULT mult0(A0, B0, C0);
MULT mult1(A1, B1, C1);

// error checker
wire [1:0] error;
CheckRes checker(N[63:32], Q[63:32], D[63:32], error);

always @ (posedge clk, rst) begin
  if (rst) begin
    state <= 0;
  end 
  else begin
    state <= next_state;
    counter <= next_counter;
  end
end

always @ (state, counter, rst) begin
  case (state)
    0: begin      
      if (N == 0 | D > N) begin
        Q <= 0;          
        done <= 1;
      end
      else if (D == N) begin
        Q <= 1;
        done <= 1;
      end
      else if (D == 1) begin
        Q <= N;
        done <= 1;
      end
      // add 2^n's division for faster
      else begin
        done <= 0;
      end 
      next_counter <= 0;
      next_state <= 1;
    end 
    1: begin // iteration 1
      A0 <= N;
      B0 <= F;
      A1 <= D;
      B1 <= F;
      Q <= Q;
      done <= 0;
      next_counter <= counter + 1;
      next_state <= 2;
    end 
    2: begin // iteration 2, 3, 4...
      A0 <= C0[95:32];
      B0 <= ((~(C1[95:32])) + 1) & 33'h1FFFFFFFF;
      A1 <= C1[95:32];
      B1 <= ((~(C1[95:32])) + 1) & 33'h1FFFFFFFF;
      done <= 0;
      Q <= C0[95:32];
      if (counter >= 6) begin
        next_counter <= counter;
        next_state <= 3;
      end
      else begin
        next_counter <= counter + 1;
        next_state <= 2;
      end
    end 
    3: begin
      A0 <= A0;
      B0 <= B0;
      A1 <= A1;
      B1 <= B1;
      if (error[0]) begin
        Q <= Q - 33'h100000000; 
      end
      else if (error[1]) begin
 	Q <= Q + 33'h100000000;
      end
      else begin
        Q <= Q;
      end
      done <= 1; 
      next_counter <= 0;
      next_state <= 3;
    end
    default: begin
      A0 <= A0;
      B0 <= B0;
      A1 <= A1;
      B1 <= B1;
      Q <= Q; 
      done <= done; 
      next_counter <= next_counter;
      next_state <= next_state;
    end
  endcase
end
endmodule
