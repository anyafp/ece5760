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

    wire [9:0] box_size;
    reg [9:0] x_, y_;
    reg signed [9:0] vx, vy;
    wire [9:0] x_next, x_prev, y_next, y_prev;
    wire signed [9:0] vx_next, vx_prev, vy_next, vy_prev;

    assign box_size = 10'd200;

    particle particle1 (
        .x_prev(x_prev),
        .y_prev(y_prev),
        .vx_prev(vx_prev),
        .vy_prev(vy_prev),
        .box_length(box_size),
        .x_next(x_next),
        .y_next(y_next),
        .vx_next(vx_next),
        .vy_next(vy_next)
    );

    always @ (posedge clk_50) begin

        if (~reset) begin
            x_ <= 10'd30;
            y_ <= 10'd30;
            vx <= 10'd1;
            vy <= 10'd1;
        end
        else begin
            x_ <= x_next;
            y_ <= y_next;
            vx <= vx_next;
            vy <= vy_next;
        end
    end

    assign x_prev  = x_;
    assign y_prev  = y_;
    assign vx_prev = vx;
    assign vy_prev = vy;
    
endmodule

//////////////////////////////////////////////////
//// particle position update ////////////////////
//////////////////////////////////////////////////

module particle (
    x_prev,
    y_prev,
    vx_prev,
    vy_prev,
    box_length,
    x_next,
    y_next,
    vx_next,
    vy_next );

    input  [9:0] x_prev, y_prev, box_length;
    input signed [9:0] vx_prev, vy_prev; 
    output [9:0] x_next, y_next;
    output signed [9:0] vx_next, vy_next;

    assign vx_next = ( x_prev > box_length || x_prev + vx_prev <= 10'b0 ) ? -vx_prev : vx_prev;
    assign vy_next = ( y_prev > box_length || y_prev + vy_prev <= 10'b0 ) ? -vy_prev : vy_prev;

    // if ( x_prev > box_length || x_prev < 10'b0 )
    //     assign vx_next = -vx_prev;
    // else 
    //     assign vx_next = vx_prev;
    
    // if ( y_prev > box_length || y_prev < 10'b0 )
    //     assign vy_next = -vy_prev;
    // else
    //     assign vy_next = vy_prev;

    assign x_next = x_prev + vx_next;
    assign y_next = y_prev + vy_next;
    
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

/*

//=======================================================
// SRAM/VGA Iterator state machine
//=======================================================
// --Check for sram address=0 nonzero, which means that
//   HPS wrote some new data.
//
// --clear sram address=0 to signal HPS
//=======================================================
// Controls for Qsys sram slave exported in system module
//=======================================================
wire [31:0] sram_readdata ;
reg [31:0] data_buffer, sram_writedata ;
reg [7:0] sram_address; 
reg sram_write ;
wire sram_clken = 1'b1;
wire sram_chipselect = 1'b1;

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
reg [9:0] vga_x_cood [24:0];
reg [9:0] vga_y_cood [24:0];
reg [7:0] color_reg  [24:0];

//=======================================================

wire signed [26:0] incr_x, incr_y;
wire        [15:0] max_iter;
reg         [ 4:0] zoom = 0;
reg 					 pressed = 0;

reg  signed [26:0] c_r [24:0];
reg  signed [26:0] c_i [24:0];
wire        [15:0] total_iter [24:0];
wire        [24:0] done; 
reg         [24:0] mreset = 2'b0;
reg         [ 7:0] state [24:0];

assign max_iter = 16'd1000;
assign incr_x = 27'sb0000_00000001001100110011001;
assign incr_y = 27'sb0000_00000001000100010001000;

reg [24:0] draw_flag = 2'b0;
reg [24:0] done_flag = 2'b0;

reg [24:0] box1flag = 25'b0;
reg [24:0] box2flag = 25'b0;

//=======================================================
// Arbiter
//=======================================================

always @(posedge clk_50) begin
	casex (done_flag)
		25'bxxxxxxxxxxxxxxxxxxxxxxxx1: begin
			//draw//
			//vga_sram_write <= 1'b1;
			// compute address
			vga_sram_address <= vga_out_base_address + {22'b0, vga_x_cood[0]} + ({22'b0,vga_y_cood[0]}*640) ; 
			// data
			vga_sram_writedata <= color_reg[0];
			draw_flag <= 25'd1;
		end
		25'bxxxxxxxxxxxxxxxxxxxxxxx10: begin
			//draw//
			//vga_sram_write <= 1'b1;
			// compute address
			vga_sram_address <= vga_out_base_address + {22'b0, vga_x_cood[1]} + ({22'b0,vga_y_cood[1]}*640) ; 
			// data
			vga_sram_writedata <= color_reg[1];
			draw_flag <= 25'd2;
		end
		25'bxxxxxxxxxxxxxxxxxxxxxx100: begin
			//draw//
			//vga_sram_write <= 1'b1;
			// compute address
			vga_sram_address <= vga_out_base_address + {22'b0, vga_x_cood[2]} + ({22'b0,vga_y_cood[2]}*640) ; 
			// data
			vga_sram_writedata <= color_reg[2];
			draw_flag <= 25'd4;
		end
		25'bxxxxxxxxxxxxxxxxxxxxx1000: begin
			//draw//
			//vga_sram_write <= 1'b1;
			// compute address
			vga_sram_address <= vga_out_base_address + {22'b0, vga_x_cood[3]} + ({22'b0,vga_y_cood[3]}*640) ; 
			// data
			vga_sram_writedata <= color_reg[3];
			draw_flag <= 25'd8;
		end
		25'bxxxxxxxxxxxxxxxxxxxx10000: begin
			//draw//
			//vga_sram_write <= 1'b1;
			// compute address
			vga_sram_address <= vga_out_base_address + {22'b0, vga_x_cood[4]} + ({22'b0,vga_y_cood[4]}*640) ; 
			// data
			vga_sram_writedata <= color_reg[4];
			draw_flag <= 25'd16;
		end
		25'bxxxxxxxxxxxxxxxxxxx100000: begin
			//draw//
			//vga_sram_write <= 1'b1;
			// compute address
			vga_sram_address <= vga_out_base_address + {22'b0, vga_x_cood[5]} + ({22'b0,vga_y_cood[5]}*640) ; 
			// data
			vga_sram_writedata <= color_reg[5];
			draw_flag <= 25'd32;
		end
		25'bxxxxxxxxxxxxxxxxxx1000000: begin
			//draw//
			//vga_sram_write <= 1'b1;
			// compute address
			vga_sram_address <= vga_out_base_address + {22'b0, vga_x_cood[6]} + ({22'b0,vga_y_cood[6]}*640) ; 
			// data
			vga_sram_writedata <= color_reg[6];
			draw_flag <= 25'd64;
		end
		25'bxxxxxxxxxxxxxxxxx10000000: begin
			//draw//
			//vga_sram_write <= 1'b1;
			// compute address
			vga_sram_address <= vga_out_base_address + {22'b0, vga_x_cood[7]} + ({22'b0,vga_y_cood[7]}*640) ; 
			// data
			vga_sram_writedata <= color_reg[7];
			draw_flag <= 25'd128;
		end
		25'bxxxxxxxxxxxxxxxx100000000: begin
			//draw//
			//vga_sram_write <= 1'b1;
			// compute address
			vga_sram_address <= vga_out_base_address + {22'b0, vga_x_cood[8]} + ({22'b0,vga_y_cood[8]}*640) ; 
			// data
			vga_sram_writedata <= color_reg[8];
			draw_flag <= 25'd256;
		end
		25'bxxxxxxxxxxxxxxx1000000000: begin
			//draw//
			//vga_sram_write <= 1'b1;
			// compute address
			vga_sram_address <= vga_out_base_address + {22'b0, vga_x_cood[9]} + ({22'b0,vga_y_cood[9]}*640) ; 
			// data
			vga_sram_writedata <= color_reg[9];
			draw_flag <= 25'd512;
		end
		25'bxxxxxxxxxxxxxx10000000000: begin
			//draw//
			//vga_sram_write <= 1'b1;
			// compute address
			vga_sram_address <= vga_out_base_address + {22'b0, vga_x_cood[10]} + ({22'b0,vga_y_cood[10]}*640) ; 
			// data
			vga_sram_writedata <= color_reg[10];
			draw_flag <= 25'd1024;
		end
		25'bxxxxxxxxxxxxx100000000000: begin
			//draw//
			//vga_sram_write <= 1'b1;
			// compute address
			vga_sram_address <= vga_out_base_address + {22'b0, vga_x_cood[11]} + ({22'b0,vga_y_cood[11]}*640) ; 
			// data
			vga_sram_writedata <= color_reg[11];
			draw_flag <= 25'd2048;
		end
		25'bxxxxxxxxxxxx1000000000000: begin
			//draw//
			//vga_sram_write <= 1'b1;
			// compute address
			vga_sram_address <= vga_out_base_address + {22'b0, vga_x_cood[12]} + ({22'b0,vga_y_cood[12]}*640) ; 
			// data
			vga_sram_writedata <= color_reg[12];
			draw_flag <= 25'd4096;
		end
		25'bxxxxxxxxxxx10000000000000: begin
			//draw//
			//vga_sram_write <= 1'b1;
			// compute address
			vga_sram_address <= vga_out_base_address + {22'b0, vga_x_cood[13]} + ({22'b0,vga_y_cood[13]}*640) ; 
			// data
			vga_sram_writedata <= color_reg[13];
			draw_flag <= 25'd8192;
		end
		25'bxxxxxxxxxx100000000000000: begin
			//draw//
			//vga_sram_write <= 1'b1;
			// compute address
			vga_sram_address <= vga_out_base_address + {22'b0, vga_x_cood[14]} + ({22'b0,vga_y_cood[14]}*640) ; 
			// data
			vga_sram_writedata <= color_reg[14];
			draw_flag <= 25'd16384;
		end
		25'bxxxxxxxxx1000000000000000: begin
			//draw//
			//vga_sram_write <= 1'b1;
			// compute address
			vga_sram_address <= vga_out_base_address + {22'b0, vga_x_cood[15]} + ({22'b0,vga_y_cood[15]}*640) ; 
			// data
			vga_sram_writedata <= color_reg[15];
			draw_flag <= 25'd32768;
		end
		25'bxxxxxxxx10000000000000000: begin
			//draw//
			//vga_sram_write <= 1'b1;
			// compute address
			vga_sram_address <= vga_out_base_address + {22'b0, vga_x_cood[16]} + ({22'b0,vga_y_cood[16]}*640) ; 
			// data
			vga_sram_writedata <= color_reg[16];
			draw_flag <= 25'd65536;
		end
		25'bxxxxxxx100000000000000000: begin
			//draw//
			//vga_sram_write <= 1'b1;
			// compute address
			vga_sram_address <= vga_out_base_address + {22'b0, vga_x_cood[17]} + ({22'b0,vga_y_cood[17]}*640) ; 
			// data
			vga_sram_writedata <= color_reg[17];
			draw_flag <= 25'd131072;
		end
		25'bxxxxxx1000000000000000000: begin
			//draw//
			//vga_sram_write <= 1'b1;
			// compute address
			vga_sram_address <= vga_out_base_address + {22'b0, vga_x_cood[18]} + ({22'b0,vga_y_cood[18]}*640) ; 
			// data
			vga_sram_writedata <= color_reg[18];
			draw_flag <= 25'd262144;
		end
		25'bxxxxx10000000000000000000: begin
			//draw//
			//vga_sram_write <= 1'b1;
			// compute address
			vga_sram_address <= vga_out_base_address + {22'b0, vga_x_cood[19]} + ({22'b0,vga_y_cood[19]}*640) ; 
			// data
			vga_sram_writedata <= color_reg[19];
			draw_flag <= 25'd524288;
		end
		25'bxxxx100000000000000000000: begin
			//draw//
			//vga_sram_write <= 1'b1;
			// compute address
			vga_sram_address <= vga_out_base_address + {22'b0, vga_x_cood[20]} + ({22'b0,vga_y_cood[20]}*640) ; 
			// data
			vga_sram_writedata <= color_reg[20];
			draw_flag <= 25'd1048576;
		end
		25'bxxx1000000000000000000000: begin
			//draw//
			//vga_sram_write <= 1'b1;
			// compute address
			vga_sram_address <= vga_out_base_address + {22'b0, vga_x_cood[21]} + ({22'b0,vga_y_cood[21]}*640) ; 
			// data
			vga_sram_writedata <= color_reg[21];
			draw_flag <= 25'd2097152;
		end
		25'bxx10000000000000000000000: begin
			//draw//
			//vga_sram_write <= 1'b1;
			// compute address
			vga_sram_address <= vga_out_base_address + {22'b0, vga_x_cood[22]} + ({22'b0,vga_y_cood[22]}*640) ; 
			// data
			vga_sram_writedata <= color_reg[22];
			draw_flag <= 25'd4194304;
		end
		25'bx100000000000000000000000: begin
			//draw//
			//vga_sram_write <= 1'b1;
			// compute address
			vga_sram_address <= vga_out_base_address + {22'b0, vga_x_cood[23]} + ({22'b0,vga_y_cood[23]}*640) ; 
			// data
			vga_sram_writedata <= color_reg[23];
			draw_flag <= 25'd8388608;
		end
		25'b1000000000000000000000000: begin
			//draw//
			//vga_sram_write <= 1'b1;
			// compute address
			vga_sram_address <= vga_out_base_address + {22'b0, vga_x_cood[24]} + ({22'b0,vga_y_cood[24]}*640) ; 
			// data
			vga_sram_writedata <= color_reg[24];
			draw_flag <= 25'd16777216;
		end
		default: begin
			draw_flag <= 25'd0;
		end
	endcase
end



//=======================================================
// Instantiate 2 iterators
//=======================================================
genvar i;
 generate
 
   for (i = 0; i < 25; i = i + 1) begin: iterations
		mandelbrot iter (
		.clock(clk_50),
		.reset(mreset[i]),
		.c_r(c_r[i]),
		.c_i(c_i[i]),
		.max_iter(max_iter),
		.total_iter(total_iter[i]), 
		.done(done[i])
	   );
	 
	 always @(posedge clk_50) begin

		// reset state machine and read/write controls
		if (~reset) begin
			state[i] <= 0 ;
			if ( i == 0 ) begin
				vga_sram_write <= 1'b0 ; // set to on if a write operation to bus
				sram_write <= 1'b0 ;
			end
		end
		
		else begin
		
			if (state[i] == 8'd0) begin
				vga_x_cood[i] <= i; 
				vga_y_cood[i] <= 0;
				c_r[i] <= -27'sb0010_00000000000000000000000 + i*27'sb0000_00000001001100110011001;
				c_i[i] <= 27'sb0001_00000000000000000000000;
				// only one iterator needs to signal this
				if ( i == 0 ) begin
				   // tell HPS to start timing
					sram_address <= 8'd0 ;
					sram_writedata <= 32'b1 ;
					sram_write <= 1'b1 ;
					// end vga write
					vga_sram_write <= 1'b0;
				end
				state[i] <= 8'd1;
				mreset[i] <= 0;
				
			end
			
			if (state[i] == 8'd1) begin
				mreset[i] <= 1;
				if ( i == 0 ) begin
					vga_sram_write <= 1'b1;
				end
			// box 2 (bigger box) for real coordinates
			   if ( c_r[i] > -27'sb0000_01111100100000011001011 && c_r[i] < 27'sb0000_00110011011101000011111 && c_i[i] > -27'sb0000_10000000000000000000000 && c_i[i] < 27'sb0000_10000000000000000000000) begin

						color_reg[i] <= 8'b_000_000_00 ; // black
						done_flag[i] <= 1'b1;
						state[i] <= 8'd2;
						mreset[i] <= 1'b0;
						box2flag[i] <= 1'b1;
				end
				// box 1 (smaller box) for real coordinates (-1.16129, -0.838714)
			   else if ( c_r[i] > -27'sb0001_00101001010010100101001 && c_r[i] < -27'sb0000_11010110101101011011001 && c_i[i] > -27'sb0000_00101100001001011010111 && c_i[i] < 27'sb0000_00101100001001011010111 ) begin
	
						color_reg[i] <= 8'b_000_000_00 ; // black
						done_flag[i] <= 1'b1;
						state[i] <= 8'd2;
						mreset[i] <= 1'b0;
						box1flag[i] <= 1'b1;

				end
				
				else if (~done[i]) begin
					state[i] <= 8'd1;
				end
				else begin
					done_flag[i] <= 1'b1;
					mreset[i] <= 1'b0;
					state[i] <= 8'd2;
					
					// assign color reg
					if (total_iter[i] >= max_iter) begin
					  color_reg[i] <= 8'b_000_000_00 ; // black
					end
					else if (total_iter[i] >= (max_iter >>> 1)) begin
					  color_reg[i] <= 8'b_011_001_00 ; // white
					end
					else if (total_iter[i] >= (max_iter >>> 2)) begin
					  color_reg[i] <= 8'b_011_001_00 ;
					end
					else if (total_iter[i] >= (max_iter >>> 3)) begin
					  color_reg[i] <= 8'b_101_010_01 ;
					end
					else if (total_iter[i] >= (max_iter >>> 4)) begin
					  color_reg[i] <= 8'b_011_001_01 ;
					end 
					else if (total_iter[i] >= (max_iter >>> 5)) begin
					  color_reg[i] <= 8'b_001_001_01 ;
					end
					else if (total_iter[i] >= (max_iter >>> 6)) begin
					  color_reg[i] <= 8'b_011_010_10 ;
					end
					else if (total_iter[i] >= (max_iter >>> 7)) begin
					  color_reg[i] <= 8'b_010_100_10 ;
					end
					else if (total_iter[i] >= (max_iter >>> 8)) begin
					  color_reg[i] <= 8'b_010_100_10 ;
					end
					else begin
					  color_reg[i] <= 8'b_010_100_10 ;
					end
    				end
			end
			
			
			if (state[i] == 8'd2) begin

				if (draw_flag[i]) begin
					box1flag[i] <= 1'b0;
					box2flag[i] <= 1'b0;
					done_flag[i] <= 1'b0;
					vga_x_cood[i] <= vga_x_cood[i] + 25;
					c_r[i] <= c_r[i] + 25*incr_x;
					
					if (vga_x_cood[i] > 10'd639) begin
						vga_x_cood[i] <= i;
						c_r[i] <= -27'sb0010_00000000000000000000000 + i*27'sb0000_00000001001100110011001;
						vga_y_cood[i] <= vga_y_cood[i] + 1;
						c_i[i] <= c_i[i] - incr_y;
					end
					
					if (vga_y_cood[i] > 10'd479) begin
						state[i] <= 8'd3;
					end
					else begin
						state[i] <= 8'd1;
					end
				end
				else begin
					state[i] <= 8'd2;

				end
			end
			
			if (state[i] == 8'd3) begin
				if (i == 0) begin
					// only one iterator needs to signal done
					// end vga write
					vga_sram_write <= 1'b0;
					sram_address <= 8'd0 ;
					sram_writedata <= 32'b0 ;
					sram_write <= 1'b1 ;
				end
				state[i] <= 8'd3;
			end
		end
		
		
	end
	 
	 
 end 
endgenerate
*/