`timescale 1ns/1ns

module testbench();
	
	reg clk_50, reset, key2, key3;

	//Initialize clocks and index
	initial begin
		clk_50   =  1'b0;
        key2 = 0;
        key3 = 0;
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
        #1000
        key2 = 1;
        #20
        key2 = 0;
	end

    wire [31:0] sram_readdata ;
    reg [31:0] data_buffer, sram_writedata ;
    reg [7:0] sram_address; 
    reg sram_write ;
    wire sram_clken = 1'b1;
    wire sram_chipselect = 1'b1;
    reg [7:0] state = 8'd10;

    // rectangle corners
    reg [9:0] x1, y1, x2, y2 ;
    reg [31:0] timer ; // may need to throttle write-rate
    //=======================================================
    // Controls for VGA memory
    //=======================================================
    wire [31:0] vga_out_base_address = 32'h0000_0000 ;  // vga base addr
    reg [7:0] vga_sram_writedata ;
    reg [31:0] vga_sram_address; 
    reg vga_sram_write ;
    wire vga_sram_clken = 1'b1;
    wire vga_sram_chipselect = 1'b1;
    //=======================================================
    // pixel address is
    reg [9:0] vga_x_cood, vga_y_cood ;
    reg [7:0] color_reg ;

    //=======================================================

    reg  signed [26:0] c_r_1, c_i_1;
    wire signed [26:0] incr_x, incr_y;
    wire        [15:0] max_iter, total_iter_1;
    wire        [1:0]  done; 
    reg         [1:0]  reset_mandel;
    reg         [ 4:0] zoom = 0;


    assign max_iter = 16'd1000;

    // genvar i;
    // generate
    //     for (i = 1; i < 2; i = i + 1) begin : iterators // <-- example block name
    //         mandelbrot iter1 (
    //             .clock(clk_50),
    //             .reset(reset[i]),
    //             .c_r(c_r_1[]),
    //             .c_i(c_i_1),
    //             .max_iter(max_iter),
    //             .total_iter(total_iter_1), 
    //             .done(done_1)
    //         );
    //     end 
    // endgenerate

    assign incr_x = 27'sb0000_00000001001100110011001 >> zoom;
    assign incr_y = 27'sb0000_00000001000100010001000 >> zoom;

    always @(posedge clk_50) begin

        // reset state machine and read/write controls
        if (~reset) begin
            state <= 0 ;
            vga_sram_write <= 1'b0 ; // set to on if a write operation to bus
            sram_write <= 1'b0 ;
            timer <= 0;
        end

        else if (key2) begin
            if ( zoom < 5'd16 ) begin
                zoom <= zoom + 1;
                state <= 0 ;
                vga_sram_write <= 1'b0 ; // set to on if a write operation to bus
                sram_write <= 1'b0 ;
                timer <= 0;
            end
        end 
        else if (key3) begin
            if ( zoom > 5'd0 ) begin
                zoom <= zoom - 1;
                state <= 0 ;
                vga_sram_write <= 1'b0 ; // set to on if a write operation to bus
                sram_write <= 1'b0 ;
                timer <= 0;
            end
        end

        
        else begin
            // general purpose tick counter
            timer <= timer + 1;
            if (state == 8'd0) begin
                vga_x_cood <= 0; 
                vga_y_cood <= 0;
                c_r_1 <= -27'sb0010_00000000000000000000000;
                c_i_1 <= 27'sb0001_00000000000000000000000;
                state <= 8'd1;
                reset_1 <= 0;
                
                // end vga write
                vga_sram_write <= 1'b0;
                // signal the HPS we are done
                sram_address <= 8'd0 ;
                sram_writedata <= 32'b1 ;
                sram_write <= 1'b1 ;
            end
            
            if (state == 8'd1) begin
                reset_1 <= 1;
                if (~done_1) begin
                    state <= 8'd1;
                end
                else begin
                    reset_1 <= 0;
                    state <= 8'd2;
                end
            end
            
            if (state == 8'd2) begin
                
                if (total_iter_1 >= max_iter) begin
                color_reg <= 8'b_000_000_00 ; // black
                end
                else if (total_iter_1 >= (max_iter >>> 1)) begin
                color_reg <= 8'b_011_001_00 ; // white
                end
                else if (total_iter_1 >= (max_iter >>> 2)) begin
                color_reg <= 8'b_011_001_00 ;
                end
                else if (total_iter_1 >= (max_iter >>> 3)) begin
                color_reg <= 8'b_101_010_01 ;
                end
                else if (total_iter_1 >= (max_iter >>> 4)) begin
                color_reg <= 8'b_011_001_01 ;
                end
                else if (total_iter_1 >= (max_iter >>> 5)) begin
                color_reg <= 8'b_001_001_01 ;
                end
                else if (total_iter_1 >= (max_iter >>> 6)) begin
                color_reg <= 8'b_011_010_10 ;
                end
                else if (total_iter_1 >= (max_iter >>> 7)) begin
                color_reg <= 8'b_010_100_10 ;
                end
                else if (total_iter_1 >= (max_iter >>> 8)) begin
                color_reg <= 8'b_010_100_10 ;
                end
                else begin
                color_reg <= 8'b_010_100_10 ;
                end
                
                //draw//
                vga_sram_write <= 1'b1;
                // compute address
                vga_sram_address <= vga_out_base_address + {22'b0, vga_x_cood} + ({22'b0,vga_y_cood}*640) ; 
                // data
                vga_sram_writedata <= color_reg  ;
                
                vga_x_cood <= vga_x_cood + 1;
                c_r_1 <= c_r_1 + incr_x;
                
                if (vga_x_cood > 10'd639) begin
                    vga_x_cood <= 0;
                    c_r_1 <= -27'sb0010_00000000000000000000000;
                    vga_y_cood <= vga_y_cood + 1;
                    c_i_1 <= c_i_1 - incr_y;
                end
                
                if (vga_y_cood > 10'd479) begin
                    state <= 8'd3;
                end
                else begin
                    state <= 8'd1;
                end
            end
            
            if (state == 8'd3) begin
                // end vga write
                vga_sram_write <= 1'b0;
                // signal the HPS we are done
                sram_address <= 8'd0 ;
                sram_writedata <= 32'b0 ;
                sram_write <= 1'b1 ;
                state <= 8'd3;
            end
        end
        
        
    end

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
    done);

    input   clock, reset;
    input   signed [26:0] c_r, c_i;
    input [15:0] max_iter;
    output [15:0] total_iter;
    output done;

    wire signed [26:0] z_r_sq, z_i_sq, z_r_i;
    reg signed [26:0] z_r, z_i; 
    wire signed [26:0] z_r_temp, z_i_temp;
    reg [15:0] temp_iter;
    wire int_done_r, int_done_i, int_done;


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
    assign int_done_r = ( ( z_r ) > 27'sb0010_00000000000000000000000 ) || ( ( z_r ) < -27'sb0010_00000000000000000000000 );
    assign int_done_i = ( ( z_i ) > 27'sb0010_00000000000000000000000 ) || ( ( z_i ) < -27'sb0010_00000000000000000000000 );
    assign int_done = int_done_r | int_done_i;

    assign done = ( int_done == 1 ) || ( ( z_r_sq + z_i_sq ) > 27'sb0100_00000000000000000000000 ) || ( temp_iter == max_iter );
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
