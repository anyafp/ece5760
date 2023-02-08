///////////////////////////////////////
/// 640x480 version! 16-bit color
/// This code will segfault the original
/// DE1 computer
/// compile with
/// gcc graphics_video_16bit.c -o gr -O2 -lm
///
///////////////////////////////////////
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/ipc.h> 
#include <sys/shm.h> 
#include <sys/mman.h>
#include <sys/time.h> 
#include <math.h>
#include <pthread.h>
//#include "address_map_arm_brl4.h"

#define TRUE 1
#define FALSE 0

// lock for scanf
pthread_mutex_t scan_lock = PTHREAD_MUTEX_INITIALIZER;

// characters
#define FPGA_CHAR_BASE        0xC9000000 
#define FPGA_CHAR_END         0xC9001FFF
#define FPGA_CHAR_SPAN        0x00002000

// AXI -- VIDEO DISPLAY
#define FPGA_AXI_BASE         0xC0000000
#define FPGA_AXI_SPAN		  0x04000000

// AXI LW -- Cyclone V FPGA devices
#define FPGA_LW_BASE		  0xff200000
#define FPGA_LW_SPAN 		  0x00003000

// the light weight buss base
void *h2p_lw_virtual_base;

// pixel buffer
volatile unsigned int * vga_pixel_ptr = NULL ;
void *vga_pixel_virtual_base;

// character buffer
volatile unsigned int * vga_char_ptr = NULL ;
void *vga_char_virtual_base;

// /dev/mem file id
int fd;

// measure time
struct timeval t1, t2;
double elapsedTime;
char num_string[20], time_string[20];
char init_x_string[20], init_y_string[20], init_z_string[20];
char sig_string[20], beta_string[20], rho_string[20], status_string[20];

// X, Y, Z pointers
volatile signed int* x_pio_ptr = NULL;
volatile signed int* y_pio_ptr = NULL;
volatile signed int* z_pio_ptr = NULL; 
volatile signed int* x_init_pio_ptr = NULL;
volatile signed int* y_init_pio_ptr = NULL;
volatile signed int* z_init_pio_ptr = NULL; 
volatile signed int* sigma_pio_ptr = NULL;
volatile signed int* beta_pio_ptr = NULL;
volatile signed int* rho_pio_ptr = NULL; 

volatile unsigned char* clock_ptr = NULL; 
volatile unsigned char* rst_ptr   = NULL; 
volatile unsigned char* start_stop_ptr = NULL; 

#define X_PIO                 0x00
#define Y_PIO                 0x10
#define Z_PIO                 0x20
#define CLK_PIO				  0x30
#define RST_PIO				  0x40
#define X_INIT_PIO			  0x50
#define Y_INIT_PIO			  0x60
#define Z_INIT_PIO			  0x70
#define SIGMA_PIO			  0x80
#define BETA_PIO			  0x90
#define RHO_PIO 			  0xA0
#define START_STOP_PIO		  0xB0

// graphics primitives
void VGA_text (int, int, char *);
void VGA_text_clear();
void VGA_box (int, int, int, int, short);
void VGA_rect (int, int, int, int, short);
void VGA_line(int, int, int, int, short) ;
void VGA_Vline(int, int, int, short) ;
void VGA_Hline(int, int, int, short) ;
void VGA_disc (int, int, int, short);
void VGA_circle (int, int, int, int);
void VGA_sin (int, short);
void VGA_xy( float, float );
void VGA_xz( float, float );
void VGA_yz( float, float );

// cast int
int   fix2int(int);
float fix2float(int);
int float2fix(float);

int fix2int(int a) { return a >> 20; }

float fix2float(int a) { return ((float)a) / 1048576; }

int float2fix(float a) { return (int)(a*1048576); }

// 16-bit primary colors
#define red  (0+(0<<5)+(31<<11))
#define dark_red (0+(0<<5)+(15<<11))
#define green (0+(63<<5)+(0<<11))
#define dark_green (0+(31<<5)+(0<<11))
#define blue (31+(0<<5)+(0<<11))
#define dark_blue (15+(0<<5)+(0<<11))
#define yellow (0+(63<<5)+(31<<11))
#define cyan (31+(63<<5)+(0<<11))
#define magenta (31+(0<<5)+(31<<11))
#define black (0x0000)
#define gray (15+(31<<5)+(51<<11))
#define white (0xffff)
int colors[] = {red, dark_red, green, dark_green, blue, dark_blue, 
		yellow, cyan, magenta, gray, black, white};

// pixel macro
#define VGA_PIXEL(x,y,color) do{\
	int  *pixel_ptr ;\
	pixel_ptr = (int*)((char *)vga_pixel_ptr + (((y)*640+(x))<<1)) ; \
	*(short *)pixel_ptr = (color);\
} while(0)

///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////
// THREADS ////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////

// global variables for threads
int choose_int = 0;   // which setting to change
int change_init = 0;  // triggers change initial values
int temp_start_stop = 0;  // 0: playing,  1: paused
int speed_var = 5000; // variable for speed
int temp_speed;       // variable to indicate speed up or slow down
float temp_x = -1;
float temp_y = 0.1;
float temp_z = 25;
float temp_sig = 10;
float temp_beta = 2.6667;
float temp_rho = 28;

///////////////////////////////////////////////////////////////
// reset thread
///////////////////////////////////////////////////////////////

void * reset_thread() {

  while (1) {
  
    if (change_init) {
    
      // update pio pointers
      *(x_init_pio_ptr) = float2fix(temp_x);
      *(y_init_pio_ptr) = float2fix(temp_y);
      *(z_init_pio_ptr) = float2fix(temp_z);
      
      // reset
      *(clock_ptr) = 0;
    	*(rst_ptr) = 0;
    	*(clock_ptr) = 1;
    	*(clock_ptr) = 0;
    	*(rst_ptr) = 1;
     
      // clear VGA
      VGA_box (0, 0, 639, 479, 0x0000);
      
      // done initializing
      change_init = 0;
    }
  }
}

///////////////////////////////////////////////////////////////
// draw thread
///////////////////////////////////////////////////////////////

void * draw_thread() {
		
    while (1) {
    
      // start timer
      gettimeofday( &t1, NULL );
      
      if ( !change_init ) {
      
        // send posedge
    		*(clock_ptr) = 1;
    		*(clock_ptr) = 0;
         
        // if not paused
        if (!temp_start_stop ) {
        
  //        // start timer
  // 		    gettimeofday( &t1, NULL );
           
          // draw 3 graphs
          VGA_xy( fix2float(*(x_pio_ptr)), fix2float(*(y_pio_ptr)) );
     		  VGA_xz( fix2float(*(x_pio_ptr)), fix2float(*(z_pio_ptr)) );
     		  VGA_yz( fix2float(*(y_pio_ptr)), fix2float(*(z_pio_ptr)) );
            
  //        // stop timer
  //   		  gettimeofday( &t2, NULL );
  //          
  //        // draw time
  //   		  elapsedTime = ( t2.tv_sec - t1.tv_sec ) * 1000000.0; // sec to us
  //   		  elapsedTime += (t2.tv_usec - t1.tv_usec); // us 
  //   		  sprintf( time_string, "T = %6.0f uSec  ", elapsedTime );
  // 		    VGA_text( 30, 4, time_string );
          
          // print data
            
        }
        
  //      // stop timer
  // 		  gettimeofday( &t2, NULL );
  //        
  //      // draw time
  // 		  elapsedTime = ( t2.tv_sec - t1.tv_sec ) * 1000000.0; // sec to us
  // 		  elapsedTime += (t2.tv_usec - t1.tv_usec); // us 
  // 		  sprintf( time_string, "T = %6.0f uSec  ", elapsedTime );
  //	    VGA_text( 30, 4, time_string );
  
        // print data
        sprintf( time_string, "%i us", speed_var );
        sprintf( init_x_string, "%f", temp_x );
        sprintf( init_y_string, "%f", temp_y );
        sprintf( init_z_string, "%f", temp_z );
        sprintf( sig_string, "%f", temp_sig );
        sprintf( beta_string, "%f", temp_beta );
        sprintf( rho_string, "%f", temp_rho );
        if ( temp_start_stop )
          sprintf( status_string, "paused" );
        else
          sprintf( status_string, "played" );
        
        VGA_text( 13, 35, init_x_string );
        VGA_text( 13, 36, init_y_string );
        VGA_text( 13, 37, init_z_string );
        VGA_text( 13, 38, sig_string );
        VGA_text( 13, 39, beta_string );
        VGA_text( 13, 40, rho_string );
        VGA_text( 13, 41, time_string );
        VGA_text( 13, 42, status_string );
  
        usleep( speed_var );
        
      }
   }
}

///////////////////////////////////////////////////////////////
// scan thread
///////////////////////////////////////////////////////////////

void * scan_thread() {
  
  while (1) {
  
    // Which category to change?
    printf("0: init vals, 1: params, 2: speed, 3: pause/resume, 4: clear -- ");
    scanf("%i", &choose_int);
    
    switch ( choose_int ) {
    
      case 0: // x, y, z, init values
        printf("Enter x: ");
        scanf("%f", &temp_x);
        printf("Enter y: ");
        scanf("%f", &temp_y);
        printf("Enter z: ");
        scanf("%f", &temp_z);
        change_init = 1; // reset
        
        break;
        
      case 1: // sigma, beta, rho parameters
        printf("Enter sigma: ");
        scanf("%f", &temp_sig);
        printf("Enter beta: ");
        scanf("%f", &temp_beta);
        printf("Enter rho: ");
        scanf("%f", &temp_rho);
        *(sigma_pio_ptr) = float2fix(temp_sig);
        *(beta_pio_ptr) = float2fix(temp_beta);
        *(rho_pio_ptr) = float2fix(temp_rho);
        
        break;
        
      case 2: // drawing speed
        printf("Decrease (0) or Increase (1) speed? ");
        scanf("%i", &temp_speed);
        
        // increase speed
        if (temp_speed) {
          // lower bound
          if (speed_var > 500)
            speed_var = speed_var - 500; // decrease sleep time
        
        // decrease speed    
        } else {
          // upper bound
          if (speed_var < 30000)
            speed_var = speed_var + 500; // increase sleep time
        }
        
        break;
        
      case 3: // pause/resume
        // if paused
        if (temp_start_stop) {
          temp_start_stop = 0; // play
          *(start_stop_ptr) = temp_start_stop;
        } else {
          temp_start_stop = 1; // pause
          *(start_stop_ptr) = temp_start_stop;
        }
        
        break;
        
      case 4: // clear page
        VGA_box (0, 0, 639, 479, 0x0000);
        
        break;
    }
  }
}

	
int main(void)
{
  	
	// === need to mmap: =======================
	// FPGA_CHAR_BASE
	// FPGA_ONCHIP_BASE      
	// FPGA_LW_BASE        
  
	// === get FPGA addresses ==================
    // Open /dev/mem
	if( ( fd = open( "/dev/mem", ( O_RDWR | O_SYNC ) ) ) == -1 ) 	{
		printf( "ERROR: could not open \"/dev/mem\"...\n" );
		return( 1 );
	}
    
    // get virtual addr that maps to physical
	h2p_lw_virtual_base = mmap( NULL, FPGA_LW_SPAN, ( PROT_READ | PROT_WRITE ), MAP_SHARED, fd, FPGA_LW_BASE );	
	if( h2p_lw_virtual_base == MAP_FAILED ) {
		printf( "ERROR: mmap1() failed...\n" );
		close( fd );
		return(1);
	}

	x_pio_ptr = (signed int *)(h2p_lw_virtual_base + X_PIO);
	y_pio_ptr = (signed int *)(h2p_lw_virtual_base + Y_PIO);
    z_pio_ptr = (signed int *)(h2p_lw_virtual_base + Z_PIO);
	x_init_pio_ptr = (signed int *)(h2p_lw_virtual_base + X_INIT_PIO);
	y_init_pio_ptr = (signed int *)(h2p_lw_virtual_base + Y_INIT_PIO);
	z_init_pio_ptr = (signed int *)(h2p_lw_virtual_base + Z_INIT_PIO);
  sigma_pio_ptr = (signed int *)(h2p_lw_virtual_base + SIGMA_PIO);
	beta_pio_ptr = (signed int *)(h2p_lw_virtual_base + BETA_PIO);
	rho_pio_ptr = (signed int *)(h2p_lw_virtual_base + RHO_PIO);

	clock_ptr = (unsigned char *)(h2p_lw_virtual_base + CLK_PIO);
	rst_ptr = (unsigned char *)(h2p_lw_virtual_base + RST_PIO);
	start_stop_ptr = (unsigned char *)(h2p_lw_virtual_base + START_STOP_PIO);

	// === get VGA char addr =====================
	// get virtual addr that maps to physical
	vga_char_virtual_base = mmap( NULL, FPGA_CHAR_SPAN, ( 	PROT_READ | PROT_WRITE ), MAP_SHARED, fd, FPGA_CHAR_BASE );	
	if( vga_char_virtual_base == MAP_FAILED ) {
		printf( "ERROR: mmap2() failed...\n" );
		close( fd );
		return(1);
	}
    
    // Get the address that maps to the FPGA LED control 
	vga_char_ptr =(unsigned int *)(vga_char_virtual_base);

	// === get VGA pixel addr ====================
	// get virtual addr that maps to physical
	vga_pixel_virtual_base = mmap( NULL, FPGA_AXI_SPAN, ( PROT_READ | PROT_WRITE ), MAP_SHARED, fd, FPGA_AXI_BASE);	
	if( vga_pixel_virtual_base == MAP_FAILED ) {
		printf( "ERROR: mmap3() failed...\n" );
		close( fd );
		return(1);
	}
    
    // Get the address that maps to the FPGA pixel buffer
	vga_pixel_ptr =(unsigned int *)(vga_pixel_virtual_base);

	// ===========================================

	/* create a message to be displayed on the VGA 
          and LCD displays */
	char text_x[40] = "init x = ";
  char text_y[40] = "init y = ";
  char text_z[40] = "init z = ";
	char text_sig[40] = "sig = ";
  char text_beta[40] = "beta = ";
  char text_rho[40] = "rho = ";
	char text_speed[40] = "usleep = ";
  char text_status[40] = "status = ";
	char color_index = 0 ;
	int color_counter = 0 ;

	// clear the screen
	VGA_box (0, 0, 639, 479, 0x0000);
	// clear the text
	VGA_text_clear();
	// write text
	VGA_text (3, 35, text_x);
  VGA_text (3, 36, text_y);
  VGA_text (3, 37, text_z);
  VGA_text (3, 38, text_sig);
  VGA_text (3, 39, text_beta);
  VGA_text (3, 40, text_rho);
	VGA_text (3, 41, text_speed);
  VGA_text (3, 42, text_status);
	
	// R bits 11-15 mask 0xf800
	// G bits 5-10  mask 0x07e0
	// B bits 0-4   mask 0x001f
	// so color = B+(G<<5)+(R<<11);

	// initialize
	*(x_init_pio_ptr) = float2fix(-1);
	*(y_init_pio_ptr) = float2fix(0.1);
	*(z_init_pio_ptr) = float2fix(25);
	*(sigma_pio_ptr) = float2fix(10);
	*(beta_pio_ptr) = float2fix(8/3);
	*(rho_pio_ptr) = float2fix(28);
	*(start_stop_ptr) = 0;

	// reset to init values
	*(clock_ptr) = 0;
	*(rst_ptr) = 0;
	*(clock_ptr) = 1;
	*(clock_ptr) = 0;
	*(rst_ptr) = 1;
 
   // thread identifiers
   pthread_t thread_scan, thread_draw, thread_reset;
   
   // For portability, explicitly create threads in a joinable state 
	 // thread attribute used here to allow JOIN
	 pthread_attr_t attr;
	 pthread_attr_init( &attr );
	 pthread_attr_setdetachstate( &attr, PTHREAD_CREATE_JOINABLE );
	
	 // now the threads
   pthread_create( &thread_reset, NULL, reset_thread, NULL );
   pthread_create( &thread_draw, NULL, draw_thread, NULL );
   pthread_create( &thread_scan, NULL, scan_thread, NULL );

   pthread_join( thread_reset, NULL );
   pthread_join( thread_draw, NULL );
   pthread_join( thread_scan, NULL );
   return 0;

} // end main

/****************************************************************************************
 * Draw x, y, z output
****************************************************************************************/

void VGA_xy(float x, float y) {
	VGA_PIXEL( 160 - (int)(x*4), 120 - (int)(y*4), white);
}

void VGA_xz(float x, float z) {
	VGA_PIXEL( 480 - (int)(x*4), 240 - (int)(z*4), white);
}

void VGA_yz(float y, float z) {
	VGA_PIXEL( 320 - (int)(y*4), 450 - (int)(z*4), white);
}

/****************************************************************************************
 * Draw sine wave
****************************************************************************************/
// #define SWAP(X,Y) do{int temp=X; X=Y; Y=temp;}while(0) 

void VGA_sin(int ampl, short pixel_color)
{ 
    int col;

	for ( col = 50; col <= 600; col++ ) {
		
        int y_val = ampl * sin( col / ( 2*M_PI ) );
		VGA_PIXEL(col, y_val + 150, pixel_color);	

	}

    VGA_Hline( 50, 150, 600, white );
    VGA_Vline( 50, 100, 300, white );
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
			//pixel_ptr = (char *)vga_pixel_ptr + (row<<10)    + col ;
			// set pixel color
			//*(char *)pixel_ptr = pixel_color;	
			VGA_PIXEL(col,row,pixel_color);	
		}
}

/****************************************************************************************
 * Draw a outline rectangle on the VGA monitor 
****************************************************************************************/
#define SWAP(X,Y) do{int temp=X; X=Y; Y=temp;}while(0) 

void VGA_rect(int x1, int y1, int x2, int y2, short pixel_color)
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
	// left edge
	col = x1;
	for (row = y1; row <= y2; row++){
		//640x480
		//pixel_ptr = (char *)vga_pixel_ptr + (row<<10)    + col ;
		// set pixel color
		//*(char *)pixel_ptr = pixel_color;	
		VGA_PIXEL(col,row,pixel_color);		
	}
		
	// right edge
	col = x2;
	for (row = y1; row <= y2; row++){
		//640x480
		//pixel_ptr = (char *)vga_pixel_ptr + (row<<10)    + col ;
		// set pixel color
		//*(char *)pixel_ptr = pixel_color;	
		VGA_PIXEL(col,row,pixel_color);		
	}
	
	// top edge
	row = y1;
	for (col = x1; col <= x2; ++col){
		//640x480
		//pixel_ptr = (char *)vga_pixel_ptr + (row<<10)    + col ;
		// set pixel color
		//*(char *)pixel_ptr = pixel_color;	
		VGA_PIXEL(col,row,pixel_color);
	}
	
	// bottom edge
	row = y2;
	for (col = x1; col <= x2; ++col){
		//640x480
		//pixel_ptr = (char *)vga_pixel_ptr + (row<<10)    + col ;
		// set pixel color
		//*(char *)pixel_ptr = pixel_color;
		VGA_PIXEL(col,row,pixel_color);
	}
}

/****************************************************************************************
 * Draw a horixontal line on the VGA monitor 
****************************************************************************************/
#define SWAP(X,Y) do{int temp=X; X=Y; Y=temp;}while(0) 

void VGA_Hline(int x1, int y1, int x2, short pixel_color)
{
	char  *pixel_ptr ; 
	int row, col;

	/* check and fix box coordinates to be valid */
	if (x1>639) x1 = 639;
	if (y1>479) y1 = 479;
	if (x2>639) x2 = 639;
	if (x1<0) x1 = 0;
	if (y1<0) y1 = 0;
	if (x2<0) x2 = 0;
	if (x1>x2) SWAP(x1,x2);
	// line
	row = y1;
	for (col = x1; col <= x2; ++col){
		//640x480
		//pixel_ptr = (char *)vga_pixel_ptr + (row<<10)    + col ;
		// set pixel color
		//*(char *)pixel_ptr = pixel_color;	
		VGA_PIXEL(col,row,pixel_color);		
	}
}

/****************************************************************************************
 * Draw a vertical line on the VGA monitor 
****************************************************************************************/
#define SWAP(X,Y) do{int temp=X; X=Y; Y=temp;}while(0) 

void VGA_Vline(int x1, int y1, int y2, short pixel_color)
{
	char  *pixel_ptr ; 
	int row, col;

	/* check and fix box coordinates to be valid */
	if (x1>639) x1 = 639;
	if (y1>479) y1 = 479;
	if (y2>479) y2 = 479;
	if (x1<0) x1 = 0;
	if (y1<0) y1 = 0;
	if (y2<0) y2 = 0;
	if (y1>y2) SWAP(y1,y2);
	// line
	col = x1;
	for (row = y1; row <= y2; row++){
		//640x480
		//pixel_ptr = (char *)vga_pixel_ptr + (row<<10)    + col ;
		// set pixel color
		//*(char *)pixel_ptr = pixel_color;	
		VGA_PIXEL(col,row,pixel_color);			
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
				//pixel_ptr = (char *)vga_pixel_ptr + (row<<10) + col ;
				// set pixel color
				//*(char *)pixel_ptr = pixel_color;
				VGA_PIXEL(col,row,pixel_color);	
			}
					
		}
}

/****************************************************************************************
 * Draw a  circle on the VGA monitor 
****************************************************************************************/

void VGA_circle(int x, int y, int r, int pixel_color)
{
	char  *pixel_ptr ; 
	int row, col, rsqr, xc, yc;
	int col1, row1;
	rsqr = r*r;
	
	for (yc = -r; yc <= r; yc++){
		//row = yc;
		col1 = (int)sqrt((float)(rsqr + r - yc*yc));
		// right edge
		col = col1 + x; // add the center point
		row = yc + y; // add the center point
		//check for valid 640x480
		if (col>639) col = 639;
		if (row>479) row = 479;
		if (col<0) col = 0;
		if (row<0) row = 0;
		//pixel_ptr = (char *)vga_pixel_ptr + (row<<10) + col ;
		// set pixel color
		//*(char *)pixel_ptr = pixel_color;
		VGA_PIXEL(col,row,pixel_color);	
		// left edge
		col = -col1 + x; // add the center point
		//check for valid 640x480
		if (col>639) col = 639;
		if (row>479) row = 479;
		if (col<0) col = 0;
		if (row<0) row = 0;
		//pixel_ptr = (char *)vga_pixel_ptr + (row<<10) + col ;
		// set pixel color
		//*(char *)pixel_ptr = pixel_color;
		VGA_PIXEL(col,row,pixel_color);	
	}
	for (xc = -r; xc <= r; xc++){
		//row = yc;
		row1 = (int)sqrt((float)(rsqr + r - xc*xc));
		// right edge
		col = xc + x; // add the center point
		row = row1 + y; // add the center point
		//check for valid 640x480
		if (col>639) col = 639;
		if (row>479) row = 479;
		if (col<0) col = 0;
		if (row<0) row = 0;
		//pixel_ptr = (char *)vga_pixel_ptr + (row<<10) + col ;
		// set pixel color
		//*(char *)pixel_ptr = pixel_color;
		VGA_PIXEL(col,row,pixel_color);	
		// left edge
		row = -row1 + y; // add the center point
		//check for valid 640x480
		if (col>639) col = 639;
		if (row>479) row = 479;
		if (col<0) col = 0;
		if (row<0) row = 0;
		//pixel_ptr = (char *)vga_pixel_ptr + (row<<10) + col ;
		// set pixel color
		//*(char *)pixel_ptr = pixel_color;
		VGA_PIXEL(col,row,pixel_color);	
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
		//pixel_ptr = (char *)vga_pixel_ptr + (y<<10)+ x; 
		// set pixel color
		//*(char *)pixel_ptr = c;
		VGA_PIXEL(x,y,c);			
		 
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
