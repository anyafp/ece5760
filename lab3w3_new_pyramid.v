

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

wire			[15: 0]	hex3_hex0;
//wire			[15: 0]	hex5_hex4;

//assign HEX0 = ~hex3_hex0[ 6: 0]; // hex3_hex0[ 6: 0]; 
//assign HEX1 = ~hex3_hex0[14: 8];
//assign HEX2 = ~hex3_hex0[22:16];
//assign HEX3 = ~hex3_hex0[30:24];
assign HEX4 = 7'b1111111;
assign HEX5 = 7'b1111111;
assign HEX3 = 7'b1111111;
assign HEX2 = 7'b1111111;
assign HEX1 = 7'b1111111;
assign HEX0 = 7'b1111111;

//=======================================================
// FSM for 30 drums
//=======================================================

// M10K variables
wire signed [17:0] q [74:0], q_prev [74:0]; // read value
reg signed [17:0] d [74:0], d_prev [74:0]; // write value
reg [8:0] w_add [74:0], w_add_prev [74:0];
reg [8:0] r_add [74:0], r_add_prev [74:0];
reg [74:0] we, we_prev;

// Drum node variables
reg [17:0] rho_eff = 18'b0_00010000000000000;
reg signed [17:0] u_up [74:0];
reg signed [17:0] u [74:0];
reg signed [17:0] u_down [74:0];
reg signed [17:0] u_prev [74:0];
wire signed [17:0] u_next [74:0];
reg signed [17:0] u_bottom [74:0];

reg [2:0] state_drum [74:0];
reg signed [17:0] output_val;
reg signed [17:0] int_val;
reg done_flag = 1'b0;
reg audio_done = 1'b0;
wire signed [17:0] u_g;
reg signed [17:0] rho_0 = 18'b0_01000000000000000;

reg [31:0] drum_timer ;
reg [31:0] final_time;

wire signed [17:0] out_init_ampl [74:0];

// Index
reg [8:0] j [74:0];
reg [8:0] n [74:0];

wire arm_reset;
wire [31:0] arm_incr;
wire [31:0] arm_rho;
wire [31:0] arm_rows;

reg [8:0] num_rows = 9'd30;
wire [8:0] half_rows;

assign half_rows = num_rows>>1;

reg init_reset[74:0];
wire init_done[74:0];
reg total_init_done[74:0];

// Initializing node variables
reg [17:0] incr = 18'b0_01000000000000000;

signed_mult mul_rho ( .out(u_g), .a(int_val >>> arm_rho), .b(int_val >>> arm_rho) );

genvar i;
generate
	for ( i = 0; i < 75; i = i + 1 ) begin: cols

		M10K_512_20 m10k ( q[i], d[i], w_add[i], r_add[i], we[i], CLOCK_50 );
		M10K_512_20 m10k_prev ( q_prev[i], d_prev[i], w_add_prev[i], r_add_prev[i], we_prev[i], CLOCK_50 );
		pyramid_init init_vals ( .out(out_init_ampl[i]), .clock(CLOCK_50), .reset(init_reset[i]), .done(init_done[i]), .i(i[8:0]), .j(j[i]), .total_i(9'd74), .total_j(num_rows-9'd1), .incr(incr) );
			
		drum node (
			.rho_eff( rho_eff ),
			.u( ( j[i] == 9'b0 ) ? u_bottom[i] : u[i] ),
			.u_right( ( i == 0 ) ? 18'd0 : ( j[i] == 9'b0 ) ? u_bottom[i-1] : u[i-1] ),
			.u_left( ( i == 74 ) ? 18'd0 : ( j[i] == 9'b0 ) ? u_bottom[i+1] : u[i+1] ),
			.u_up( ( j[i] == num_rows-9'd1 ) ? 18'b0 : u_up[i] ),
			.u_down( ( j[i] == 9'b0  ) ? 18'b0 : u_down[i] ),
			.u_prev( u_prev[i] ),
			.u_next( u_next[i] ) 
		);

		always @ ( posedge CLOCK_50 ) begin

			if ( ~arm_reset || ~KEY[0] ) begin
				state_drum[i] <= 3'd0;
				init_reset[i] <= 0;
			end
			else begin
				// STATE 0 (RESET)
				if ( state_drum[i] == 3'd0 ) begin
					state_drum[i] <= 3'd1; 
					j[i] <= 9'd0;
					n[i] <= 9'd0;
					total_init_done[i] <= 1'b0;
					if ( i == 0 ) num_rows <= arm_rows[8:0];
					if ( i == 0 ) incr <= arm_incr[17:0];
					init_reset[i] <= 1;
				end
				// STATE 1 (INIT)
				else if ( state_drum[i] == 3'd1 ) begin

					// Once all nodes are initialized
					if ( j[i] == num_rows ) begin
						
						if ( total_init_done == 75'd37778931862957161709567 ) begin
							state_drum[i] <= 3'd2;
							j[i] <= 9'd0;
							we[i] <= 1'b0;
							if ( i == 0 ) drum_timer <= 0;
							// set up read
							r_add[i] <= 9'd1; // read u_up M10K
							we[i] <= 0;
							r_add_prev[i] <= 9'd0; // read u_prev M10K 
							we_prev[i] <= 0;
							total_init_done[i] <= 1'b1;
						end
						else begin
							state_drum[i] <= 3'd1;
						end
						
					end
					else begin
						init_reset[i] <= 1;
						if ( init_done[i] == 1 ) begin
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
							state_drum[i] <= 3'd1;
							init_reset[i] <= 0;
						end
					end
				end
				// STATE 2 (Wait for M10K to see read addr)
				else if ( state_drum[i] == 3'd2 ) begin
					if ( i == 0 ) drum_timer <= drum_timer + 1;
					if ( i == 0 ) done_flag <= 1'b0;
					state_drum[i] <= 3'd3;
				
				end
				// STATE 3 (Setting inputs)
				else if ( state_drum[i] == 3'd3 ) begin
					if ( i == 0 ) drum_timer <= drum_timer + 1;
					 // If not at top
					if ( j[i] < num_rows-9'd1 ) u_up[i] <= q[i];

					u_prev[i] <= q_prev[i];

					state_drum[i] <= 3'd4;
				end
				// STATE 4 (Get u_next and write and set up next row)
				else if ( state_drum[i] == 3'd4 ) begin
					if ( i == 0 ) drum_timer <= drum_timer + 1;
					we[i] <= 1'b1;
					w_add[i] <= j[i];
					d[i] <= u_next[i];

					we_prev[i] <= 1'b1;
					w_add_prev[i] <= j[i];
					d_prev[i] <= ( j[i] == 9'd0 ) ? u_bottom[i] : u[i];

					if ( j[i] == half_rows && i == 37 ) int_val <= u[i];
					if ( j[i] == 9'd0 ) u_bottom[i] <= u_next[i];

					// Set up next row if not at top
					if ( j[i] < num_rows-9'd1 ) begin
						u[i] <= u_up[i];
						u_down[i] <= ( j[i] == 9'd0 ) ? u_bottom[i] : u[i];
						j[i] <= j[i] + 9'd1;
						state_drum[i] <= 3'd2;
						// set up read 
						// If not at top
						if ( j[i] + 9'd1 < num_rows-9'd1 ) begin
							r_add[i] <= j[i] + 9'd2; // read u_up M10K
						end
						r_add_prev[i] <= j[i] + 9'd1; // read u_prev M10K 
						
					end
					else begin
						n[i] <= n[i] + 9'd1;
						j[i] <= 9'd0;
						state_drum[i] <= 3'd5;
					end
				end
				// STATE 5 (Output value)
				else if ( state_drum[i] == 3'd5 ) begin
					if ( i == 0 ) begin
						output_val <= int_val;
						if ( rho_0 + u_g < 18'b0_01111101011100001 ) begin
							rho_eff <= rho_0 + u_g;
						end
						else begin
							rho_eff <= 18'b0_01111101011100001;
						end
						done_flag <= 1'b1;
					end
					if ( audio_done == 1'b1 ) begin
						if ( i == 0 ) drum_timer <= 1'b0;
						if ( i == 0 ) final_time <= drum_timer;
						// set up read
						r_add[i] <= 9'd1; // read u_up M10K
						we[i] <= 0;
						r_add_prev[i] <= 9'd0; // read u_prev M10K 
						we_prev[i] <= 0;
						state_drum[i] <= 3'd2;
					end
					else begin
						state_drum[i] <= 3'd5;
					end
				end
//				// STATE 6 (Output value)
//				else if ( state_drum[i] == 3'd6 ) begin
//					if ( i == 0 ) begin
//						output_val <= int_val;
//						if ( rho_0 + u_g < 18'b0_01111101011100001 ) begin
//							rho_eff <= rho_0 + u_g;
//						end
//						else begin
//							rho_eff <= 18'b0_01111101011100001;
//						end
//						done_flag <= 1'b1;
//					end
//					if ( audio_done == 1'b1 ) begin
//						state_drum[i] <= 3'd2;
//						if ( i == 0 ) drum_timer <= 1'b0;
//					end
//					else begin
//						state_drum[i] <= 3'd6;
//						if ( i == 0 ) final_time <= drum_timer;
//					end
//				end
			end
		end
	end
endgenerate

//=======================================================
// Bus controller for AVALON bus-master
//=======================================================
// computes DDS for sine wave and fills audio FIFO

reg [31:0] bus_addr ; // Avalon address
// see 
// ftp://ftp.altera.com/up/pub/Altera_Material/15.1/University_Program_IP_Cores/Audio_Video/Audio.pdf
// for addresses
wire [31:0] audio_base_address = 32'h00003040 ;  // Avalon address
wire [31:0] audio_fifo_address = 32'h00003044 ;  // Avalon address +4 offset
wire [31:0] audio_left_address = 32'h00003048 ;  // Avalon address +8
wire [31:0] audio_right_address = 32'h0000304c ;  // Avalon address +12
reg [3:0] bus_byte_enable ; // four bit byte read/write mask
reg bus_read  ;       // high when requesting data
reg bus_write ;      //  high when writing data
reg [31:0] bus_write_data ; //  data to send to Avalog bus
wire bus_ack  ;       //  Avalon bus raises this when done
wire [31:0] bus_read_data ; // data from Avalon bus
reg [30:0] timer ;
reg [3:0] state ;
wire state_clock ;

// current free words in audio interface
reg [7:0] fifo_space ;
// debug check of space
assign LEDR = fifo_space ;

// use 4-byte-wide bus-master	 
//assign bus_byte_enable = 4'b1111;

// DDS signals
reg [31:0] dds_accum ;
// DDS LUT
wire [15:0] sine_out ;
//sync_rom sineTable(CLOCK_50, dds_accum[31:24], sine_out);

// get some signals exposed
// connect bus master signals to i/o for probes
assign GPIO_0[0] = bus_write ;
assign GPIO_0[1] = bus_read ;
assign GPIO_0[2] = bus_ack ;
//assign GPIO_0[3] = ??? ;

always @(posedge CLOCK_50) begin //CLOCK_50

	// reset state machine and read/write controls
	if (~KEY[0]) begin
		state <= 0 ;
		bus_read <= 0 ; // set to one if a read opeation from bus
		bus_write <= 0 ; // set to one if a write operation to bus
		timer <= 0;
	end
	else begin
		// timer just for deubgging
		timer <= timer + 1;
	end
	
	// set up read FIFO available space
	if (state==4'd0) begin
		bus_addr <= audio_fifo_address ;
		bus_read <= 1'b1 ;
		bus_byte_enable <= 4'b1111;
		state <= 4'd1 ; // wait for read ACK
	end
	
	// wait for read ACK and read the fifo available
	// bus ACK is high when data is available
	if (state==4'd1 && bus_ack==1) begin
		state <= 4'd2 ; //4'd2
		// FIFO space is in high byte
		fifo_space <= (bus_read_data>>24) ;
		// end the read
		bus_read <= 1'b0 ;
	end
	
	// When there is room in the FIFO
	// -- compute next DDS sine sample
	// -- start write to fifo for each channel
	// -- first the left channel
	if (state==4'd2 && fifo_space>8'd2 && done_flag == 1'b1) begin // 
		state <= 4'd3;	
		// IF SW=10'h200 
		// and Fout = (sample_rate)/(2^32)*{SW[9:0], 16'b0}
		// then Fout=48000/(2^32)*(2^25) = 375 Hz
		// convert 16-bit table to 32-bit format
		bus_write_data <=  output_val <<< 14 ;
		bus_addr <= audio_left_address ;
		bus_byte_enable <= 4'b1111;
		bus_write <= 1'b1 ;
		audio_done <= 1'b1;
	end	
	// if no space, try again later
	else if (state==4'd2 && fifo_space<=8'd2) begin
		state <= 4'b0 ;
	end
	
	// detect bus-transaction-complete ACK 
	// for left channel write
	// You MUST do this check
	if (state==4'd3 && bus_ack==1) begin
		state <= 4'd4 ;
		bus_write <= 0;
		audio_done <= 1'b0;
	end
	
	// -- now the right channel
	if (state==4'd4) begin // 
		state <= 4'd5;	
		//bus_write_data <=  output_val <<< 14 ;
		bus_addr <= audio_right_address ;
		bus_write <= 1'b1 ;
	end	
	
	// detect bus-transaction-complete ACK
	// for right channel write
	// You MUST do this check
	if (state==4'd5 && bus_ack==1) begin
		state <= 4'd0 ;
		bus_write <= 0;
	end
	
end // always @(posedge state_clock)


//=======================================================
//  Structural coding
//=======================================================

Computer_System The_System (
	////////////////////////////////////
	// FPGA Side
	////////////////////////////////////

	// Global signals
	.system_pll_ref_clk_clk					(CLOCK_50),
	.system_pll_ref_reset_reset			(1'b0),
	.sdram_clk_clk								(state_clock),

	// AV Config
	.av_config_SCLK							(FPGA_I2C_SCLK),
	.av_config_SDAT							(FPGA_I2C_SDAT),

	// Audio Subsystem
	.audio_pll_ref_clk_clk					(CLOCK3_50),
	.audio_pll_ref_reset_reset				(1'b0),
	.audio_clk_clk								(AUD_XCK),
	.audio_ADCDAT								(AUD_ADCDAT),
	.audio_ADCLRCK								(AUD_ADCLRCK),
	.audio_BCLK									(AUD_BCLK),
	.audio_DACDAT								(AUD_DACDAT),
	.audio_DACLRCK								(AUD_DACLRCK),

	// bus-master state machine interface
	.bus_master_audio_external_interface_address     (bus_addr),     
	.bus_master_audio_external_interface_byte_enable (bus_byte_enable), 
	.bus_master_audio_external_interface_read        (bus_read),        
	.bus_master_audio_external_interface_write       (bus_write),       
	.bus_master_audio_external_interface_write_data  (bus_write_data),  
	.bus_master_audio_external_interface_acknowledge (bus_ack),                                  
	.bus_master_audio_external_interface_read_data   (bus_read_data),   
	
	.timer_pio_ext_export (final_time),
	.reset_pio_ext_export (arm_reset),
	.incr_pio_ext_export  (arm_incr),
	.rho_gain_pio_ext_export (arm_rho),
	.num_rows_pio_ext_export (arm_rows), 
	
	
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


endmodule

//////////////////////////////////////////////////
////////////	Sin Wave ROM Table	//////////////
//////////////////////////////////////////////////
// produces a 2's comp, 16-bit, approximation
// of a sine wave, given an input phase (address)
module sync_rom (clock, address, sine);
input clock;
input [7:0] address;
output [15:0] sine;
reg signed [15:0] sine;
always@(posedge clock)
begin
    case(address)
    		8'h00: sine = 16'h0000 ;
			8'h01: sine = 16'h0192 ;
			8'h02: sine = 16'h0323 ;
			8'h03: sine = 16'h04b5 ;
			8'h04: sine = 16'h0645 ;
			8'h05: sine = 16'h07d5 ;
			8'h06: sine = 16'h0963 ;
			8'h07: sine = 16'h0af0 ;
			8'h08: sine = 16'h0c7c ;
			8'h09: sine = 16'h0e05 ;
			8'h0a: sine = 16'h0f8c ;
			8'h0b: sine = 16'h1111 ;
			8'h0c: sine = 16'h1293 ;
			8'h0d: sine = 16'h1413 ;
			8'h0e: sine = 16'h158f ;
			8'h0f: sine = 16'h1598 ;
			8'h10: sine = 16'h187d ;
			8'h11: sine = 16'h19ef ;
			8'h12: sine = 16'h1b5c ;
			8'h13: sine = 16'h1cc5 ;
			8'h14: sine = 16'h1e2a ;
			8'h15: sine = 16'h1f8b ;
			8'h16: sine = 16'h20e6 ;
			8'h17: sine = 16'h223c ;
			8'h18: sine = 16'h238d ;
			8'h19: sine = 16'h24d9 ;
			8'h1a: sine = 16'h261f ;
			8'h1b: sine = 16'h275f ;
			8'h1c: sine = 16'h2899 ;
			8'h1d: sine = 16'h29cc ;
			8'h1e: sine = 16'h2afa ;
			8'h1f: sine = 16'h2c20 ;
			8'h20: sine = 16'h2d40 ;
			8'h21: sine = 16'h2e59 ;
			8'h22: sine = 16'h2f6b ;
			8'h23: sine = 16'h3075 ;
			8'h24: sine = 16'h3178 ;
			8'h25: sine = 16'h3273 ;
			8'h26: sine = 16'h3366 ;
			8'h27: sine = 16'h3452 ;
			8'h28: sine = 16'h3535 ;
			8'h29: sine = 16'h3611 ;
			8'h2a: sine = 16'h36e4 ;
			8'h2b: sine = 16'h37ae ;
			8'h2c: sine = 16'h3870 ;
			8'h2d: sine = 16'h3929 ;
			8'h2e: sine = 16'h39da ;
			8'h2f: sine = 16'h3a81 ;
			8'h30: sine = 16'h3b1f ;
			8'h31: sine = 16'h3bb5 ;
			8'h32: sine = 16'h3c41 ;
			8'h33: sine = 16'h3cc4 ;
			8'h34: sine = 16'h3d3d ;
			8'h35: sine = 16'h3dad ;
			8'h36: sine = 16'h3e14 ;
			8'h37: sine = 16'h3e70 ;
			8'h38: sine = 16'h3ec4 ;
			8'h39: sine = 16'h3f0d ;
			8'h3a: sine = 16'h3f4d ;
			8'h3b: sine = 16'h3f83 ;
			8'h3c: sine = 16'h3fb0 ;
			8'h3d: sine = 16'h3fd2 ;
			8'h3e: sine = 16'h3feb ;
			8'h3f: sine = 16'h3ffa ;
			8'h40: sine = 16'h3fff ;
			8'h41: sine = 16'h3ffa ;
			8'h42: sine = 16'h3feb ;
			8'h43: sine = 16'h3fd2 ;
			8'h44: sine = 16'h3fb0 ;
			8'h45: sine = 16'h3f83 ;
			8'h46: sine = 16'h3f4d ;
			8'h47: sine = 16'h3f0d ;
			8'h48: sine = 16'h3ec4 ;
			8'h49: sine = 16'h3e70 ;
			8'h4a: sine = 16'h3e14 ;
			8'h4b: sine = 16'h3dad ;
			8'h4c: sine = 16'h3d3d ;
			8'h4d: sine = 16'h3cc4 ;
			8'h4e: sine = 16'h3c41 ;
			8'h4f: sine = 16'h3bb5 ;
			8'h50: sine = 16'h3b1f ;
			8'h51: sine = 16'h3a81 ;
			8'h52: sine = 16'h39da ;
			8'h53: sine = 16'h3929 ;
			8'h54: sine = 16'h3870 ;
			8'h55: sine = 16'h37ae ;
			8'h56: sine = 16'h36e4 ;
			8'h57: sine = 16'h3611 ;
			8'h58: sine = 16'h3535 ;
			8'h59: sine = 16'h3452 ;
			8'h5a: sine = 16'h3366 ;
			8'h5b: sine = 16'h3273 ;
			8'h5c: sine = 16'h3178 ;
			8'h5d: sine = 16'h3075 ;
			8'h5e: sine = 16'h2f6b ;
			8'h5f: sine = 16'h2e59 ;
			8'h60: sine = 16'h2d40 ;
			8'h61: sine = 16'h2c20 ;
			8'h62: sine = 16'h2afa ;
			8'h63: sine = 16'h29cc ;
			8'h64: sine = 16'h2899 ;
			8'h65: sine = 16'h275f ;
			8'h66: sine = 16'h261f ;
			8'h67: sine = 16'h24d9 ;
			8'h68: sine = 16'h238d ;
			8'h69: sine = 16'h223c ;
			8'h6a: sine = 16'h20e6 ;
			8'h6b: sine = 16'h1f8b ;
			8'h6c: sine = 16'h1e2a ;
			8'h6d: sine = 16'h1cc5 ;
			8'h6e: sine = 16'h1b5c ;
			8'h6f: sine = 16'h19ef ;
			8'h70: sine = 16'h187d ;
			8'h71: sine = 16'h1598 ;
			8'h72: sine = 16'h158f ;
			8'h73: sine = 16'h1413 ;
			8'h74: sine = 16'h1293 ;
			8'h75: sine = 16'h1111 ;
			8'h76: sine = 16'h0f8c ;
			8'h77: sine = 16'h0e05 ;
			8'h78: sine = 16'h0c7c ;
			8'h79: sine = 16'h0af0 ;
			8'h7a: sine = 16'h0963 ;
			8'h7b: sine = 16'h07d5 ;
			8'h7c: sine = 16'h0645 ;
			8'h7d: sine = 16'h04b5 ;
			8'h7e: sine = 16'h0323 ;
			8'h7f: sine = 16'h0192 ;
			8'h80: sine = 16'h0000 ;
			8'h81: sine = 16'hfe6e ;
			8'h82: sine = 16'hfcdd ;
			8'h83: sine = 16'hfb4b ;
			8'h84: sine = 16'hf9bb ;
			8'h85: sine = 16'hf82b ;
			8'h86: sine = 16'hf69d ;
			8'h87: sine = 16'hf510 ;
			8'h88: sine = 16'hf384 ;
			8'h89: sine = 16'hf1fb ;
			8'h8a: sine = 16'hf074 ;
			8'h8b: sine = 16'heeef ;
			8'h8c: sine = 16'hed6d ;
			8'h8d: sine = 16'hebed ;
			8'h8e: sine = 16'hea71 ;
			8'h8f: sine = 16'he8f8 ;
			8'h90: sine = 16'he783 ;
			8'h91: sine = 16'he611 ;
			8'h92: sine = 16'he4a4 ;
			8'h93: sine = 16'he33b ;
			8'h94: sine = 16'he1d6 ;
			8'h95: sine = 16'he075 ;
			8'h96: sine = 16'hdf1a ;
			8'h97: sine = 16'hddc4 ;
			8'h98: sine = 16'hdc73 ;
			8'h99: sine = 16'hdb27 ;
			8'h9a: sine = 16'hd9e1 ;
			8'h9b: sine = 16'hd8a1 ;
			8'h9c: sine = 16'hd767 ;
			8'h9d: sine = 16'hd634 ;
			8'h9e: sine = 16'hd506 ;
			8'h9f: sine = 16'hd3e0 ;
			8'ha0: sine = 16'hd2c0 ;
			8'ha1: sine = 16'hd1a7 ;
			8'ha2: sine = 16'hd095 ;
			8'ha3: sine = 16'hcf8b ;
			8'ha4: sine = 16'hce88 ;
			8'ha5: sine = 16'hcd8d ;
			8'ha6: sine = 16'hcc9a ;
			8'ha7: sine = 16'hcbae ;
			8'ha8: sine = 16'hcacb ;
			8'ha9: sine = 16'hc9ef ;
			8'haa: sine = 16'hc91c ;
			8'hab: sine = 16'hc852 ;
			8'hac: sine = 16'hc790 ;
			8'had: sine = 16'hc6d7 ;
			8'hae: sine = 16'hc626 ;
			8'haf: sine = 16'hc57f ;
			8'hb0: sine = 16'hc4e1 ;
			8'hb1: sine = 16'hc44b ;
			8'hb2: sine = 16'hc3bf ;
			8'hb3: sine = 16'hc33c ;
			8'hb4: sine = 16'hc2c3 ;
			8'hb5: sine = 16'hc253 ;
			8'hb6: sine = 16'hc1ec ;
			8'hb7: sine = 16'hc190 ;
			8'hb8: sine = 16'hc13c ;
			8'hb9: sine = 16'hc0f3 ;
			8'hba: sine = 16'hc0b3 ;
			8'hbb: sine = 16'hc07d ;
			8'hbc: sine = 16'hc050 ;
			8'hbd: sine = 16'hc02e ;
			8'hbe: sine = 16'hc015 ;
			8'hbf: sine = 16'hc006 ;
			8'hc0: sine = 16'hc001 ;
			8'hc1: sine = 16'hc006 ;
			8'hc2: sine = 16'hc015 ;
			8'hc3: sine = 16'hc02e ;
			8'hc4: sine = 16'hc050 ;
			8'hc5: sine = 16'hc07d ;
			8'hc6: sine = 16'hc0b3 ;
			8'hc7: sine = 16'hc0f3 ;
			8'hc8: sine = 16'hc13c ;
			8'hc9: sine = 16'hc190 ;
			8'hca: sine = 16'hc1ec ;
			8'hcb: sine = 16'hc253 ;
			8'hcc: sine = 16'hc2c3 ;
			8'hcd: sine = 16'hc33c ;
			8'hce: sine = 16'hc3bf ;
			8'hcf: sine = 16'hc44b ;
			8'hd0: sine = 16'hc4e1 ;
			8'hd1: sine = 16'hc57f ;
			8'hd2: sine = 16'hc626 ;
			8'hd3: sine = 16'hc6d7 ;
			8'hd4: sine = 16'hc790 ;
			8'hd5: sine = 16'hc852 ;
			8'hd6: sine = 16'hc91c ;
			8'hd7: sine = 16'hc9ef ;
			8'hd8: sine = 16'hcacb ;
			8'hd9: sine = 16'hcbae ;
			8'hda: sine = 16'hcc9a ;
			8'hdb: sine = 16'hcd8d ;
			8'hdc: sine = 16'hce88 ;
			8'hdd: sine = 16'hcf8b ;
			8'hde: sine = 16'hd095 ;
			8'hdf: sine = 16'hd1a7 ;
			8'he0: sine = 16'hd2c0 ;
			8'he1: sine = 16'hd3e0 ;
			8'he2: sine = 16'hd506 ;
			8'he3: sine = 16'hd634 ;
			8'he4: sine = 16'hd767 ;
			8'he5: sine = 16'hd8a1 ;
			8'he6: sine = 16'hd9e1 ;
			8'he7: sine = 16'hdb27 ;
			8'he8: sine = 16'hdc73 ;
			8'he9: sine = 16'hddc4 ;
			8'hea: sine = 16'hdf1a ;
			8'heb: sine = 16'he075 ;
			8'hec: sine = 16'he1d6 ;
			8'hed: sine = 16'he33b ;
			8'hee: sine = 16'he4a4 ;
			8'hef: sine = 16'he611 ;
			8'hf0: sine = 16'he783 ;
			8'hf1: sine = 16'he8f8 ;
			8'hf2: sine = 16'hea71 ;
			8'hf3: sine = 16'hebed ;
			8'hf4: sine = 16'hed6d ;
			8'hf5: sine = 16'heeef ;
			8'hf6: sine = 16'hf074 ;
			8'hf7: sine = 16'hf1fb ;
			8'hf8: sine = 16'hf384 ;
			8'hf9: sine = 16'hf510 ;
			8'hfa: sine = 16'hf69d ;
			8'hfb: sine = 16'hf82b ;
			8'hfc: sine = 16'hf9bb ;
			8'hfd: sine = 16'hfb4b ;
			8'hfe: sine = 16'hfcdd ;
			8'hff: sine = 16'hfe6e ;
	endcase
end
endmodule

//////////////////////////////////////////////////
//// drum ///////////
//////////////////////////////////////////////////

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

    assign u_next = int_val - (int_val >>> 11);

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

module pyramid_init (out, clock, reset, done, i, j, total_i, total_j, incr);
    output signed [17:0] out;
	 output done;
    input [8:0] i;
    input [8:0] j;
    input [8:0] total_i;
    input [8:0] total_j;
    input [17:0] incr;
	 input clock; 
	 input reset;

    wire [8:0] int_i, int_j, int_out;
	 reg signed [17:0] out_temp;
	 reg [8:0] count; 
	 
	 always @ (posedge clock) begin 
		if (~reset) begin 
			count <= 0;
			out_temp <= 0;
		end
		else if ( done == 0 ) begin
			out_temp <= out_temp + incr;
			count <= count + 1;
		end
	 end
	 

    assign int_i = ( ( total_i - i ) >= i ) ? i : ( total_i - i );
    assign int_j = ( ( total_j - j ) >= j ) ? j : ( total_j - j );

    assign int_out = ( int_i >= int_j ) ? int_j : int_i;

    assign out = out_temp;
	 
	 assign done = ( count > int_out );
	 
endmodule
//////////////////////////////////////////////////
