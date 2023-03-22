
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

    reg [8:0] num_rows = 9'd20;
    wire [8:0] half_rows;

    assign half_rows = num_rows>>1;

    reg init_reset[74:0];
    wire init_done[74:0];

    // Initializing node variables
    reg [17:0] incr = 18'b0_00000010000000000;

    reg [19:0] total_done = 20'b0;

    signed_mult mul_rho ( .out(u_g), .a(int_val >>> 3), .b(int_val >>> 3) );

    genvar i;
    generate
        for ( i = 0; i < 20; i = i + 1 ) begin: cols

            M10K_512_20 m10k ( q[i], d[i], w_add[i], r_add[i], we[i], clk_50 );
            M10K_512_20 m10k_prev ( q_prev[i], d_prev[i], w_add_prev[i], r_add_prev[i], we_prev[i], clk_50 );
            pyramid_init init_vals ( .out(out_init_ampl[i]), .clock(clk_50), .reset(init_reset[i]), .done(init_done[i]), .i(i[8:0]), .j(j[i]), .total_i(9'd19), .total_j(num_rows-9'd1), .incr(incr) );
                
            drum node (
                .rho_eff( rho_eff ),
                .u( ( j[i] == 9'b0 ) ? u_bottom[i] : u[i] ),
                .u_right( ( i == 0 ) ? 18'd0 : ( j[i] == 9'b0 ) ? u_bottom[i-1] : u[i-1] ),
                .u_left( ( i == 19 ) ? 18'd0 : ( j[i] == 9'b0 ) ? u_bottom[i+1] : u[i+1] ),
                .u_up( ( j[i] == num_rows-9'd1 ) ? 18'b0 : u_up[i] ),
                .u_down( ( j[i] == 9'b0  ) ? 18'b0 : u_down[i] ),
                .u_prev( u_prev[i] ),
                .u_next( u_next[i] ) 
            );

            always @ ( posedge clk_50 ) begin

                if ( ~reset ) begin
                    state_drum[i] <= 3'd0;
                    init_reset[i] <= 0;
                end
                else begin
                    // STATE 0 (RESET)
                    if ( state_drum[i] == 3'd0 ) begin
                        state_drum[i] <= 3'd1; 
                        j[i] <= 9'd0;
                        n[i] <= 9'd0;
                        if ( i == 0 ) num_rows <= 9'd20;
                        if ( i == 0 ) incr <= 18'b0_00000000100000000;
                        init_reset[i] <= 1;
                    end
                    // STATE 1 (INIT)
                    else if ( state_drum[i] == 3'd1 ) begin

                        if ( total_done == 20'd1048575 ) begin
                            state_drum[i] <= 3'd2;
                            j[i] <= 9'd0;
                            if ( i == 0 ) drum_timer <= 0;
                            // set up read
                            r_add[i] <= 9'd1; // read u_up M10K
                            r_add_prev[i] <= 9'd0; // read u_prev M10K 
                        end

                        // Once all nodes are initialized
                        else if ( j[i] == num_rows ) begin
                            total_done[i] <= 1'b1;
                            init_reset[i] <= 0;
                            we[i] <= 1'b0;
                            we_prev[i] <= 1'b0;
                        end
                        else begin
                            // init_reset[i] <= 1;
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
                                state_drum[i] <= 3'd6;
                                init_reset[i] <= 0;
                            end
                        end
                    end
                    // STATE 6 (let init module see the reset)
                    else if ( state_drum[i] == 3'd6 ) begin
                        state_drum[i] <= 3'd1;
                        init_reset[i] <= 1;
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

                        if ( j[i] == half_rows && i == 10 ) int_val <= u[i];
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

    assign bus_ack = 1'b1;

    // current free words in audio interface
    reg [7:0] fifo_space = 8'd3;
    // debug check of space
    assign LEDR = fifo_space ;

    // use 4-byte-wide bus-master	 
    //assign bus_byte_enable = 4'b1111;

    // DDS signals
    reg [31:0] dds_accum ;
    // DDS LUT
    wire [15:0] sine_out ;
    //sync_rom sineTable(CLOCK_50, dds_accum[31:24], sine_out);

    always @(posedge clk_50) begin //CLOCK_50

        // reset state machine and read/write controls
        if (~reset) begin
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
            // fifo_space <= (bus_read_data>>24) ;
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
	 
    assign done = ( count >= (int_out + 9'd1) );
	 
endmodule
//////////////////////////////////////////////////
