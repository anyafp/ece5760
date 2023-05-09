module DE1_SoC_Computer (
	////////////////////////////////////
	// FPGA Pins
	////////////////////////////////////

	// Clock pins
	CLOCK_50,
	CLOCK2_50,
	CLOCK3_50,
	CLOCK4_50,

	// ADC
	ADC_CS_N,
	ADC_DIN,
	ADC_DOUT,
	ADC_SCLK,

	// Audio
	AUD_ADCDAT,
	AUD_ADCLRCK,
	AUD_BCLK,
	AUD_DACDAT,
	AUD_DACLRCK,
	AUD_XCK,

	// SDRAM
	DRAM_ADDR,
	DRAM_BA,
	DRAM_CAS_N,
	DRAM_CKE,
	DRAM_CLK,
	DRAM_CS_N,
	DRAM_DQ,
	DRAM_LDQM,
	DRAM_RAS_N,
	DRAM_UDQM,
	DRAM_WE_N,

	// I2C Bus for Configuration of the Audio and Video-In Chips
	FPGA_I2C_SCLK,
	FPGA_I2C_SDAT,

	// 40-Pin Headers
	GPIO_0,
	GPIO_1,
	
	// Seven Segment Displays
	HEX0,
	HEX1,
	HEX2,
	HEX3,
	HEX4,
	HEX5,

	// IR
	IRDA_RXD,
	IRDA_TXD,

	// Pushbuttons
	KEY,

	// LEDs
	LEDR,

	// PS2 Ports
	PS2_CLK,
	PS2_DAT,
	
	PS2_CLK2,
	PS2_DAT2,

	// Slider Switches
	SW,

	// Video-In
	TD_CLK27,
	TD_DATA,
	TD_HS,
	TD_RESET_N,
	TD_VS,

	// VGA
	VGA_B,
	VGA_BLANK_N,
	VGA_CLK,
	VGA_G,
	VGA_HS,
	VGA_R,
	VGA_SYNC_N,
	VGA_VS,

	////////////////////////////////////
	// HPS Pins
	////////////////////////////////////
	
	// DDR3 SDRAM
	HPS_DDR3_ADDR,
	HPS_DDR3_BA,
	HPS_DDR3_CAS_N,
	HPS_DDR3_CKE,
	HPS_DDR3_CK_N,
	HPS_DDR3_CK_P,
	HPS_DDR3_CS_N,
	HPS_DDR3_DM,
	HPS_DDR3_DQ,
	HPS_DDR3_DQS_N,
	HPS_DDR3_DQS_P,
	HPS_DDR3_ODT,
	HPS_DDR3_RAS_N,
	HPS_DDR3_RESET_N,
	HPS_DDR3_RZQ,
	HPS_DDR3_WE_N,

	// Ethernet
	HPS_ENET_GTX_CLK,
	HPS_ENET_INT_N,
	HPS_ENET_MDC,
	HPS_ENET_MDIO,
	HPS_ENET_RX_CLK,
	HPS_ENET_RX_DATA,
	HPS_ENET_RX_DV,
	HPS_ENET_TX_DATA,
	HPS_ENET_TX_EN,

	// Flash
	HPS_FLASH_DATA,
	HPS_FLASH_DCLK,
	HPS_FLASH_NCSO,

	// Accelerometer
	HPS_GSENSOR_INT,
		
	// General Purpose I/O
	HPS_GPIO,
		
	// I2C
	HPS_I2C_CONTROL,
	HPS_I2C1_SCLK,
	HPS_I2C1_SDAT,
	HPS_I2C2_SCLK,
	HPS_I2C2_SDAT,

	// Pushbutton
	HPS_KEY,

	// LED
	HPS_LED,
		
	// SD Card
	HPS_SD_CLK,
	HPS_SD_CMD,
	HPS_SD_DATA,

	// SPI
	HPS_SPIM_CLK,
	HPS_SPIM_MISO,
	HPS_SPIM_MOSI,
	HPS_SPIM_SS,

	// UART
	HPS_UART_RX,
	HPS_UART_TX,

	// USB
	HPS_CONV_USB_N,
	HPS_USB_CLKOUT,
	HPS_USB_DATA,
	HPS_USB_DIR,
	HPS_USB_NXT,
	HPS_USB_STP
);

//=======================================================
//  PARAMETER declarations
//=======================================================


//=======================================================
//  PORT declarations
//=======================================================

////////////////////////////////////
// FPGA Pins
////////////////////////////////////

// Clock pins
input						CLOCK_50;
input						CLOCK2_50;
input						CLOCK3_50;
input						CLOCK4_50;

// ADC
inout						ADC_CS_N;
output					ADC_DIN;
input						ADC_DOUT;
output					ADC_SCLK;

// Audio
input						AUD_ADCDAT;
inout						AUD_ADCLRCK;
inout						AUD_BCLK;
output					AUD_DACDAT;
inout						AUD_DACLRCK;
output					AUD_XCK;

// SDRAM
output 		[12: 0]	DRAM_ADDR;
output		[ 1: 0]	DRAM_BA;
output					DRAM_CAS_N;
output					DRAM_CKE;
output					DRAM_CLK;
output					DRAM_CS_N;
inout			[15: 0]	DRAM_DQ;
output					DRAM_LDQM;
output					DRAM_RAS_N;
output					DRAM_UDQM;
output					DRAM_WE_N;

// I2C Bus for Configuration of the Audio and Video-In Chips
output					FPGA_I2C_SCLK;
inout						FPGA_I2C_SDAT;

// 40-pin headers
inout			[35: 0]	GPIO_0;
inout			[35: 0]	GPIO_1;

// Seven Segment Displays
output		[ 6: 0]	HEX0;
output		[ 6: 0]	HEX1;
output		[ 6: 0]	HEX2;
output		[ 6: 0]	HEX3;
output		[ 6: 0]	HEX4;
output		[ 6: 0]	HEX5;

// IR
input						IRDA_RXD;
output					IRDA_TXD;

// Pushbuttons
input			[ 3: 0]	KEY;

// LEDs
output		[ 9: 0]	LEDR;

// PS2 Ports
inout						PS2_CLK;
inout						PS2_DAT;

inout						PS2_CLK2;
inout						PS2_DAT2;

// Slider Switches
input			[ 9: 0]	SW;

// Video-In
input						TD_CLK27;
input			[ 7: 0]	TD_DATA;
input						TD_HS;
output					TD_RESET_N;
input						TD_VS;

// VGA
output		[ 7: 0]	VGA_B;
output					VGA_BLANK_N;
output					VGA_CLK;
output		[ 7: 0]	VGA_G;
output					VGA_HS;
output		[ 7: 0]	VGA_R;
output					VGA_SYNC_N;
output					VGA_VS;



////////////////////////////////////
// HPS Pins
////////////////////////////////////
	
// DDR3 SDRAM
output		[14: 0]	HPS_DDR3_ADDR;
output		[ 2: 0]  HPS_DDR3_BA;
output					HPS_DDR3_CAS_N;
output					HPS_DDR3_CKE;
output					HPS_DDR3_CK_N;
output					HPS_DDR3_CK_P;
output					HPS_DDR3_CS_N;
output		[ 3: 0]	HPS_DDR3_DM;
inout			[31: 0]	HPS_DDR3_DQ;
inout			[ 3: 0]	HPS_DDR3_DQS_N;
inout			[ 3: 0]	HPS_DDR3_DQS_P;
output					HPS_DDR3_ODT;
output					HPS_DDR3_RAS_N;
output					HPS_DDR3_RESET_N;
input						HPS_DDR3_RZQ;
output					HPS_DDR3_WE_N;

// Ethernet
output					HPS_ENET_GTX_CLK;
inout						HPS_ENET_INT_N;
output					HPS_ENET_MDC;
inout						HPS_ENET_MDIO;
input						HPS_ENET_RX_CLK;
input			[ 3: 0]	HPS_ENET_RX_DATA;
input						HPS_ENET_RX_DV;
output		[ 3: 0]	HPS_ENET_TX_DATA;
output					HPS_ENET_TX_EN;

// Flash
inout			[ 3: 0]	HPS_FLASH_DATA;
output					HPS_FLASH_DCLK;
output					HPS_FLASH_NCSO;

// Accelerometer
inout						HPS_GSENSOR_INT;

// General Purpose I/O
inout			[ 1: 0]	HPS_GPIO;

// I2C
inout						HPS_I2C_CONTROL;
inout						HPS_I2C1_SCLK;
inout						HPS_I2C1_SDAT;
inout						HPS_I2C2_SCLK;
inout						HPS_I2C2_SDAT;

// Pushbutton
inout						HPS_KEY;

// LED
inout						HPS_LED;

// SD Card
output					HPS_SD_CLK;
inout						HPS_SD_CMD;
inout			[ 3: 0]	HPS_SD_DATA;

// SPI
output					HPS_SPIM_CLK;
input						HPS_SPIM_MISO;
output					HPS_SPIM_MOSI;
inout						HPS_SPIM_SS;

// UART
input						HPS_UART_RX;
output					HPS_UART_TX;

// USB
inout						HPS_CONV_USB_N;
input						HPS_USB_CLKOUT;
inout			[ 7: 0]	HPS_USB_DATA;
input						HPS_USB_DIR;
input						HPS_USB_NXT;
output					HPS_USB_STP;

//=======================================================
//  REG/WIRE declarations
//=======================================================

// VGA clock and reset lines
wire vga_pll_lock;
wire vga_pll;
reg  vga_reset;

// M10k memory control and data
wire [ 7:0] M10k_out;
reg  [ 7:0] write_data;
reg  [18:0] write_address;
reg  [18:0] read_address;
reg 			write_enable;

// M10k memory clock
wire M10k_pll;
wire M10k_pll_locked;

// Wires for connecting VGA driver to memory
wire [9:0] next_x;
wire [9:0] next_y;

// ===============================================================================

reg  [ 7:0] state;

// PIO Wires
wire [ 9:0] box_pio;
wire [31:0] delay_pio; 
wire [ 9:0] velocity_pio;
wire [19:0] nparticles_pio;
wire [ 9:0] hits_pio; 
wire 			reset_pio;
wire			sw_p;
wire			sw_v;
wire			sw_n;
wire			sw_t;

// Position registers and wires
reg  [9:0] x_[149:0], y_[149:0];		 // Registers that store all position values
reg  [9:0] x_prev_curr, y_prev_curr; // Register for one position value
wire [9:0] x_next_particle, y_next_particle, x_prev_particle,y_prev_particle; // Wires for module

// Velocity registers and wires
reg signed  [9:0] vx[149:0], vy[149:0];			 // Registers that store all velocity values
reg signed  [9:0] vx_prev_curr, vy_prev_curr; // Register for one velocity value
wire signed [9:0] vx_next_particle, vy_next_particle, vx_prev_particle, vy_prev_particle; // Wires for module

// Counters, indices, etc
reg [31:0] count; 		 // Counts cycles in wait state
reg [19:0] idx, cmp_idx; // Index for position/velocty registers, compare index for collisions
reg [ 9:0] box_counter;
reg [ 9:0] timestep_counter;
reg [ 9:0] clear_counter_x, clear_counter_y; // Counter for erasing box

// Other variables
wire [ 9:0] box_size;				// Current size of box
reg  [ 9:0] box_erase;				// Old box measurements to erase
wire [19:0] num_particles;			// Number of particles (assigned from PIO)
wire [ 9:0] mask_val; 				// Mask to get proper range of positions to initialize
reg  [ 9:0] hits_reg, hits_temp; // counter for wall collisions
wire 			wall_hits_wire;		// Wall was hit this cycle
reg 			reset_fpga;				// Only reset FPGA at the end of each timestep
wire [ 9:0] hit_in_wire, hit_out_wire;
reg  [ 9:0] hit_counter;

// Assignments
assign sw_p				= SW[0];
assign sw_v				= SW[1];
assign sw_n				= SW[2];
assign sw_t				= SW[3];
assign num_particles = nparticles_pio;
assign box_size 		= box_pio >> 1;
//assign hits_pio 		= hits_temp;
assign hits_pio 		= hits_temp;
assign mask_val 		= (box_pio < 10'd70) ? 10'b0000011111 : (box_pio < 10'd135) ? 10'b0000111111 : (box_pio < 10'd265) ? 10'b0001111111 : 10'b0011111111;

// LFSR variables
wire [12:0] rnd;		  // Random value
reg 			reset_rnd; // Reset LFSR
wire 			done_rnd;  // LFSR done signal

LFSR randNum ( 
	  .clock(M10k_pll), 
	  .reset(reset_rnd), 
	  .rnd(rnd), 
	  .done(done_rnd)
);

particle particle1 (
	  .x_prev(x_prev_particle),
	  .y_prev(y_prev_particle),
	  .vx_prev(vx_prev_particle),
	  .vy_prev(vy_prev_particle),
	  .box_length(box_size),
	  .x_next(x_next_particle),
	  .y_next(y_next_particle),
	  .vx_next(vx_next_particle),
	  .vy_next(vy_next_particle),
	  .hit_counter_in(hit_in_wire),
	  .hit_counter_out(hit_out_wire)
);

// Assign input wires to particle module
assign x_prev_particle  = x_prev_curr; 
assign y_prev_particle  = y_prev_curr; 
assign vx_prev_particle = vx_prev_curr;
assign vy_prev_particle = vy_prev_curr;
assign hit_in_wire      = hit_counter;
 
// ===============================================================================
// STATE 0:  Initalize particle x and y
// STATE 1:  Initalize particle x and y
// STATE 15: Clear screen
// STATE 2:  Top Box
// STATE 3:  Bottom Box
// STATE 4:  Left Box
// STATE 5:  Right Box
// STATE 6:  Erase previous (1) -- top left
// STATE 16: Check for collision & update vx/vy
// STATE 10: Draw new pixel (1) -- top left
// STATE 14: WAIT
// ===============================================================================

always@(posedge M10k_pll) begin
	// Zero everything in reset
	if (~KEY[0] || ~reset_fpga) begin
		state <= 8'd0 ;
		idx <= 20'd0;
		cmp_idx <= 20'd0;
		box_counter <= 0;
		clear_counter_x <= 0;
		clear_counter_y <= 0;
		reset_fpga <= 1;
		vga_reset <= 1'b_1;
		reset_rnd <= 1'b0;
		hits_reg <= 0;
		timestep_counter <= 0;
		hit_counter <= 0;
	end

	else begin

		// STATE 0: start
		if ( state == 8'd0 ) begin
			 reset_rnd <= 1'b1;
			 if ( done_rnd ) begin
				  state <= 8'd1;
			 end
		end
		
		// STATE 1: set and reset
		else if ( state == 8'd1 ) begin
			if ( idx < num_particles ) begin
				if ( done_rnd == 0 ) begin 
					state <= 8'd0;
					idx <= idx + 20'd1;
					x_[idx] <= (rnd & mask_val) + (10'd320 - box_size);
				end
			end
			else if ( idx < ( num_particles << 1 ) ) begin
				if ( done_rnd == 0 ) begin 
					state <= 8'd0;
					idx <= idx + 20'd1;
					y_[idx-num_particles] <= (rnd & mask_val) + (10'd240 - box_size);
				end
			end
			else if ( idx < ( ( num_particles << 1 ) + num_particles ) ) begin
				if ( done_rnd == 0 ) begin 
					state <= 8'd0;
					idx <= idx + 20'd1;
					
					// left
					if ( ( rnd & 2'b11 ) == 0 ) begin
						vx[idx-(num_particles<<1)] <= -velocity_pio;
						vy[idx-(num_particles<<1)] <= 10'd0;
					end
					// up
					else if ( ( rnd & 2'b11 ) == 2'd1 ) begin
						vx[idx-(num_particles<<1)] <= 10'd0;
						vy[idx-(num_particles<<1)] <= velocity_pio;
					end
					// right
					else if ( ( rnd & 2'b11 ) == 2'd2 ) begin
						vx[idx-(num_particles<<1)] <= velocity_pio;
						vy[idx-(num_particles<<1)] <= 10'd0;
					end
					// down
					else begin
						vx[idx-(num_particles<<1)] <= 10'd0;
						vy[idx-(num_particles<<1)] <= -velocity_pio;
					end
				end
			end
			// done
			else if ( idx == ( ( num_particles << 1 ) + num_particles ) ) begin
				state <= 8'd15;
				reset_rnd <= 1'b0;
				idx <= 20'd0;
			end
		end
		
		// STATE 15: Clear Screen
		else if ( state == 8'd15 ) begin
		
			vga_reset <= 1'b_0 ;
			write_enable <= 1'b_1 ;
			write_address <= (19'd_640 * clear_counter_y) + (clear_counter_x) ;
			write_data <= 8'b_000_000_00 ; // black
			
			if ( clear_counter_x == 10'd639 ) begin
				clear_counter_x <= 0;
				clear_counter_y <= clear_counter_y + 1;
				if ( clear_counter_y == 10'd479 ) state <= 8'd2;
				else state <= 8'd15;
			end
			else begin
				clear_counter_x <= clear_counter_x + 1;
				state <= 8'd15;
			end
			
		end
		
		// STATE 2: Top Box
		else if ( state == 8'd2 ) begin
			
			// draw new box
			if ( box_counter < box_pio ) begin
				box_counter <= box_counter + 20'd1;
				vga_reset <= 1'b_0 ;
				write_enable <= 1'b_1 ;
				write_address <= (19'd_640 * (10'd240-box_size)) + (10'd320-box_size+box_counter) ;
				write_data <= 8'b_111_111_11 ; // white
				state <= 8'd2;
			end
			else begin 
				box_counter <= 0; 
				state <= 8'd3;
			end
			
		end
		
		// STATE 3: Bottom Box
		else if ( state == 8'd3 ) begin
			

			// draw new box
			if ( box_counter < box_pio ) begin
				box_counter <= box_counter + 20'd1;
				vga_reset <= 1'b_0 ;
				write_enable <= 1'b_1 ;
				write_address <= (19'd_640 * (10'd240+box_size)) + (10'd320-box_size+box_counter);
				write_data <= 8'b_111_111_11 ; // white
				state <= 8'd3;
			end
			else begin 
				box_counter <= 0; 
				state <= 8'd4;
			end
		end
		
		// STATE 4: Left Box
		else if ( state == 8'd4 ) begin
			
			// draw new box
			if ( box_counter < box_pio ) begin
				box_counter <= box_counter + 20'd1;
				vga_reset <= 1'b_0 ;
				write_enable <= 1'b_1 ;
				write_address <= (19'd_640 * (10'd240-box_size +box_counter)) + (10'd320-box_size) ;
				write_data <= 8'b_111_111_11; // white
				state <= 8'd4;
			end
			else begin 
				box_counter <= 0; 
				state <= 8'd5;
			end
		end
		
		// STATE 5: Right Box
		else if ( state == 8'd5 ) begin
			
			// draw new box
			if ( box_counter < box_pio ) begin
				box_counter <= box_counter + 20'd1;
				vga_reset <= 1'b_0 ;
				write_enable <= 1'b_1 ;
				write_address <= (19'd_640 * (10'd240-box_size +box_counter)) + (10'd320+box_size) ;
				write_data <= 8'b_111_111_11 ; // white
				state <= 8'd5;
			end
			else begin
				box_counter <= 0; 
				box_erase <= box_size;
				state <= 8'd6;
			end
			
		end

		// STATE 6: Erase previous (1) -- top left
		else if ( state == 8'd6 ) begin
			if ( idx == num_particles ) begin
				state <= 8'd16;
				idx <= 0; 
				cmp_idx <= 1;
			end
			else begin
				idx <= idx + 20'd1;
				if (( y_[idx] == (10'd240 + box_size) || y_[idx] == (10'd240 - box_size) ) && ( x_[idx] <= (10'd320 + box_size) || x_[idx] >= (10'd320 - box_size) ) )
					state <= 8'd6;
				else if ( ( x_[idx] == (10'd320 + box_size) || x_[idx] == (10'd320 - box_size) ) && ( y_[idx] <= (10'd240 + box_size) || y_[idx] >= (10'd240 - box_size) ) )
					state <= 8'd6;
				else begin
					vga_reset <= 1'b_0 ;
					write_enable <= 1'b_1 ;
					write_address <= (19'd_640 * y_[idx]) + x_[idx] ;
					write_data <= 8'b_000_000_00 ; // black
				end
				state <= 8'd6;
			end
		end
		
		
		// STATE 16: Check for collisions & update vx/vy
		else if ( state == 8'd16 ) begin
			
			// next state
			if ( idx == num_particles ) begin
				state <= 8'd10;
				x_prev_curr <= x_[0];
				y_prev_curr <= y_[0];
				vx_prev_curr <= vx[0];
				vy_prev_curr <= vy[0];
				idx <= 0;
			end
			
			else begin
			
				// check all particles on the right of the idk particle
				if ( cmp_idx < num_particles ) begin
				
				

					if ( ( x_[idx] == x_[cmp_idx] ) && ( y_[idx] == y_[cmp_idx] ) ) begin
						case ( { (( vx[idx] < 0 ) ? 2'd0 : ( vx[idx] > 0 ) ? 2'd2 : ( vy[idx] > 0 ) ? 2'd1 : 2'd3), (( vx[cmp_idx] < 0 ) ? 2'd0 : ( vx[cmp_idx] > 0 ) ? 2'd2 : ( vy[cmp_idx] > 0 ) ? 2'd1 : 2'd3) } )
						
							4'b0000: begin
								vx[idx] <= 10'd0;
								vy[idx] <= velocity_pio;
								vx[cmp_idx] <= 10'd0;
								vy[cmp_idx] <= -velocity_pio;
								end
							
							4'b0001: begin
								vx[idx] <= 10'd0;
								vy[idx] <= -velocity_pio;
								vx[cmp_idx] <= velocity_pio;
								vy[cmp_idx] <= 10'd0;
								end
								
							4'b0010: begin
								vx[idx] <= 10'd0;
								vy[idx] <= velocity_pio;
								vx[cmp_idx] <= 10'd0;
								vy[cmp_idx] <= -velocity_pio;
								end
								
							4'b0011: begin
								vx[idx] <= 10'd0;
								vy[idx] <= velocity_pio;
								vx[cmp_idx] <= velocity_pio;
								vy[cmp_idx] <= 10'd0;
								end
								
							4'b0100:begin
								vx[idx] <= 10'd0;
								vy[idx] <= -velocity_pio;
								vx[cmp_idx] <= velocity_pio;
								vy[cmp_idx] <= 10'd0;
								end
								
							4'b0101: begin
								vx[idx] <= velocity_pio;
								vy[idx] <= 10'd0;
								vx[cmp_idx] <= -velocity_pio;
								vy[cmp_idx] <= 10'd0;
								end
								
							4'b0110: begin
								vx[idx] <= 10'd0;
								vy[idx] <= -velocity_pio;
								vx[cmp_idx] <= -velocity_pio;
								vy[cmp_idx] <= 10'd0;
								end
								
							4'b0111: begin
								vx[idx] <= -velocity_pio;
								vy[idx] <= 10'd0;
								vx[cmp_idx] <= velocity_pio;
								vy[cmp_idx] <= 10'd0;
								end
								
							4'b1000: begin
								vx[idx] <= 10'd0;
								vy[idx] <= velocity_pio;
								vx[cmp_idx] <= 10'd0;
								vy[cmp_idx] <= -velocity_pio;
								end
								
							4'b1001: begin
								vx[idx] <= 10'd0;
								vy[idx] <= -velocity_pio;
								vx[cmp_idx] <= -velocity_pio;
								vy[cmp_idx] <= 10'd0;
								end
								
							4'b1010: begin
								vx[idx] <= 10'd0;
								vy[idx] <= velocity_pio;
								vx[cmp_idx] <= 10'd0;
								vy[cmp_idx] <= -velocity_pio;
								end
								
							4'b1011: begin
								vx[idx] <= -velocity_pio;
								vy[idx] <= 10'd0;
								vx[cmp_idx] <= 10'd0;
								vy[cmp_idx] <= velocity_pio;
								end
								
							4'b1100: begin
								vx[idx] <= velocity_pio;
								vy[idx] <= 10'd0;
								vx[cmp_idx] <= 10'd0;
								vy[cmp_idx] <= velocity_pio;
								end
								
							4'b1101: begin
								vx[idx] <= velocity_pio;
								vy[idx] <= 10'd0;
								vx[cmp_idx] <= -velocity_pio;
								vy[cmp_idx] <= 10'd0;
								end
								
							4'b1110: begin
								vx[idx] <= 10'd0;
								vy[idx] <= velocity_pio;
								vx[cmp_idx] <= -velocity_pio;
								vy[cmp_idx] <= 10'd0;
								end
								
							4'b1111: begin
								vx[idx] <= velocity_pio;
								vy[idx] <= 10'd0;
								vx[cmp_idx] <= -velocity_pio;
								vy[cmp_idx] <= 10'd0;
								end
								
						endcase

					end
					cmp_idx <= cmp_idx + 1;
					state <= 8'd16;
				end // cmp < num_particles
				// cmp >= num_particles
				else begin 
					state <= 8'd16;
					idx <= idx + 1;
					cmp_idx <= idx + 20'd2;
				end
			end // idx == num_particles
		end // state
		
		// STATE 10: Draw new pixel (1) -- top left
		else if ( state == 8'd10 ) begin
			
			// updating 
			x_[idx] <= x_next_particle;
			y_[idx] <= y_next_particle;
			vx[idx] <= vx_next_particle;
			vy[idx] <= vy_next_particle;
			hit_counter <= hit_out_wire;
			
			if ( idx == num_particles ) begin
				state <= 8'd14;
				idx <= 0; 
				count <= 32'b0;
			end
			else begin
				
				vga_reset <= 1'b_0 ;
				write_enable <= 1'b_1 ;
				write_address <= (19'd_640 * y_next_particle) + x_next_particle ;
				write_data <= 8'b_111_111_11 ; // white
				if ( idx < num_particles ) begin
					x_prev_curr <= x_[idx+1];
					y_prev_curr <= y_[idx+1];
					vx_prev_curr <= vx[idx+1];
					vy_prev_curr <= vy[idx+1];
				end
				state <= 8'd10;
				idx <= idx + 20'd1;
			end
		end
		
		// STATE 14: WAIT
		else if ( state == 8'd14 ) begin
			if ( !reset_pio ) reset_fpga <= 0;
			write_enable <= 1'b_0 ;
			count <= count + 32'b1;
			
			if ( idx < num_particles ) begin
			
				// 00: negative, 01: zero, 10: positive
				case ( { (( vx[idx] < 0 ) ? 2'd0 : ( vx[idx] > 0 ) ? 2'd2 : 2'd1 ) } )
					2'b00: vx[idx] <= -velocity_pio;
					2'b01: vx[idx] <= 10'd0;
					2'b10: vx[idx] <= velocity_pio;
				endcase
				
				// 00: negative, 01: zero, 10: positive
				case ( { (( vy[idx] < 0 ) ? 2'd0 : ( vy[idx] > 0 ) ? 2'd2 : 2'd1 ) } )
					2'b00: vy[idx] <= -velocity_pio;
					2'b01: vy[idx] <= 10'd0;
					2'b10: vy[idx] <= velocity_pio;
				endcase
				
			end
			
			idx <= idx + 1;

			if ( count > delay_pio ) begin
				state <= 8'd6;
				idx <= 0;
				
				if ( timestep_counter >= 10'd100 ) begin
					timestep_counter <= 0;
					hits_temp <= hit_counter;
					hit_counter <= 0;
				end
				else begin
					timestep_counter <= timestep_counter + 1;
				end
			end
			else
				state <= 8'd14;

		end

	end
end

// Instantiate memory
M10K_1000_8 pixel_data( .q(M10k_out), // contains pixel color (8 bit) for display
								.d(write_data),
								.write_address(write_address),
								.read_address((19'd_640*next_y) + next_x),
								.we(write_enable),
								.clk(M10k_pll)
);

// Instantiate VGA driver					
vga_driver DUT   (	.clock(vga_pll), 
							.reset(vga_reset),
							.color_in(M10k_out),	// Pixel color (8-bit) from memory
							.next_x(next_x),		// This (and next_y) used to specify memory read address
							.next_y(next_y),		// This (and next_x) used to specify memory read address
							.hsync(VGA_HS),
							.vsync(VGA_VS),
							.red(VGA_R),
							.green(VGA_G),
							.blue(VGA_B),
							.sync(VGA_SYNC_N),
							.clk(VGA_CLK),
							.blank(VGA_BLANK_N)
);


//=======================================================
//  Structural coding
//=======================================================
// From Qsys

Computer_System The_System (
	////////////////////////////////////
	// FPGA Side
	////////////////////////////////////
	.vga_pio_locked_export			(vga_pll_lock),           //       vga_pio_locked.export
	.vga_pio_outclk0_clk				(vga_pll),              //      vga_pio_outclk0.clk
	.m10k_pll_locked_export			(M10k_pll_locked),          //      m10k_pll_locked.export
	.m10k_pll_outclk0_clk			(M10k_pll),            //     m10k_pll_outclk0.clk

	// Global signals
	.system_pll_ref_clk_clk					(CLOCK_50),
	.system_pll_ref_reset_reset			(1'b0),
	
	.delay_pio_ext_export     (delay_pio),
	.box_pio_ext_export     (box_pio),  
	.reset_pio_ext_export     (reset_pio),
	.velocity_pio_ext_export  (velocity_pio), 
	.hits_pio_ext_export  (hits_pio), 
	.nparticles_pio_ext_export  (nparticles_pio),
	.sw_p_pio_ext_export  (sw_p),
	.sw_v_pio_ext_export  (sw_v),
	.sw_n_pio_ext_export  (sw_n),
	.sw_t_pio_ext_export  (sw_t),
	

	////////////////////////////////////
	// HPS Side
	////////////////////////////////////
	// DDR3 SDRAM
	.memory_mem_a			(HPS_DDR3_ADDR),
	.memory_mem_ba			(HPS_DDR3_BA),
	.memory_mem_ck			(HPS_DDR3_CK_P),
	.memory_mem_ck_n		(HPS_DDR3_CK_N),
	.memory_mem_cke		(HPS_DDR3_CKE),
	.memory_mem_cs_n		(HPS_DDR3_CS_N),
	.memory_mem_ras_n		(HPS_DDR3_RAS_N),
	.memory_mem_cas_n		(HPS_DDR3_CAS_N),
	.memory_mem_we_n		(HPS_DDR3_WE_N),
	.memory_mem_reset_n	(HPS_DDR3_RESET_N),
	.memory_mem_dq			(HPS_DDR3_DQ),
	.memory_mem_dqs		(HPS_DDR3_DQS_P),
	.memory_mem_dqs_n		(HPS_DDR3_DQS_N),
	.memory_mem_odt		(HPS_DDR3_ODT),
	.memory_mem_dm			(HPS_DDR3_DM),
	.memory_oct_rzqin		(HPS_DDR3_RZQ),
		  
	// Ethernet
	.hps_io_hps_io_gpio_inst_GPIO35	(HPS_ENET_INT_N),
	.hps_io_hps_io_emac1_inst_TX_CLK	(HPS_ENET_GTX_CLK),
	.hps_io_hps_io_emac1_inst_TXD0	(HPS_ENET_TX_DATA[0]),
	.hps_io_hps_io_emac1_inst_TXD1	(HPS_ENET_TX_DATA[1]),
	.hps_io_hps_io_emac1_inst_TXD2	(HPS_ENET_TX_DATA[2]),
	.hps_io_hps_io_emac1_inst_TXD3	(HPS_ENET_TX_DATA[3]),
	.hps_io_hps_io_emac1_inst_RXD0	(HPS_ENET_RX_DATA[0]),
	.hps_io_hps_io_emac1_inst_MDIO	(HPS_ENET_MDIO),
	.hps_io_hps_io_emac1_inst_MDC		(HPS_ENET_MDC),
	.hps_io_hps_io_emac1_inst_RX_CTL	(HPS_ENET_RX_DV),
	.hps_io_hps_io_emac1_inst_TX_CTL	(HPS_ENET_TX_EN),
	.hps_io_hps_io_emac1_inst_RX_CLK	(HPS_ENET_RX_CLK),
	.hps_io_hps_io_emac1_inst_RXD1	(HPS_ENET_RX_DATA[1]),
	.hps_io_hps_io_emac1_inst_RXD2	(HPS_ENET_RX_DATA[2]),
	.hps_io_hps_io_emac1_inst_RXD3	(HPS_ENET_RX_DATA[3]),

	// Flash
	.hps_io_hps_io_qspi_inst_IO0	(HPS_FLASH_DATA[0]),
	.hps_io_hps_io_qspi_inst_IO1	(HPS_FLASH_DATA[1]),
	.hps_io_hps_io_qspi_inst_IO2	(HPS_FLASH_DATA[2]),
	.hps_io_hps_io_qspi_inst_IO3	(HPS_FLASH_DATA[3]),
	.hps_io_hps_io_qspi_inst_SS0	(HPS_FLASH_NCSO),
	.hps_io_hps_io_qspi_inst_CLK	(HPS_FLASH_DCLK),

	// Accelerometer
	.hps_io_hps_io_gpio_inst_GPIO61	(HPS_GSENSOR_INT),

	//.adc_sclk                        (ADC_SCLK),
	//.adc_cs_n                        (ADC_CS_N),
	//.adc_dout                        (ADC_DOUT),
	//.adc_din                         (ADC_DIN),

	// General Purpose I/O
	.hps_io_hps_io_gpio_inst_GPIO40	(HPS_GPIO[0]),
	.hps_io_hps_io_gpio_inst_GPIO41	(HPS_GPIO[1]),

	// I2C
	.hps_io_hps_io_gpio_inst_GPIO48	(HPS_I2C_CONTROL),
	.hps_io_hps_io_i2c0_inst_SDA		(HPS_I2C1_SDAT),
	.hps_io_hps_io_i2c0_inst_SCL		(HPS_I2C1_SCLK),
	.hps_io_hps_io_i2c1_inst_SDA		(HPS_I2C2_SDAT),
	.hps_io_hps_io_i2c1_inst_SCL		(HPS_I2C2_SCLK),

	// Pushbutton
	.hps_io_hps_io_gpio_inst_GPIO54	(HPS_KEY),

	// LED
	.hps_io_hps_io_gpio_inst_GPIO53	(HPS_LED),

	// SD Card
	.hps_io_hps_io_sdio_inst_CMD	(HPS_SD_CMD),
	.hps_io_hps_io_sdio_inst_D0	(HPS_SD_DATA[0]),
	.hps_io_hps_io_sdio_inst_D1	(HPS_SD_DATA[1]),
	.hps_io_hps_io_sdio_inst_CLK	(HPS_SD_CLK),
	.hps_io_hps_io_sdio_inst_D2	(HPS_SD_DATA[2]),
	.hps_io_hps_io_sdio_inst_D3	(HPS_SD_DATA[3]),

	// SPI
	.hps_io_hps_io_spim1_inst_CLK		(HPS_SPIM_CLK),
	.hps_io_hps_io_spim1_inst_MOSI	(HPS_SPIM_MOSI),
	.hps_io_hps_io_spim1_inst_MISO	(HPS_SPIM_MISO),
	.hps_io_hps_io_spim1_inst_SS0		(HPS_SPIM_SS),

	// UART
	.hps_io_hps_io_uart0_inst_RX	(HPS_UART_RX),
	.hps_io_hps_io_uart0_inst_TX	(HPS_UART_TX),

	// USB
	.hps_io_hps_io_gpio_inst_GPIO09	(HPS_CONV_USB_N),
	.hps_io_hps_io_usb1_inst_D0		(HPS_USB_DATA[0]),
	.hps_io_hps_io_usb1_inst_D1		(HPS_USB_DATA[1]),
	.hps_io_hps_io_usb1_inst_D2		(HPS_USB_DATA[2]),
	.hps_io_hps_io_usb1_inst_D3		(HPS_USB_DATA[3]),
	.hps_io_hps_io_usb1_inst_D4		(HPS_USB_DATA[4]),
	.hps_io_hps_io_usb1_inst_D5		(HPS_USB_DATA[5]),
	.hps_io_hps_io_usb1_inst_D6		(HPS_USB_DATA[6]),
	.hps_io_hps_io_usb1_inst_D7		(HPS_USB_DATA[7]),
	.hps_io_hps_io_usb1_inst_CLK		(HPS_USB_CLKOUT),
	.hps_io_hps_io_usb1_inst_STP		(HPS_USB_STP),
	.hps_io_hps_io_usb1_inst_DIR		(HPS_USB_DIR),
	.hps_io_hps_io_usb1_inst_NXT		(HPS_USB_NXT)
);
endmodule // end top level

// Declaration of module, include width and signedness of each input/output
module vga_driver (
	input wire clock,
	input wire reset,
	input [7:0] color_in,
	output [9:0] next_x,
	output [9:0] next_y,
	output wire hsync,
	output wire vsync,
	output [7:0] red,
	output [7:0] green,
	output [7:0] blue,
	output sync,
	output clk,
	output blank
);
	
	// Horizontal parameters (measured in clock cycles)
	parameter [9:0] H_ACTIVE  	=  10'd_639 ;
	parameter [9:0] H_FRONT 	=  10'd_15 ;
	parameter [9:0] H_PULSE		=  10'd_95 ;
	parameter [9:0] H_BACK 		=  10'd_47 ;

	// Vertical parameters (measured in lines)
	parameter [9:0] V_ACTIVE  	=  10'd_479 ;
	parameter [9:0] V_FRONT 	=  10'd_9 ;
	parameter [9:0] V_PULSE		=  10'd_1 ;
	parameter [9:0] V_BACK 		=  10'd_32 ;

//	// Horizontal parameters (measured in clock cycles)
//	parameter [9:0] H_ACTIVE  	=  10'd_9 ;
//	parameter [9:0] H_FRONT 	=  10'd_4 ;
//	parameter [9:0] H_PULSE		=  10'd_4 ;
//	parameter [9:0] H_BACK 		=  10'd_4 ;
//	parameter [9:0] H_TOTAL 	=  10'd_799 ;
//
//	// Vertical parameters (measured in lines)
//	parameter [9:0] V_ACTIVE  	=  10'd_1 ;
//	parameter [9:0] V_FRONT 	=  10'd_1 ;
//	parameter [9:0] V_PULSE		=  10'd_1 ;
//	parameter [9:0] V_BACK 		=  10'd_1 ;

	// Parameters for readability
	parameter 	LOW 	= 1'b_0 ;
	parameter 	HIGH	= 1'b_1 ;

	// States (more readable)
	parameter 	[7:0]	H_ACTIVE_STATE 		= 8'd_0 ;
	parameter 	[7:0] 	H_FRONT_STATE		= 8'd_1 ;
	parameter 	[7:0] 	H_PULSE_STATE 		= 8'd_2 ;
	parameter 	[7:0] 	H_BACK_STATE 		= 8'd_3 ;

	parameter 	[7:0]	V_ACTIVE_STATE 		= 8'd_0 ;
	parameter 	[7:0] 	V_FRONT_STATE		= 8'd_1 ;
	parameter 	[7:0] 	V_PULSE_STATE 		= 8'd_2 ;
	parameter 	[7:0] 	V_BACK_STATE 		= 8'd_3 ;

	// Clocked registers
	reg 		hysnc_reg ;
	reg 		vsync_reg ;
	reg 	[7:0]	red_reg ;
	reg 	[7:0]	green_reg ;
	reg 	[7:0]	blue_reg ;
	reg 		line_done ;

	// Control registers
	reg 	[9:0] 	h_counter ;
	reg 	[9:0] 	v_counter ;

	reg 	[7:0]	h_state ;
	reg 	[7:0]	v_state ;

	// State machine
	always@(posedge clock) begin
		// At reset . . .
  		if (reset) begin
			// Zero the counters
			h_counter 	<= 10'd_0 ;
			v_counter 	<= 10'd_0 ;
			// States to ACTIVE
			h_state 	<= H_ACTIVE_STATE  ;
			v_state 	<= V_ACTIVE_STATE  ;
			// Deassert line done
			line_done 	<= LOW ;
  		end
  		else begin
			//////////////////////////////////////////////////////////////////////////
			///////////////////////// HORIZONTAL /////////////////////////////////////
			//////////////////////////////////////////////////////////////////////////
			if (h_state == H_ACTIVE_STATE) begin
				// Iterate horizontal counter, zero at end of ACTIVE mode
				h_counter <= (h_counter==H_ACTIVE)?10'd_0:(h_counter + 10'd_1) ;
				// Set hsync
				hysnc_reg <= HIGH ;
				// Deassert line done
				line_done <= LOW ;
				// State transition
				h_state <= (h_counter == H_ACTIVE)?H_FRONT_STATE:H_ACTIVE_STATE ;
			end
			// Assert done flag, wait here for reset
			if (h_state == H_FRONT_STATE) begin
				// Iterate horizontal counter, zero at end of H_FRONT mode
				h_counter <= (h_counter==H_FRONT)?10'd_0:(h_counter + 10'd_1) ;
				// Set hsync
				hysnc_reg <= HIGH ;
				// State transition
				h_state <= (h_counter == H_FRONT)?H_PULSE_STATE:H_FRONT_STATE ;
			end
			if (h_state == H_PULSE_STATE) begin
				// Iterate horizontal counter, zero at end of H_FRONT mode
				h_counter <= (h_counter==H_PULSE)?10'd_0:(h_counter + 10'd_1) ;
				// Set hsync
				hysnc_reg <= LOW ;
				// State transition
				h_state <= (h_counter == H_PULSE)?H_BACK_STATE:H_PULSE_STATE ;
			end
			if (h_state == H_BACK_STATE) begin
				// Iterate horizontal counter, zero at end of H_FRONT mode
				h_counter <= (h_counter==H_BACK)?10'd_0:(h_counter + 10'd_1) ;
				// Set hsync
				hysnc_reg <= HIGH ;
				// State transition
				h_state <= (h_counter == H_BACK)?H_ACTIVE_STATE:H_BACK_STATE ;
				// Signal line complete at state transition (offset by 1 for synchronous state transition)
				line_done <= (h_counter == (H_BACK-1))?HIGH:LOW ;
			end
			//////////////////////////////////////////////////////////////////////////
			///////////////////////// VERTICAL ///////////////////////////////////////
			//////////////////////////////////////////////////////////////////////////
			if (v_state == V_ACTIVE_STATE) begin
				// increment vertical counter at end of line, zero on state transition
				v_counter <= (line_done==HIGH)?((v_counter==V_ACTIVE)?10'd_0:(v_counter + 10'd_1)):v_counter ;
				// set vsync in active mode
				vsync_reg <= HIGH ;
				// state transition - only on end of lines
				v_state <= (line_done==HIGH)?((v_counter==V_ACTIVE)?V_FRONT_STATE:V_ACTIVE_STATE):V_ACTIVE_STATE ;
			end
			if (v_state == V_FRONT_STATE) begin
				// increment vertical counter at end of line, zero on state transition
				v_counter <= (line_done==HIGH)?((v_counter==V_FRONT)?10'd_0:(v_counter + 10'd_1)):v_counter ;
				// set vsync in front porch
				vsync_reg <= HIGH ;
				// state transition
				v_state <= (line_done==HIGH)?((v_counter==V_FRONT)?V_PULSE_STATE:V_FRONT_STATE):V_FRONT_STATE ;
			end
			if (v_state == V_PULSE_STATE) begin
				// increment vertical counter at end of line, zero on state transition
				v_counter <= (line_done==HIGH)?((v_counter==V_PULSE)?10'd_0:(v_counter + 10'd_1)):v_counter ;
				// clear vsync in pulse
				vsync_reg <= LOW ;
				// state transition
				v_state <= (line_done==HIGH)?((v_counter==V_PULSE)?V_BACK_STATE:V_PULSE_STATE):V_PULSE_STATE ;
			end
			if (v_state == V_BACK_STATE) begin
				// increment vertical counter at end of line, zero on state transition
				v_counter <= (line_done==HIGH)?((v_counter==V_BACK)?10'd_0:(v_counter + 10'd_1)):v_counter ;
				// set vsync in back porch
				vsync_reg <= HIGH ;
				// state transition
				v_state <= (line_done==HIGH)?((v_counter==V_BACK)?V_ACTIVE_STATE:V_BACK_STATE):V_BACK_STATE ;
			end

			//////////////////////////////////////////////////////////////////////////
			//////////////////////////////// COLOR OUT ///////////////////////////////
			//////////////////////////////////////////////////////////////////////////
			red_reg 		<= (h_state==H_ACTIVE_STATE)?((v_state==V_ACTIVE_STATE)?{color_in[7:5],5'd_0}:8'd_0):8'd_0 ;
			green_reg 	<= (h_state==H_ACTIVE_STATE)?((v_state==V_ACTIVE_STATE)?{color_in[4:2],5'd_0}:8'd_0):8'd_0 ;
			blue_reg 	<= (h_state==H_ACTIVE_STATE)?((v_state==V_ACTIVE_STATE)?{color_in[1:0],6'd_0}:8'd_0):8'd_0 ;
			
 	 	end
	end
	// Assign output values
	assign hsync = hysnc_reg ;
	assign vsync = vsync_reg ;
	assign red = red_reg ;
	assign green = green_reg ;
	assign blue = blue_reg ;
	assign clk = clock ;
	assign sync = 1'b_0 ;
	assign blank = hysnc_reg & vsync_reg ;
	// The x/y coordinates that should be available on the NEXT cycle
	assign next_x = (h_state==H_ACTIVE_STATE)?h_counter:10'd_0 ;
	assign next_y = (v_state==V_ACTIVE_STATE)?v_counter:10'd_0 ;

endmodule




//============================================================
// M10K module for testing
//============================================================
// See example 12-16 in 
// http://people.ece.cornell.edu/land/courses/ece5760/DE1_SOC/HDL_style_qts_qii51007.pdf
//============================================================

module M10K_1000_8( 
    output reg [7:0] q,
    input [7:0] d,
    input [18:0] write_address, read_address,
    input we, clk
);
	 // force M10K ram style
	 // 307200 words of 8 bits
    reg [7:0] mem [307200:0]  /* synthesis ramstyle = "no_rw_check, M10K" */;
	 
    always @ (posedge clk) begin
        if (we) begin
            mem[write_address] <= d;
		  end
        q <= mem[read_address]; // q doesn't get d in this clock cycle
    end
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
    vy_next,
	 hit_counter_in,
	 hit_counter_out );

    input [9:0] x_prev, y_prev, box_length;
    input signed [9:0] vx_prev, vy_prev; 
	 input [9:0] hit_counter_in;
    output [9:0] x_next, y_next;
    output signed [9:0] vx_next, vy_next;
	 output [9:0] hit_counter_out;

    assign vx_next = ( ((x_prev + vx_prev) >= (10'd320 + box_length)) || ((x_prev + vx_prev) <= (10'd320 - box_length)) ) ? -vx_prev : vx_prev;
    assign vy_next = ( ((y_prev + vy_prev) >= (10'd240 + box_length)) || ((y_prev + vy_prev) <= (10'd240 - box_length)) ) ? -vy_prev : vy_prev;
	 // assign wall_hit = ( vx_next != vx_prev ) || ( vy_next != vy_prev );
	 assign hit_counter_out = ( ( vx_next != vx_prev ) || ( vy_next != vy_prev ) ) ? hit_counter_in + 10'd1 : hit_counter_in;
	 
    assign x_next = ( (x_prev + vx_next) <= (10'd320 - box_length)) ? (10'd320 - box_length + 1) : ( (x_prev + vx_next) >= (10'd320 + box_length)) ? (10'd320 + box_length - 1) : x_prev + vx_next;
    assign y_next = ( (y_prev + vy_prev) <= (10'd240 - box_length)) ? (10'd240 - box_length + 1) : ( (y_prev + vy_prev) >= (10'd240 + box_length)) ? (10'd240 + box_length - 1) : y_prev + vy_next;
	 
endmodule

//////////////////////////////////////////////////
//// random number generator ////////////////////
//////////////////////////////////////////////////

module LFSR (
    input clock,
    input reset,
    output [12:0] rnd,
	output done );

	reg [12:0] random, random_next, random_done;
	reg [3:0] count, count_next; //to keep track of the shifts

    wire feedback = random[12] ^ random[3] ^ random[2] ^ random[0]; 

	always @ (posedge clock) begin
		if (~reset) begin
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
			count_next = 0;
			random_done = random; //assign the random number to output after 13 shifts
		end
	 
	end

	assign rnd = random_done;
	assign done = ( count >= 4'd13 ) ? 1 : 0;

endmodule
