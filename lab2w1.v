`timescale 1ns/1ns

module testbench();
	
	reg clk_50, reset;

    wire [15:0] total_iter_out;
    wire done_out;
    wire signed [26:0] c_r, c_i;
    wire [15:0] max_iter;

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

    assign c_r = 27'b0000_01100000000000000000000;
    assign c_i = -27'b0000_01100000000000000000000;
    assign max_iter  = 16'd1000;

    // Instantiation of Design Under Test
	mandelbrot DUT (
        .clock(clk_50),
        .reset(reset),
        .c_r(c_r),
        .c_i(c_i),
        .max_iter(max_iter),
        .total_iter(total_iter_out), 
        .done(done_out)
    );

endmodule

//////////////////////////////////////////////////
//// mandelbrot //////////////////////////////////
//////////////////////////////////////////////////

module mandelbrot (
    clock,
    reset,
    c_r,
    c_i,
    max_iter,
    total_iter, 
    done );

    input   clock, reset;
    input   signed [26:0] c_r, c_i;
    input [15:0] max_iter;
    output [15:0] total_iter;
    output done;

    reg signed [26:0] z_r, z_i; 
    wire signed [26:0] z_r_sq, z_i_sq, z_r_i, z_r_temp, z_i_temp; 
    reg [15:0] temp_iter;


	always @ (posedge clock) begin
		if (reset == 0) begin
            z_r <= 0; 
            z_i <= 0;
            temp_iter <= 0;
        end
		else if (done == 0) begin
			z_r <= z_r_temp;
            z_i <= z_i_temp;
            temp_iter <= temp_iter + 1;
        end
	end

    signed_mult sign_mult_z_r(.out(z_r_sq), .a(z_r), .b(z_r));
    signed_mult sign_mult_z_i(.out(z_i_sq), .a(z_i), .b(z_i));
    signed_mult sign_mult_z_i_r(.out(z_r_i), .a(z_r), .b(z_i));

    assign z_r_temp = z_r_sq - z_i_sq + c_r;
    assign z_i_temp = ( z_r_i <<< 1 ) + c_i;

    // check each one more than 2
    assign done = ( z_r_sq + z_i_sq ) > 27'b0100_00000000000000000000000 ? 1 : ( ( temp_iter == max_iter ) ? 1 : 0 );
    assign total_iter = temp_iter;

endmodule

//////////////////////////////////////////////////
//// signed mult of 4.23 format 2'comp ///////////
//////////////////////////////////////////////////

module signed_mult (out, a, b);
	output 	signed  [26:0]	out;
	input 	signed	[26:0] 	a;
	input 	signed	[26:0] 	b;
	// intermediate full bit length 8.46
	wire 	signed	[53:0]	mult_out;
	assign mult_out = a * b;
	// select bits for 4.23 fixed point
	assign out = { mult_out[53], mult_out[48:23] };

endmodule
