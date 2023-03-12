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
	reg signed [17:0] u_up;
	reg signed [17:0] u;
	reg signed [17:0] u_down;
	reg signed [17:0] u_prev;
	wire signed [17:0] u_next;
	reg signed [17:0] u_bottom;

	reg [2:0] state;
	reg signed [17:0] output_val;
	reg signed [17:0] int_val;
	reg signed [17:0] init_val = 18'b0_00000011011010011;

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
				.u( ( j == 18'b0 ) ? u_bottom : u ),
				.u_right( 18'b0 ),
				.u_left( 18'b0 ),
				.u_up( ( j == 18'd29 ) ? 18'b0 : u_up ),
				.u_down( ( j == 18'b0  ) ? 18'b0 : u_down ),
				.u_prev( u_prev ),
				.u_next( u_next ) 
			);

			always @ ( posedge clk_50 ) begin

				if ( ~reset ) begin
					state <= 3'd0;
				end
				else begin
					// STATE 0 (RESET)
					if ( state == 3'd0 ) begin
						state <= 3'd1; 
						j <= 9'd0;
						n <= 9'd0;
					end
					// STATE 1 (INIT)
					else if ( state == 3'd1 ) begin

						// Once all nodes are initialized
						if ( j == 9'd30 ) begin
							state <= 3'd2;
							j <= 9'd0;
							we <= 1'b0;
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
								d <= init_val;
								d_prev <= init_val;
								if ( j == 9'd0 ) u_bottom <= init_val;
								init_val <= init_val + incr;
							end
							else begin
								init_val <= init_val - incr;
								we <= 1'b1;
								we_prev <= 1'b1;
								w_add <= j;
								w_add_prev <= j;
								r_add <= j;
								r_add_prev <= j;
								d <= init_val;
								d_prev <= init_val;
							end
							j <= j + 9'd1;
							state <= 3'd1;
						end
					end
					// STATE 2 (Set up read address)
					else if ( state == 3'd2 ) begin

						// If not at top
						if ( j < 9'd29 ) begin
							r_add <= j + 9'd1; // read u_up M10K
							we <= 0;
						end

						r_add_prev <= j; // read u_prev M10K 
						we_prev <= 0;

						state <= 3'd3;
					
					end
					// STATE 3 (Wait for M10K to see read addr)
					else if ( state == 3'd3 ) begin

						state <= 3'd4;

					end
					// STATE 4 (Setting inputs)
					else if ( state == 3'd4 ) begin

					    // If not at top
						if ( j < 9'd29 ) u_up <= q;

						u_prev <= q_prev;

						state <= 3'd5;

					end
					// STATE 5 (Get u_next and write and set up next row)
					else if ( state == 3'd5 ) begin

						we <= 1'b1;
						w_add <= j;
						d <= u_next;

						we_prev <= 1'b1;
						w_add_prev <= j;
						d_prev <= ( j == 9'd0 ) ? u_bottom : u;

						if ( j == 9'd15 ) int_val <= u;
						if ( j == 9'd0 ) u_bottom <= u_next;

						// Set up next row if not at top
						if ( j < 9'd29 ) begin
							u <= u_up;
							u_down <= ( j == 9'd0 ) ? u_bottom : u;
							j <= j + 9'd1;
							state <= 3'd2;
						end
						else begin
							n <= n + 9'd1;
							j <= 9'd0;
							state <= 3'd6;
						end
					end
					// STATE 6 (Output value)
					else if ( state == 3'd6 ) begin
						output_val <= int_val;
						state <= 3'd2;
					end
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
