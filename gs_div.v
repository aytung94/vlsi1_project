`include "first_guess.v"
`include "MULT.v"

module top;

reg [63:0] A, B;
reg clk, rst;
reg [63:0] counter;
reg [63:0] realC;
wire [63:0] C;
wire done;
integer i;

always begin
  #5 clk = ~clk; 
end

initial begin
  clk = 0;
  counter = 0;
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
      $display ("failed: A = %h, B = %h, C = %h\n", A, B, C); 
      counter = counter + 1;
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
reg [32:0] F0, F1, F2, F3, F4;
reg [96:0] N0, D0, N1, D1, N2, D2, N3, D3, N4, D4, N5, D5;
output reg [63:0] Q;
output reg done;
reg [3:0] state, next_state;

//lut_f get_f(D, F);
assign F[32] = 1'b0;
FirstGuess get_f(D[63:32], F[31:0]);

reg [63:0] A0, A1;
reg [32:0] B0, B1;
wire [96:0] C0, C1; 
//mult97_64x33 mult0(A0, B0, C0);
//mult97_64x33 mult1(A1, B1, C1);
MULT mult0(A0, B0, C0);
MULT mult1(A1, B1, C1);

reg [3:0] counter, next_counter;

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
    F0 <= F0;
    N0 <= N0;
    D0 <= D0;
    F1 <= F1;
    N1 <= N1;
    D1 <= D1;
    F2 <= F2;
    N2 <= N2;
    D2 <= D2;
    F3 <= F3;
    N3 <= N3;
    D3 <= D3;
    F4 <= F4;
    N4 <= N4;
    D4 <= D4;
    N5 <= N5;
    D5 <= D5;
    done <= done;
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
      //N0 <= N * F; 
      //D0 <= D * F;
      next_counter <= counter + 1;
      next_state <= 2;
    end 
    2: begin // iteration 2, 3, 4...
      //N0 <= C0[95:32];
      //D0 <= C1[95:32];
      //F0 <= ((~(C1[95:32])) + 1) & 33'h1FFFFFFFF;
      A0 <= C0[95:32];
      B0 <= ((~(C1[95:32])) + 1) & 33'h1FFFFFFFF;
      A1 <= C1[95:32];
      B1 <= ((~(C1[95:32])) + 1) & 33'h1FFFFFFFF;
      if (counter == 5) begin
        next_counter <= counter;
        next_state <= 3;
      end
      else begin
        next_counter <= counter + 1;
        next_state <= 2;
      end
    end 
/*    3: begin // iteration 2
      A0 <= N0;
      B0 <= F0;
      A1 <= D0;
      B1 <= F0;
      //N1 <= N0 * F0;
      //D1 <= D0 * F0;
    end 
    4: begin
      N1 <= C0[95:32];
      D1 <= C1[95:32];
      F1 <= ((~(C1[95:32])) + 1) & 33'h1FFFFFFFF;
    end 
    5: begin // iteration 3
      A0 <= N1;
      B0 <= F1;
      A1 <= D1;
      B1 <= F1;
      //N2 <= N1 * F1;
      //D2 <= D1 * F1;
    end 
    6: begin 
      N2 <= C0[95:32];
      D2 <= C1[95:32];
      F2 <= ((~(C1[95:32])) + 1) & 33'h1FFFFFFFF;
    end 
    7: begin // iteration 4
      A0 <= N2;
      B0 <= F2;
      A1 <= D2;
      B1 <= F2;
      //N3 <= N2 * F2;
      //D3 <= D2 * F2;
    end 
    8: begin
      N3 <= C0[95:32];
      D3 <= C1[95:32];
      F3 <= ((~(C1[95:32])) + 1) & 33'h1FFFFFFFF;
    end 
    9: begin //iteration 5
      A0 <= N3;
      B0 <= F3;
      A1 <= D3;
      B1 <= F3;
      //N4 <= N3 * F3;
      //D4 <= D3 * F3;
    end
    10: begin
      N4 <= C0[95:32];
      D4 <= C1[95:32];
      F4 <= ((~(C1[95:32])) + 1) & 33'h1FFFFFFFF;
    end 
    11: begin //iteration 6
      A0 <= N4;
      B0 <= F4;
      A1 <= D4;
      B1 <= F4;
      //N5 <= N4 * F4;
      //D5 <= D4 * F4;
    end 
    12: begin */
    3: begin
      //N5 <= C0[95:32];
      //D5 <= C1[95:32];
      Q <= C0[95:32]; 
      done <= 1; 
      next_state <= 4;
    end
    4: begin
      Q <= Q;
      done <= 1;
      next_state <= 4;
    end
    default: begin
      done <= 1;
    end
  endcase
end
endmodule
