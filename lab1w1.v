`timescale 1ns/1ns

module testbench();
	
	reg clk_50, reset;
	
	// reg [31:0] index;
    wire signed [26:0] testbench_out_x, testbench_out_y, testbench_out_z;
    reg signed  [26:0] sig_val, x_val, y_val, z_val, dt_val, beta_val, rho_val;

	//Initialize clocks and index
	initial begin
		clk_50 = 1'b0;
		// clk_25 = 1'b0;
		// index  = 32'd0;
        dt_val   =  27'b0000000_00000001000000000000;
        x_val    = -27'b0000001_00000000000000000000;
        y_val    =  27'b0000010_00000000000000000000;
        z_val    =  27'b0011001_00000000000000000000;
        sig_val  =  27'b0001010_00000000000000000000;
        beta_val =  27'b0000010_10110000000000000000;
        rho_val  =  27'b0011100_00000000000000000000;
        
	end
	
	// Toggle the clocks
	always begin
		#10
		clk_50  = !clk_50;
	end
	
	// always begin
	// 	#20
	// 	clk_25  = !clk_25;
	// end
	
	// Intialize and drive signals
	initial begin
		reset  = 1'b0;
		#10 
		reset  = 1'b1;
		#30
		reset  = 1'b0;
	end
	
	// // Increment index
	// always @ (posedge clk_50) begin
	// 	index  <= index + 32'd1;
	// end

	//Instantiation of Device Under Test
	// hook up the sine wave generators
    // DDS DUT   (.clock(clk_50), 
    //     .reset(reset),
	// 			.increment({18'h02000, 14'b0}), 
	// 			.phase(8'd0),
	// 			.sine_out(testbench_out));

    // Instantiation of Design Under Test
	DDA DUT (
        .clock(clk_50), 
        .reset(reset), 
        .dt_init(dt_val),
        .x_init(x_val),
        .y_init(y_val),
        .z_init(z_val),
        .sigma_init(sig_val),
        .rho_init(rho_val),
        .beta_init(beta_val),
        .out_x(testbench_out_x),
        .out_y(testbench_out_y),
        .out_z(testbench_out_z)
    );

endmodule

/////////////////////////////////////////////////
//// DDA ////////////////////////////////////////
/////////////////////////////////////////////////

module DDA (
    clock, 
    reset, 
    dt_init, 
    x_init, 
    y_init, 
    z_init,
    sigma_init,
    rho_init,
    beta_init,
    out_x,
    out_y,
    out_z );

    input  signed clock, reset;
    input  signed [26:0] dt_init, x_init, y_init, z_init, sigma_init, rho_init, beta_init;
    output signed [26:0] out_x, out_y, out_z;

    wire [26:0] int_out_x, int_out_y, int_out_z, dxdt_out, dydt_out, dzdt_out;

    dxdt dxdt_inst (
        .out(dxdt_out), 
        .sigma(sigma_init),
        .x_(int_out_x),
        .y_(int_out_y),
        .dt(dt_init)
    );

    dydt dydt_inst (
        .out(dydt_out), 
        .rho(rho_init),
        .x_(int_out_x),
        .y_(int_out_y),
        .z_(int_out_z),
        .dt(dt_init)
    );

    dzdt dzdt_inst (
        .out(dzdt_out), 
        .beta(beta_init),
        .x_(int_out_x),
        .y_(int_out_y),
        .z_(int_out_z),
        .dt(dt_init)
    );

    integrator int_inst_x (
        .out(int_out_x), 
        .funct(dxdt_out), 
        .InitialOut(x_init),
        .clk(clock),
        .reset(reset)
    );

    integrator int_inst_y (
        .out(int_out_y), 
        .funct(dydt_out), 
        .InitialOut(y_init),
        .clk(clock),
        .reset(reset)
    );

    integrator int_inst_z (
        .out(int_out_z), 
        .funct(dzdt_out), 
        .InitialOut(z_init),
        .clk(clock),
        .reset(reset)
    );

    assign out_x = int_out_x;
    assign out_y = int_out_y;
    assign out_z = int_out_z;

endmodule

/////////////////////////////////////////////////
//// funct: dx*dt ///////////////////////////////
/////////////////////////////////////////////////

module dxdt (out, sigma, x_, y_, dt);
	output signed [26:0] out;  // fed into integrator
	input signed  [26:0] sigma;
	input signed  [26:0] x_, y_, dt;
	
	wire signed	  [26:0] mult_out1, mult_out2, y_sub_x;

    assign y_sub_x = y_ - x_;
	signed_mult sign_mult_sigma (.out(mult_out1), .a(sigma), .b(y_sub_x));
    signed_mult sign_mult_dt    (.out(mult_out2), .a(mult_out1), .b(dt));
    assign out = mult_out2;

endmodule

/////////////////////////////////////////////////
//// funct: dy*dt ///////////////////////////////
/////////////////////////////////////////////////

module dydt(out, rho, x_, y_, z_, dt);
	output signed [26:0] out;  // fed into integrator
	input signed  [26:0] rho;
	input signed  [26:0] x_, y_, z_, dt;
	
	wire signed	  [26:0] mult_out1, mult_out2, out_sub_y, rho_sub_z;

    assign rho_sub_z = rho - z_;
	signed_mult sign_mult_x (.out(mult_out1), .a(x_), .b(rho_sub_z));
    assign out_sub_y = mult_out1 - y_;
    signed_mult sign_mult_dt (.out(mult_out2), .a(out_sub_y), .b(dt));
    assign out = mult_out2;

endmodule

/////////////////////////////////////////////////
//// funct: dz*dt ///////////////////////////////
/////////////////////////////////////////////////

module dzdt(out, beta, x_, y_, z_, dt);
	output signed [26:0] out;  // fed into integrator
	input signed  [26:0] beta;
	input signed  [26:0] x_, y_, z_, dt;
	
	wire signed	  [26:0] mult_out, mult_x_y, mult_beta_z, out_sub;

	signed_mult sign_mult_x_y (.out(mult_x_y), .a(x_), .b(y_));
    signed_mult sign_mult_beta_z (.out(mult_beta_z), .a(beta), .b(z_));
    assign out_sub = mult_x_y - mult_beta_z;
    signed_mult sign_mult_dt (.out(mult_out), .a(out_sub), .b(dt));
    assign out = mult_out;

endmodule

/////////////////////////////////////////////////
//// general integrator /////////////////////////
/////////////////////////////////////////////////

module integrator( out, funct, InitialOut, clk, reset );
	output signed [26:0] out; 		//the state variable V
	input signed [26:0] funct;      //the dV/dt function
	input clk, reset;
	input signed [26:0] InitialOut;  //the initial state variable V
	
	wire signed	[26:0] out, v1new ;
	reg signed	[26:0] v1 ;
	
	always @ (posedge clk) 
	begin
		if (reset==1) //reset	
			v1 <= InitialOut ; // 
		else 
			v1 <= v1new ;	
	end
	assign v1new = v1 + funct ;
	assign out = v1 ;
endmodule

//////////////////////////////////////////////////
//// signed mult of 7.20 format 2'comp////////////
//////////////////////////////////////////////////

module signed_mult (out, a, b);
	output 	signed  [26:0]	out;
	input 	signed	[26:0] 	a;
	input 	signed	[26:0] 	b;
	// intermediate full bit length
	wire 	signed	[53:0]	mult_out;
	assign mult_out = a * b;
	// select bits for 7.20 fixed point
	assign out = {mult_out[53], mult_out[45:20]};
endmodule
