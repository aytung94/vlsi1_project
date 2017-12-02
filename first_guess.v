module FirstGuess(D, F);
	input [31:0] D;
	output [31:0] F;
	reg [31:0] F;
	
	always @(D) begin
		if(D >= 32'h80000000)
			F <= 32'h00000001;
		else if(D >= 32'h40000000)
			F <= 32'h00000002;
		else if(D >= 32'h20000000)
			F <= 32'h00000004;
		else if(D >= 32'h10000000)
			F <= 32'h00000008;
		else if(D >= 32'h08000000)
			F <= 32'h00000010;
		else if(D >= 32'h04000000)
			F <= 32'h00000020;
		else if(D >= 32'h02000000)
			F <= 32'h00000040;
		else if(D >= 32'h01000000)
			F <= 32'h00000080;
		else if(D >= 32'h00800000)
			F <= 32'h00000100;
		else if(D >= 32'h00400000)
			F <= 32'h00000200;
		else if(D >= 32'h00200000)
			F <= 32'h00000400;
		else if(D >= 32'h00100000)
			F <= 32'h00000800;
		else if(D >= 32'h00080000)
			F <= 32'h00001000;
		else if(D >= 32'h00040000)
			F <= 32'h00002000;
		else if(D >= 32'h00020000)
			F <= 32'h00004000;
		else if(D >= 32'h00010000)
			F <= 32'h00008000;
		else if(D >= 32'h00008000)
			F <= 32'h00010000;
		else if(D >= 32'h00004000)
			F <= 32'h00020000;
		else if(D >= 32'h00002000)
			F <= 32'h00040000;
		else if(D >= 32'h00001000)
			F <= 32'h00080000;
		else if(D >= 32'h00000800)
			F <= 32'h00100000;
		else if(D >= 32'h00000400)
			F <= 32'h00200000;
		else if(D >= 32'h00000200)
			F <= 32'h00400000;
		else if(D >= 32'h00000100)
			F <= 32'h00800000;
		else if(D >= 32'h00000080)
			F <= 32'h01000000;
		else if(D >= 32'h00000040)
			F <= 32'h02000000;
		else if(D >= 32'h00000020)
			F <= 32'h04000000;
		else if(D >= 32'h00000010)
			F <= 32'h08000000;
		else if(D >= 32'h00000008)
			F <= 32'h10000000;
		else if(D >= 32'h00000004)
			F <= 32'h20000000;
		else if(D >= 32'h00000002)
			F <= 32'h40000000;
		else // D >= 32'h00000001
			F <= 32'h80000000;
	
	end
endmodule
