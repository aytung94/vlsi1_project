module CheckRes(Result, A, B, error);
	input [31:0] A, B, Result;
	output [1:0]  error;
	
	wire[96:0] Result_prime;
	MULT mult({32'h00000000, A}, {1'b0, B}, Result_prime);
	assign error[0] = (Result < Result_prime[31:0]);
	assign error[1] = (Result > Result_prime[31:0]); 
endmodule
