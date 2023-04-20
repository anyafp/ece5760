`timescale 1ns/1ns

module testbench();
	
    reg clk_50, reset;

	//Initialize clocks and index
	initial begin
		clk_50   =  1'b0;
	end
	
	// Toggle the clocks
	always begin
		#10
		clk_50  = !clk_50;
	end
	
	// Intialize and drive signals
	initial begin
		reset  = 1'b1;
		#10 
		reset  = 1'b0;
		#30
		reset  = 1'b1;
	end

    reg [8:0] state;
    reg reset_LFSR;
    wire done_LFSR, done_output;
    wire [12:0] rnd, rnd_output;

    assign rnd_output = ( rnd % 198 ) + 13'd1;
    assign done_output = done_LFSR; 

    always@(posedge clk_50) begin
        // Zero everything in reset
        if (~reset) begin
            state <= 9'd0;
            reset_LFSR <= 1'b1;
        end
        else begin
        
            if ( state == 9'd0 ) begin
                reset_LFSR <= 1'b0;
                if ( done_LFSR ) begin
                    state <= 9'd1;
                end
            end
            else if ( state == 9'd1 ) begin
                reset_LFSR <= 1'b1;
                state <= 9'd0;
            end
        end
    end

    LFSR random (
        .clock(clk_50),
        .reset(reset_LFSR),
        .rnd(rnd),
        .done(done_LFSR)
    );

endmodule

module LFSR (
    input clock,
    input reset,
    output [12:0] rnd,
	output done );

	reg [12:0] random, random_next, random_done;
	reg [3:0] count, count_next; //to keep track of the shifts

    wire feedback = random[12] ^ random[3] ^ random[2] ^ random[0]; 

	always @ (posedge clock or posedge reset) begin
		if (reset) begin
			random <= 13'hF; //An LFSR cannot have an all 0 state, thus reset to FF
			count <= 0;
		end
	 
		else begin
			random <= random_next;
			count <= count_next;
		end
	end

	always @ (*) begin
		random_next = random; //default state stays the same
		count_next = count;
	  
		random_next = {random[11:0], feedback}; //shift left the xor'd every posedge clock
		count_next = count + 1;

		if (count == 13) begin
			count = 0;
			random_done = random; //assign the random number to output after 13 shifts
		end
	 
	end

	assign rnd = random_done;
	assign done = ( count == 13 ) ? 1 : 0;

endmodule
