///////////////////////////////////////
/// 640x480 version!
/// test VGA with hardware video input copy to VGA
// compile with
// gcc fp_test_1.c -o fp1 -lm
///////////////////////////////////////
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/ipc.h> 
#include <sys/shm.h> 
#include <sys/mman.h>
#include <sys/time.h> 
#include <math.h> 
#include "address_map_arm.h" 

// =============================================
// Function Prototypes
// =============================================
void VGA_text (int, int, char *);
void VGA_text_clear();
void VGA_box (int, int, int, int, short);
void VGA_line(int, int, int, int, short) ;
void VGA_disc (int, int, int, short);
int  VGA_read_pixel(int, int) ;
int  video_in_read_pixel(int, int);
void draw_delay(void) ;

// the light weight buss base
void *h2p_lw_virtual_base;

// RAM FPGA command buffer
volatile unsigned int * sram_ptr = NULL ;
void *sram_virtual_base;

// pixel buffer
volatile unsigned int * vga_pixel_ptr = NULL ;
void *vga_pixel_virtual_base;

// character buffer
volatile unsigned int * vga_char_ptr = NULL ;
void *vga_char_virtual_base;

// /dev/mem file id
int fd;

// =============================================
// pixel macro !!!PACKED VGA MEMORY!!!
// =============================================
#define VGA_PIXEL(x,y,color) do{\
	char  *pixel_ptr ;\
	pixel_ptr = (char *)vga_pixel_ptr + ((y)*640) + (x) ;\
	*(char *)pixel_ptr = (color);\
} while(0)

// =============================================
// PIO Pointers
// =============================================
#define X_PIO                 0x00
#define Y_PIO                 0x10
#define X_INCR_PIO            0x20
#define Y_INCR_PIO				    0x30
#define RST_PIO				        0x40
#define ITER_PIO				      0x50

volatile signed int* x_pio_ptr = NULL;
volatile signed int* y_pio_ptr = NULL;
volatile signed int* incr_x_pio_ptr = NULL; 
volatile signed int* incr_y_pio_ptr = NULL;
volatile unsigned char* reset_pio_ptr = NULL;
volatile unsigned int* iter_pio_ptr = NULL;

// =============================================
// Fixed point functions
// =============================================
int float2fix(float);
int float2fix(float a) { return (int)(a*8388608); }

// =============================================
// Measure time
// =============================================
struct timeval t1, t2;
double elapsedTime;
struct timespec delay_time;
char xy_topleft[10], xy_topright[10], xy_bottomleft[10], xy_bottomright[10];
char zoom_print[10], mouse_coord[20]; 
char num_string[20], time_string[50];
char new_coord[40], zoom_val[20], iter_text[40];

// =============================================
// Variables
// =============================================
float x_incr = 0.0046875;        // Real increment value
float y_incr = 0.00416666666667; // Imaginary increment value
float x_val = -2.0;              // Top left real coordinates
float y_val = 1.0;               // Top left imaginary coordinates
int x_vga = 0;
int y_vga = 0;
int x_accum = 0;
int y_accum = 0;
float zoom_x = 1;

// =============================================
// Print data function
// =============================================
void print_data(float x_, float y_, float x_incr, float y_incr, float zoom, int iter) {
  VGA_text_clear();
  
  // Top left xy
  sprintf( xy_topleft, "(%4.4f, %4.4f)", x_, y_ );
	VGA_text (1, 1, xy_topleft);
 
  // Top right xy
  sprintf( xy_bottomleft, "(%4.4f, %4.4f)", (x_+(x_incr*640)), y_ );
	VGA_text (58, 1, xy_bottomleft);
  
  // Bottom right xy
  sprintf( xy_topright, "(%4.4f, %4.4f)", (x_+(x_incr*640)), (y_+(y_incr*480)) );
	VGA_text (58, 58, xy_topright);
 
  // Bottom left xy
  sprintf( xy_bottomleft, "(%4.4f, %4.4f)", x_, (y_+(y_incr*480)) );
	VGA_text (1, 58, xy_bottomleft);
 
  // middle
  sprintf( new_coord, "Middle xy: (%4.4f, %4.4f)", (x_+(x_incr*320)), (y_+(y_incr*240)) );
  VGA_text (10, 6, new_coord);
  
  // zoom
  sprintf( zoom_val, "Zoom: %2.3f x", zoom );
  VGA_text (10, 8, zoom_val);
  
  // iter
  sprintf( iter_text, "Max Iter: %d", iter );
  VGA_text (10, 10, iter_text);
  
  VGA_text (10, 4, time_string);
 	
}


// =============================================
// Main
// =============================================
int main(void)
{
  // ---------------------------------------------
  // Mouse setup
  // ---------------------------------------------
  int fdm, bytes;
  unsigned char data[3];
  const char *pDevice = "/dev/input/mice";
  fdm = open(pDevice, O_RDWR); // Open Mouse
  if(fdm == -1) {
      printf("ERROR Opening %s\n", pDevice);
      return -1;
  }
  int left, middle, right; // Button presses
  signed char x, y;        // Mouse coordinates
  
	delay_time.tv_nsec = 10 ;
	delay_time.tv_sec = 0 ;

	// ---------------------------------------------
  // Get addresses to map
  // ---------------------------------------------
  	
	// === need to mmap: =======================
	// FPGA_CHAR_BASE
	// FPGA_ONCHIP_BASE      
	// HW_REGS_BASE        
  
	// === get FPGA addresses ==================
  // Open /dev/mem
	if( ( fd = open( "/dev/mem", ( O_RDWR | O_SYNC ) ) ) == -1 ) 	{
		printf( "ERROR: could not open \"/dev/mem\"...\n" );
		return( 1 );
	}
    
  // get virtual addr that maps to physical
	// for light weight bus
	h2p_lw_virtual_base = mmap( NULL, HW_REGS_SPAN, ( PROT_READ | PROT_WRITE ), MAP_SHARED, fd, HW_REGS_BASE );	
	if( h2p_lw_virtual_base == MAP_FAILED ) {
		printf( "ERROR: mmap1() failed...\n" );
		close( fd );
		return(1);
	}
 
  // === get PIO pointer addresses ==================
  x_pio_ptr = (signed int *)(h2p_lw_virtual_base + X_PIO);
	y_pio_ptr = (signed int *)(h2p_lw_virtual_base + Y_PIO);
  incr_x_pio_ptr = (signed int *)(h2p_lw_virtual_base + X_INCR_PIO);
	incr_y_pio_ptr = (signed int *)(h2p_lw_virtual_base + Y_INCR_PIO);
	reset_pio_ptr = (unsigned char *)(h2p_lw_virtual_base + RST_PIO);
	iter_pio_ptr = (unsigned int *)(h2p_lw_virtual_base + ITER_PIO);
 
	// === get VGA char addr =====================
	// get virtual addr that maps to physical
	vga_char_virtual_base = mmap( NULL, FPGA_CHAR_SPAN, ( PROT_READ | PROT_WRITE ), MAP_SHARED, fd, FPGA_CHAR_BASE  );	
	if( vga_char_virtual_base == MAP_FAILED ) {
		printf( "ERROR: mmap2() failed...\n" );
		close( fd );
		return(1);
	}
    
  // Get the address that maps to the character 
	vga_char_ptr =(unsigned int *)(vga_char_virtual_base);

	// === get VGA pixel addr ====================
	// get virtual addr that maps to physical SDRAM
	vga_pixel_virtual_base = mmap( NULL, FPGA_ONCHIP_SPAN, ( PROT_READ | PROT_WRITE ), MAP_SHARED, fd, SDRAM_BASE); //SDRAM_BASE	
	if( vga_pixel_virtual_base == MAP_FAILED ) {
		printf( "ERROR: mmap3() failed...\n" );
		close( fd );
		return(1);
	}
  // Get the address that maps to the FPGA pixel buffer
	vga_pixel_ptr =(unsigned int *)(vga_pixel_virtual_base);
	
	// === get RAM FPGA parameter addr =========
	sram_virtual_base = mmap( NULL, FPGA_ONCHIP_SPAN, ( PROT_READ | PROT_WRITE ), MAP_SHARED, fd, FPGA_ONCHIP_BASE); //fp	
	
	if( sram_virtual_base == MAP_FAILED ) {
		printf( "ERROR: mmap3() failed...\n" );
		close( fd );
		return(1);
	}
  // Get the address that maps to the RAM buffer
	sram_ptr = (unsigned int *)(sram_virtual_base);
 
	// ---------------------------------------------
  // Text on VGA
  // ---------------------------------------------

	int pixel_color; // a pixel from the video
	int i,j, count; // video input index
	
	// clear the screen
  // VGA_box (0, 0, 639, 479, 0x03);
	// clear the text
	VGA_text_clear();
 
  *(sram_ptr) = 0; // Reset timing
	
	count = 0;
  
  // ---------------------------------------------
  // Variables for mouse
  // ---------------------------------------------
  float x_incr = 0.0046875;        // Real increment value
  float y_incr = 0.00416666666667; // Imaginary increment value
  float x_val = -2.0;              // Top left real coordinates
  float y_val = 1.0;               // Top left imaginary coordinates
  int x_vga = 0;
  int y_vga = 0;
  int x_accum = 0;
  int y_accum = 0;
  
  // ---------------------------------------------
  // Initialize real and im starting points and incr values
  // ---------------------------------------------
  *(x_pio_ptr) = float2fix(x_val);
  *(y_pio_ptr) = float2fix(y_val);
  *(incr_x_pio_ptr) = float2fix(x_incr);
  *(incr_y_pio_ptr) = float2fix(y_incr);
  
  // ---------------------------------------------
  // Reset sent to FPGA
  // ---------------------------------------------
	*(reset_pio_ptr) = 0;
  usleep( 1 );
	*(reset_pio_ptr) = 1;
  
  // =============================================
  // While 1 loop
  // =============================================
	while(1) {
 
    // after first reset, fpga in state 3
    while (*(sram_ptr)==0) {
    
      // === MOUSE =======================    
      bytes = read(fdm, data, sizeof(data));
  
      if (bytes > 0) {
      
        left = data[0] & 0x1;
        right = data[0] & 0x2;
        middle = data[0] & 0x4;
    
        x = data[1];
        y = data[2];
        
        x_accum += x/2;
        y_accum += y/2;
        
        // middle
        float x_temp = x_val + x_accum*x_incr + x_incr*320;
        float y_temp = y_val + y_accum*y_incr + y_incr*240;
        
        sprintf( new_coord, "Middle xy: (%4.4f, %4.4f)", x_temp, y_temp );
        VGA_text (10, 6, new_coord);
        
        // zoom in if not maxed out
        if ( left == 1 && x_incr > 0.000000715255 && y_incr > 0.000000635788 ) {
        
          x_incr = x_incr/2;
          y_incr = y_incr/2;
          *(incr_x_pio_ptr) = float2fix(x_incr);
          *(incr_y_pio_ptr) = float2fix(y_incr);
          *(reset_pio_ptr) = 0;
          usleep( 1 );
        	*(reset_pio_ptr) = 1;
          zoom_x = zoom_x*2;
    
          print_data(x_val, y_val, x_incr, y_incr, zoom_x, *(iter_pio_ptr)); // Print new info
          
          // Reset accum
          x_accum = 0;
          y_accum = 0;
          
        // zoom out
        } else if ( right == 2 && x < 4.9 && y < 4.3 ) {
          x_incr = x_incr*2;
          y_incr = y_incr*2;
          *(incr_x_pio_ptr) = float2fix(x_incr);
          *(incr_y_pio_ptr) = float2fix(y_incr);
          *(reset_pio_ptr) = 0;
          usleep( 1 );
        	*(reset_pio_ptr) = 1;
          zoom_x = zoom_x/2;
         
          print_data(x_val, y_val, x_incr, y_incr, zoom_x, *(iter_pio_ptr)); // Print new info
          
          // Reset accum
          x_accum = 0;
          y_accum = 0;
        
        // Reset to new coordinates  
        } else if ( middle == 4 ) {
        
          x_val = x_val + x_accum*x_incr;
          y_val = y_val + y_accum*y_incr;
            
          *(x_pio_ptr) = float2fix(x_val);
          *(y_pio_ptr) = float2fix(y_val);
          *(reset_pio_ptr) = 0;
          usleep( 1 );
        	*(reset_pio_ptr) = 1;
         
          print_data(x_val, y_val, x_incr, y_incr, zoom_x, *(iter_pio_ptr)); // Print new info
          
          // Reset accum
          x_accum = 0;
          y_accum = 0;
        }    
      } // if bytes > 0
      
    } // while sram ptr = 0

		gettimeofday(&t1, NULL); // Start timing
	
		// wait for FPGA to zero the "data_ready" flag
		while (*(sram_ptr)==1) ; // FPGA is done drawing
    
		// === time the fpga =======================
		gettimeofday(&t2, NULL);
		elapsedTime = (t2.tv_sec - t1.tv_sec) * 1000000.0;      // sec to us
		elapsedTime += (t2.tv_usec - t1.tv_usec) ;   // us to 
		//sprintf(num_string, "# = %d     ", total_count);
		sprintf(time_string, "T =%8.0f uSec  ", elapsedTime);
		//VGA_text (10, 3, num_string);
		//VGA_text (10, 4, time_string);
    
    print_data(x_val, y_val, x_incr, y_incr, zoom_x, *(iter_pio_ptr)); // Print new info

	} // end while(1)
} // end main

/****************************************************************************************
 * Subroutine to read a pixel from the VGA monitor 
****************************************************************************************/
int  VGA_read_pixel(int x, int y){
	char  *pixel_ptr ;
	pixel_ptr = (char *)vga_pixel_ptr + ((y)*640) + (x) ;
	return *pixel_ptr ;
}

/****************************************************************************************
 * Subroutine to send a string of text to the VGA monitor 
****************************************************************************************/
void VGA_text(int x, int y, char * text_ptr)
{
  	volatile char * character_buffer = (char *) vga_char_ptr ;	// VGA character buffer
	int offset;
	/* assume that the text string fits on one line */
	offset = (y << 7) + x;
	while ( *(text_ptr) )
	{
		// write to the character buffer
		*(character_buffer + offset) = *(text_ptr);	
		++text_ptr;
		++offset;
	}
}

/****************************************************************************************
 * Subroutine to clear text to the VGA monitor 
****************************************************************************************/
void VGA_text_clear()
{
  	volatile char * character_buffer = (char *) vga_char_ptr ;	// VGA character buffer
	int offset, x, y;
	for (x=0; x<79; x++){
		for (y=0; y<59; y++){
	/* assume that the text string fits on one line */
			offset = (y << 7) + x;
			// write to the character buffer
			*(character_buffer + offset) = ' ';		
		}
	}
}

/****************************************************************************************
 * Draw a filled rectangle on the VGA monitor 
****************************************************************************************/
#define SWAP(X,Y) do{int temp=X; X=Y; Y=temp;}while(0) 

void VGA_box(int x1, int y1, int x2, int y2, short pixel_color)
{
	char  *pixel_ptr ; 
	int row, col;

	/* check and fix box coordinates to be valid */
	if (x1>639) x1 = 639;
	if (y1>479) y1 = 479;
	if (x2>639) x2 = 639;
	if (y2>479) y2 = 479;
	if (x1<0) x1 = 0;
	if (y1<0) y1 = 0;
	if (x2<0) x2 = 0;
	if (y2<0) y2 = 0;
	if (x1>x2) SWAP(x1,x2);
	if (y1>y2) SWAP(y1,y2);
	for (row = y1; row <= y2; row++)
		for (col = x1; col <= x2; ++col)
		{
			//640x480
			VGA_PIXEL(col, row, pixel_color);
			//pixel_ptr = (char *)vga_pixel_ptr + (row<<10)    + col ;
			// set pixel color
			//*(char *)pixel_ptr = pixel_color;		
		}
}

/****************************************************************************************
 * Draw a filled circle on the VGA monitor 
****************************************************************************************/

void VGA_disc(int x, int y, int r, short pixel_color)
{
	char  *pixel_ptr ; 
	int row, col, rsqr, xc, yc;
	
	rsqr = r*r;
	
	for (yc = -r; yc <= r; yc++)
		for (xc = -r; xc <= r; xc++)
		{
			col = xc;
			row = yc;
			// add the r to make the edge smoother
			if(col*col+row*row <= rsqr+r){
				col += x; // add the center point
				row += y; // add the center point
				//check for valid 640x480
				if (col>639) col = 639;
				if (row>479) row = 479;
				if (col<0) col = 0;
				if (row<0) row = 0;
				VGA_PIXEL(col, row, pixel_color);
				//pixel_ptr = (char *)vga_pixel_ptr + (row<<10) + col ;
				// set pixel color
				//nanosleep(&delay_time, NULL);
				//draw_delay();
				//*(char *)pixel_ptr = pixel_color;
			}
					
		}
}

// =============================================
// === Draw a line
// =============================================
//plot a line 
//at x1,y1 to x2,y2 with color 
//Code is from David Rodgers,
//"Procedural Elements of Computer Graphics",1985
void VGA_line(int x1, int y1, int x2, int y2, short c) {
	int e;
	signed int dx,dy,j, temp;
	signed int s1,s2, xchange;
     signed int x,y;
	char *pixel_ptr ;
	
	/* check and fix line coordinates to be valid */
	if (x1>639) x1 = 639;
	if (y1>479) y1 = 479;
	if (x2>639) x2 = 639;
	if (y2>479) y2 = 479;
	if (x1<0) x1 = 0;
	if (y1<0) y1 = 0;
	if (x2<0) x2 = 0;
	if (y2<0) y2 = 0;
        
	x = x1;
	y = y1;
	
	//take absolute value
	if (x2 < x1) {
		dx = x1 - x2;
		s1 = -1;
	}

	else if (x2 == x1) {
		dx = 0;
		s1 = 0;
	}

	else {
		dx = x2 - x1;
		s1 = 1;
	}

	if (y2 < y1) {
		dy = y1 - y2;
		s2 = -1;
	}

	else if (y2 == y1) {
		dy = 0;
		s2 = 0;
	}

	else {
		dy = y2 - y1;
		s2 = 1;
	}

	xchange = 0;   

	if (dy>dx) {
		temp = dx;
		dx = dy;
		dy = temp;
		xchange = 1;
	} 

	e = ((int)dy<<1) - dx;  
	 
	for (j=0; j<=dx; j++) {
		//video_pt(x,y,c); //640x480
		VGA_PIXEL(x, y, c);
		//pixel_ptr = (char *)vga_pixel_ptr + (y<<10)+ x; 
		// set pixel color
		//*(char *)pixel_ptr = c;	
		 
		if (e>=0) {
			if (xchange==1) x = x + s1;
			else y = y + s2;
			e = e - ((int)dx<<1);
		}

		if (xchange==1) y = y + s2;
		else x = x + s1;

		e = e + ((int)dy<<1);
	}
}

/////////////////////////////////////////////

#define NOP10() asm("nop;nop;nop;nop;nop;nop;nop;nop;nop;nop")

void draw_delay(void){
	NOP10(); NOP10(); NOP10(); NOP10();
	NOP10(); NOP10(); NOP10(); NOP10();
	NOP10(); NOP10(); NOP10(); NOP10();
	NOP10(); NOP10(); NOP10(); NOP10();
	NOP10(); NOP10(); NOP10(); NOP10();
	NOP10(); NOP10(); NOP10(); NOP10();
	NOP10(); NOP10(); NOP10(); NOP10();
	NOP10(); NOP10(); NOP10(); NOP10();
	NOP10(); NOP10(); NOP10(); NOP10();
	NOP10(); NOP10(); NOP10(); NOP10();
	NOP10(); NOP10(); NOP10(); NOP10();
	NOP10(); NOP10(); NOP10(); NOP10();
	NOP10(); NOP10(); NOP10(); NOP10();
	NOP10(); NOP10(); NOP10(); NOP10();
	NOP10(); NOP10(); NOP10(); NOP10();
	NOP10(); NOP10(); NOP10(); NOP10(); //16
	NOP10(); NOP10(); NOP10(); NOP10();
	NOP10(); NOP10(); NOP10(); NOP10();
	NOP10(); NOP10(); NOP10(); NOP10();
	NOP10(); NOP10(); NOP10(); NOP10();
	NOP10(); NOP10(); NOP10(); NOP10();
	NOP10(); NOP10(); NOP10(); NOP10();
	NOP10(); NOP10(); NOP10(); NOP10();
	NOP10(); NOP10(); NOP10(); NOP10();
	NOP10(); NOP10(); NOP10(); NOP10();
	NOP10(); NOP10(); NOP10(); NOP10();
	NOP10(); NOP10(); NOP10(); NOP10();
	NOP10(); NOP10(); NOP10(); NOP10();
	NOP10(); NOP10(); NOP10(); NOP10();
	NOP10(); NOP10(); NOP10(); NOP10();
	NOP10(); NOP10(); NOP10(); NOP10();
	NOP10(); NOP10(); NOP10(); NOP10(); //32
	NOP10(); NOP10(); NOP10(); NOP10();
	NOP10(); NOP10(); NOP10(); NOP10();
	NOP10(); NOP10(); NOP10(); NOP10();
	NOP10(); NOP10(); NOP10(); NOP10();
	NOP10(); NOP10(); NOP10(); NOP10();
	NOP10(); NOP10(); NOP10(); NOP10();
	NOP10(); NOP10(); NOP10(); NOP10();
	NOP10(); NOP10(); NOP10(); NOP10();
	NOP10(); NOP10(); NOP10(); NOP10();
	NOP10(); NOP10(); NOP10(); NOP10();
	NOP10(); NOP10(); NOP10(); NOP10();
	NOP10(); NOP10(); NOP10(); NOP10();
	NOP10(); NOP10(); NOP10(); NOP10();
	NOP10(); NOP10(); NOP10(); NOP10();
	NOP10(); NOP10(); NOP10(); NOP10();
	NOP10(); NOP10(); NOP10(); NOP10(); //48
	NOP10(); NOP10(); NOP10(); NOP10();
	NOP10(); NOP10(); NOP10(); NOP10();
	NOP10(); NOP10(); NOP10(); NOP10();
	NOP10(); NOP10(); NOP10(); NOP10();
	NOP10(); NOP10(); NOP10(); NOP10();
	NOP10(); NOP10(); NOP10(); NOP10();
	NOP10(); NOP10(); NOP10(); NOP10();
	NOP10(); NOP10(); NOP10(); NOP10();
	NOP10(); NOP10(); NOP10(); NOP10();
	NOP10(); NOP10(); NOP10(); NOP10();
	NOP10(); NOP10(); NOP10(); NOP10();
	NOP10(); NOP10(); NOP10(); NOP10();
	NOP10(); NOP10(); NOP10(); NOP10();
	NOP10(); NOP10(); NOP10(); NOP10();
	NOP10(); NOP10(); NOP10(); NOP10();
	NOP10(); NOP10(); NOP10(); NOP10(); //64
	NOP10(); NOP10(); NOP10(); NOP10();
	NOP10(); NOP10(); NOP10(); NOP10();
	NOP10(); NOP10(); NOP10(); NOP10();
	NOP10(); NOP10(); NOP10(); NOP10(); //68
	// NOP10(); NOP10(); NOP10(); NOP10();
	// NOP10(); NOP10(); NOP10(); NOP10();
	// NOP10(); NOP10(); NOP10(); NOP10();
	// NOP10(); NOP10(); NOP10(); NOP10();
	// NOP10(); NOP10(); NOP10(); NOP10();
	// NOP10(); NOP10(); NOP10(); NOP10();
	// NOP10(); NOP10(); NOP10(); NOP10();
	// NOP10(); NOP10(); NOP10(); NOP10();
	// NOP10(); NOP10(); NOP10(); NOP10();
	// NOP10(); NOP10(); NOP10(); NOP10();
	// NOP10(); NOP10(); NOP10(); NOP10();
	// NOP10(); NOP10(); NOP10(); NOP10(); //80
	// NOP10(); NOP10(); NOP10(); NOP10();
	// NOP10(); NOP10(); NOP10(); NOP10();
	// NOP10(); NOP10(); NOP10(); NOP10();
	// NOP10(); NOP10(); NOP10(); NOP10();
	// NOP10(); NOP10(); NOP10(); NOP10();
	// NOP10(); NOP10(); NOP10(); NOP10();
	// NOP10(); NOP10(); NOP10(); NOP10();
	// NOP10(); NOP10(); NOP10(); NOP10();
	// NOP10(); NOP10(); NOP10(); NOP10();
	// NOP10(); NOP10(); NOP10(); NOP10();
	// NOP10(); NOP10(); NOP10(); NOP10();
	// NOP10(); NOP10(); NOP10(); NOP10();
	// NOP10(); NOP10(); NOP10(); NOP10();
	// NOP10(); NOP10(); NOP10(); NOP10();
	// NOP10(); NOP10(); NOP10(); NOP10();
	// NOP10(); NOP10(); NOP10(); NOP10(); //96
}

/// /// ///////////////////////////////////// 
/// end /////////////////////////////////////
