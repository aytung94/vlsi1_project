`include "first_guess.v"
`include "MULT.v"

module top;

parameter I_BITS = 32;
parameter F_BITS = 40;
parameter T_BITS = I_BITS + F_BITS;
parameter NUM_TST = 99999;

reg [T_BITS-1:0] A, B;
reg clk, rst;
reg [T_BITS-1:0] counter;
reg [T_BITS-1:0] realC;
wire [T_BITS-1:0] C;
wire done;
integer i;
integer max;
integer shift;

always begin
  #5 clk = ~clk; 
end

initial begin
  clk = 0;
  counter = 0;
  $display("Starting %d tests", NUM_TST);
  for (i = 0; i < NUM_TST; i = i + 1) begin
    shift = i % (I_BITS-2);
    A[T_BITS-2:F_BITS] = $random;
    A[T_BITS-1] = 0;
    A[F_BITS-1:0] = 0;
    B[T_BITS-2:F_BITS] = $random % (A[T_BITS-2:F_BITS] >> shift);
    B[T_BITS-1] = 0;
    B[F_BITS-1:0] = 0; 
    rst = 1;
    #20
    rst = 0;
    while (!done) begin
      #100
      rst = 0;
    end
    realC = A/B;
    if ((C >> F_BITS) != realC) begin
      $display ("failed: A = %h, B = %h, C = %h, Actual C = %h\n", A, B, C, realC); 
      counter = counter + 1;
    end
    else begin
//      $display ("passed: A = %h, B = %h, C = %h, Actual C = %h\n", A, B, C, realC); 
    end
  end
  $display ("%d tests, %d errors, %d percent correct\n", NUM_TST, counter, ((NUM_TST-counter)*100)/NUM_TST);
  $finish;
end

gs_div div(clk, rst, A,B,C, done);

endmodule

module gs_div(clk, rst, N, D, Q, done);

parameter I_BITS = 32;
parameter F_BITS = 40;
parameter T_BITS = I_BITS + F_BITS;
parameter F_MASK = 41'h1FFFFFFFFFF; // size is F_BITS+1
parameter NUM_ITR = 7;

input clk , rst;
input [T_BITS-1:0] N, D;
wire[F_BITS:0] F;
output reg [T_BITS-1:0] Q;
output reg done;
reg [3:0] state, next_state;
reg [3:0] counter, next_counter;

// first guess F
assign F[F_BITS] = 1'b0;
assign F[F_BITS-I_BITS-1:0] = 0;
FirstGuess get_f(D[T_BITS-1:F_BITS], F[F_BITS-1:F_BITS-I_BITS]);

// multipliers
reg [T_BITS-1:0] A0, A1;
reg [F_BITS:0] B0, B1;
wire [T_BITS+F_BITS:0] C0, C1; 
MULT mult0(A0, B0, C0);
MULT mult1(A1, B1, C1);

always @ (posedge clk) begin
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
      if (N == 0 | D > N) begin // 0 solution
        Q <= 0;          
        done <= 1;
        next_counter <= 0;
        next_state <= 4;
      end
      else if (D == N) begin // exact 1 solution
        Q <= 1;
        done <= 1;
        next_counter <= 0;
        next_state <= 4;
      end
      else if (D == 1) begin // N solution
        Q <= N;
        done <= 1;
        next_counter <= 0;
        next_state <= 4;
      end
      else begin
        done <= 0;
        next_counter <= 0;
        next_state <= 1;
      end
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
      A0 <= C0[T_BITS+F_BITS-1:F_BITS];
      B0 <= ((~(C1[T_BITS+F_BITS-1:F_BITS])) + 1) & F_MASK;
      A1 <= C1[T_BITS+F_BITS-1:F_BITS];
      B1 <= ((~(C1[T_BITS+F_BITS-1:F_BITS])) + 1) & F_MASK; 
      done <= 0;
      Q <= C0[T_BITS+F_BITS-1:F_BITS];
      if (counter > NUM_ITR) begin
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
      Q <= Q;
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
