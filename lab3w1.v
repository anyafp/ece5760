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
	
	// M10K variables
	wire signed [17:0] q, q_prev; // read value
	reg signed [17:0] d, d_prev; // write value
	reg [8:0] w_add, w_add_prev;
	reg [8:0] r_add, r_add_prev;
	reg we, we_prev;

	// Drum node variables
	reg [17:0] rho_eff = 18'b0_00010000000000000;
	reg signed [17:0] u_up = 18'b0;
	reg signed [17:0] u;
	reg signed [17:0] u_down = 18'b0;
	reg signed [17:0] u_prev;
	wire signed [17:0] u_next;
	reg signed [17:0] u_bottom;

	reg [2:0] state;
	reg signed [17:0] output_val;

	// Index
	reg [8:0] j;
	reg [8:0] n;

	// Initializing node variables
	reg [17:0] incr = 18'b0_00000011011010011;

	genvar i;
	generate
		for ( i = 0; i < 1; i = i + 1 ) begin: cols

			M10K_512_20 m10k ( q, d, w_add, r_add, we, clk_50 );
			M10K_512_20 m10k_prev ( q_prev, d_prev, w_add_prev, r_add_prev, we_prev, clk_50 );

			// drum node (
			//     .clk( clk ),
			//     .rho_eff( rho_eff ),
			//     .u( u[i] ),
			//     .u_right( ( i == 0 ) ? 0 : u[i-1] ),
			//     .u_left( ( i == 0 ) ? 0 : u[i+1] ),
			//     .u_up( u_up[i] ),
			//     .u_down( u_down[i] ),
			//     .u_prev( u_prev[i] ),
			//     .u_next( u_next[i] ) 
			// );

			drum node (
				.rho_eff( rho_eff ),
				.u( u ),
				.u_right( 18'b0 ),
				.u_left( 18'b0 ),
				.u_up( u_up ),
				.u_down( u_down ),
				.u_prev( u_prev ),
				.u_next( u_next ) 
			);

			always @ ( posedge clk_50 ) begin


				if ( ~reset ) begin
					state <= 3'd0;
				end
				else 
					// STATE 0 (RESET)
					if ( state == 3'd0 ) begin
						state <= 3'd1; 
						j <= 0;
						n <= 0; 
						d <= 0;
						d_prev <= 0; 
					end
					// STATE 1 (INIT)
					else if ( state == 3'd1 ) begin
						// bottom node values
						if ( j == 9'd1 ) begin
								u_bottom <= d;
								u_prev <= d;
								u <= d;
						end

						// Once all nodes are initialized
						if ( j == 9'd30 ) begin
							state <= 3'd2;
							j <= 0;
							we <= 1'b0;
							w_add <= 1;
							r_add <= 1;
							d <= 0;
						end
						else begin
							// initialize u and u_prev m10k blocks
							if ( j < 9'd15 ) begin
								we <= 1'b1;
								we_prev <= 1'b1;
								w_add <= j;
								w_add_prev <= j;
								r_add <= j;
								r_add_prev <= j;
								d <= d + incr;
								d_prev <= d_prev + incr;
							end
							else begin
								we <= 1'b1;
								we_prev <= 1'b1;
								w_add <= j;
								w_add_prev <= j;
								r_add <= j;
								r_add_prev <= j;
								d <= d - incr;
								d_prev <= d_prev - incr;
							end
							j <= j + 1;
							state <= 3'd1;
						end

					end
					// STATE 2 (COMPUTE)
					else if ( state == 3'd2 ) begin

						if ( j == 1 ) begin
							u_bottom <= u_next; 
						end

						// write m10k prev
						we_prev <= 1'b1;
						w_add_prev <= j;
						d_prev <= u;

						// write m10k
						we <= 1'b1;
						w_add <= j;
						d <= u_next;

						u_down <= ( j == 9'd0 ) ? 0 : u;
						u <= ( j == 9'd0 ) ? u_bottom : u_up;
						u_up <= (j == 9'd29) ? 0 : q;

						// Done with all rows
						if ( j == 9'd29 ) begin
							state <= 3'd3;
							j <= 0;
							r_add <= 9'd15;
						end
						else begin
							j <= j + 1;
							state <= 3'd2;
							r_add <= j + 1;
						end
					end
					// STATE 3 (AUDIO)
					else if ( state == 3'd3 ) begin
						n <= n + 8'd1;
						output_val <= q;
						state <= 3'd2;
					end
			end


		end
	endgenerate
endmodule


module drum (
    rho_eff,
    u,
    u_right,
    u_left,
    u_up,
    u_down,
    u_prev,
    u_next );

    input         [17:0] rho_eff;
    input  signed [17:0] u;
    input  signed [17:0] u_right;
    input  signed [17:0] u_left;
    input  signed [17:0] u_up;
    input  signed [17:0] u_down;
    input  signed [17:0] u_prev;
    output signed [17:0] u_next;

    wire   signed [17:0] int_sum, int_sum_rho, int_val;

    assign int_sum = u_right + u_left + u_down + u_up - ( u <<< 2 );
    signed_mult mult_sum_rho(.out(int_sum_rho), .a(int_sum), .b(rho_eff));
    assign int_val = int_sum_rho + (u <<< 1) - u_prev + (u_prev >>> 9);

    assign u_next = int_val - (int_val >>> 9);

endmodule

//////////////////////////////////////////////////
//// m10k ///////////
//////////////////////////////////////////////////

module M10K_512_20( 
    output reg [17:0] q, // data read from block
    input [17:0] d,      // data to write to block
    input [8:0] write_address, read_address,
    input we, clk );

	// force M10K ram style
    reg [17:0] mem [511:0]  /* synthesis ramstyle = "no_rw_check, M10K" */;
	 
    always @ (posedge clk) begin
        if (we) begin
            mem[write_address] <= d;
        end
        q <= mem[read_address]; // q doesn't get d in this clock cycle
    end
endmodule

//////////////////////////////////////////////////
//// signed mult of 1.17 format 2'comp ///////////
//////////////////////////////////////////////////

module signed_mult (out, a, b);
	output 	signed  [17:0]	out;
	input 	signed	[17:0] 	a;
	input 	signed	[17:0] 	b;
	// intermediate full bit length 2.34
	wire 	signed	[35:0]	mult_out;
	assign mult_out = a * b;
	// select bits for 1.17 fixed point
	assign out = { mult_out[35], mult_out[33:17] };

endmodule
