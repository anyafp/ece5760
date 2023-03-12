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
	wire signed [17:0] q [29:0], q_prev [29:0]; // read value
	reg signed [17:0] d [29:0], d_prev [29:0]; // write value
	reg [8:0] w_add [29:0], w_add_prev [29:0];
	reg [8:0] r_add [29:0], r_add_prev [29:0];
	reg [29:0] we, we_prev;

	// Drum node variables
	reg [17:0] rho_eff = 18'b0_00010000000000000;
	reg signed [17:0] u_up [29:0];
	reg signed [17:0] u [29:0];
	reg signed [17:0] u_down [29:0];
	reg signed [17:0] u_prev [29:0];
	wire signed [17:0] u_next [29:0];
	reg signed [17:0] u_bottom [29:0];

	reg [2:0] state [29:0];
	reg signed [17:0] output_val;
	reg signed [17:0] int_val;

    wire signed [17:0] out_init_ampl [29:0];

	// Index
	reg [8:0] j [29:0];
	reg [8:0] n [29:0];

	// Initializing node variables
	reg [17:0] incr = 18'b0_00000101000111101;

	genvar i;
	generate
		for ( i = 0; i < 30; i = i + 1 ) begin: cols

			M10K_512_20 m10k ( q[i], d[i], w_add[i], r_add[i], we[i], clk_50 );
			M10K_512_20 m10k_prev ( q_prev[i], d_prev[i], w_add_prev[i], r_add_prev[i], we_prev[i], clk_50 );
            pyramid_init init_vals ( .out(out_init_ampl[i]), .i(i[8:0]), .j(j[i]), .total_i(9'd29), .total_j(9'd29), .incr(incr) );
            
			drum node (
				.rho_eff( rho_eff ),
				.u( ( j[i] == 9'b0 ) ? u_bottom[i] : u[i] ),
				.u_right( ( i == 0 ) ? 18'd0 : ( j[i] == 9'b0 ) ? u_bottom[i-1] : u[i-1] ),
				.u_left( ( i == 29 ) ? 18'd0 : ( j[i] == 9'b0 ) ? u_bottom[i+1] : u[i+1] ),
				.u_up( ( j[i] == 9'd29 ) ? 18'b0 : u_up[i] ),
				.u_down( ( j[i] == 9'b0  ) ? 18'b0 : u_down[i] ),
				.u_prev( u_prev[i] ),
				.u_next( u_next[i] ) 
			);

			always @ ( posedge clk_50 ) begin

				if ( ~reset ) begin
					state[i] <= 3'd0;
				end
				else begin
					// STATE 0 (RESET)
					if ( state[i] == 3'd0 ) begin
						state[i] <= 3'd1; 
						j[i] <= 9'd0;
						n[i] <= 9'd0;
					end
					// STATE 1 (INIT)
					else if ( state[i] == 3'd1 ) begin

						// Once all nodes are initialized
						if ( j[i] == 9'd30 ) begin
							state[i] <= 3'd2;
							j[i] <= 9'd0;
							we[i] <= 1'b0;
						end
						else begin
							// initialize u and u_prev m10k blocks
                            we[i] <= 1'b1;
                            we_prev[i] <= 1'b1;
                            w_add[i] <= j[i];
                            w_add_prev[i] <= j[i];
                            r_add[i] <= j[i];
                            r_add_prev[i] <= j[i];
                            d[i] <= out_init_ampl[i];
                            d_prev[i] <= out_init_ampl[i];

                            if ( j[i] == 9'd0 ) u_bottom[i] <= out_init_ampl[i];
							j[i] <= j[i] + 9'd1;
							state[i] <= 3'd1;
						end
					end
					// STATE 2 (Set up read address)
					else if ( state[i] == 3'd2 ) begin

						// If not at top
						if ( j[i] < 9'd29 ) begin
							r_add[i] <= j[i] + 9'd1; // read u_up M10K
							we[i] <= 0;
						end

						r_add_prev[i] <= j[i]; // read u_prev M10K 
						we_prev[i] <= 0;

						state[i] <= 3'd3;
					
					end
					// STATE 3 (Wait for M10K to see read addr)
					else if ( state[i] == 3'd3 ) begin

						state[i] <= 3'd4;

					end
					// STATE 4 (Setting inputs)
					else if ( state[i] == 3'd4 ) begin

					    // If not at top
						if ( j[i] < 9'd29 ) u_up[i] <= q[i];

						u_prev[i] <= q_prev[i];

						state[i] <= 3'd5;

					end
					// STATE 5 (Get u_next and write and set up next row)
					else if ( state[i] == 3'd5 ) begin

						we[i] <= 1'b1;
						w_add[i] <= j[i];
						d[i] <= u_next[i];

						we_prev[i] <= 1'b1;
						w_add_prev[i] <= j[i];
						d_prev[i] <= ( j[i] == 9'd0 ) ? u_bottom[i] : u[i];

						if ( j[i] == 9'd15 && i == 15 ) int_val <= u[i];
						if ( j[i] == 9'd0 ) u_bottom[i] <= u_next[i];

						// Set up next row if not at top
						if ( j[i] < 9'd29 ) begin
							u[i] <= u_up[i];
							u_down[i] <= ( j[i] == 9'd0 ) ? u_bottom[i] : u[i];
							j[i] <= j[i] + 9'd1;
							state[i] <= 3'd2;
						end
						else begin
							n[i] <= n[i] + 9'd1;
							j[i] <= 9'd0;
							state[i] <= 3'd6;
						end
					end
					// STATE 6 (Output value)
					else if ( state[i] == 3'd6 ) begin
						if ( i == 0 ) output_val <= int_val;
						state[i] <= 3'd2;
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

//////////////////////////////////////////////////
//// calc initial amplitude ///////////
//////////////////////////////////////////////////

module pyramid_init (out, i, j, total_i, total_j, incr);
    output signed [17:0] out;
    input [8:0] i;
    input [8:0] j;
    input [8:0] total_i;
    input [8:0] total_j;
    input [17:0] incr;

    wire [8:0] int_i, int_j, int_out;

    assign int_i = ( ( total_i - i ) >= i ) ? i : ( total_i - i );
    assign int_j = ( ( total_j - j ) >= j ) ? j : ( total_j - j );

    assign int_out = ( int_i >= int_j ) ? int_j : int_i;

    assign out = ( int_out + 9'd1 ) * incr;
endmodule
