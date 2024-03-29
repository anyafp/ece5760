///////////////////////////////////////
/// 640x480 version!
/// This code will segfault the original
/// DE1 computer
/// compile with
/// gcc mandelbrot_video_2.c -o mandel -mfpu=neon -ftree-vectorize -O2
/// -- no optimization yields 9100 mS execution time
/// -- opt -O1 yields 4800 mS execution time
/// -- opt -O2 yields 3500 mS execution time
/// -- opt -O3 yields 3400 mS execution time
/// -- adding 'f' to all floating literals (e.g. 1.3f) and opt -O2 yields 2640 mS execution time
///gcc mandelbrot_video_vector.c -o mandel -mfpu=neon -ftree-vectorize 
///               -O3 -mfloat-abi=hard -ffast-math 
/// -- yields 2544 mS execution time
/// change to fixed point 
/// gcc mandelbrot_video_fix.c -o mandel -Os
/// -- yields 1615 mS execution time
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

/* Cyclone V FPGA devices */
#define HW_REGS_BASE          0xff200000
//#define HW_REGS_SPAN        0x00200000 
#define HW_REGS_SPAN          0x00005000 

#define FPGA_ONCHIP_BASE      0xC8000000
//#define FPGA_ONCHIP_END       0xC803FFFF
// modified for 640x480
// #define FPGA_ONCHIP_SPAN      0x00040000
#define FPGA_ONCHIP_SPAN      0x00080000

#define FPGA_CHAR_BASE        0xC9000000 
#define FPGA_CHAR_END         0xC9001FFF
#define FPGA_CHAR_SPAN        0x00002000

/* function prototypes */
void VGA_text (int, int, char *);
void VGA_text_clear();
void VGA_box (int, int, int, int, short);
void VGA_line(int, int, int, int, short) ;
void VGA_disc (int, int, int, short);

// fixed pt
typedef signed int fix28 ;
//multiply two fixed 4:28
#define multfix28(a,b) ((fix28)(((( signed long long)(a))*(( signed long long)(b)))>>28)) 
//#define multfix28(a,b) ((fix28)((( ((short)((a)>>17)) * ((short)((b)>>17)) )))) 
#define float2fix28(a) ((fix28)((a)*268435456.0f)) // 2^28
#define fix2float28(a) ((float)(a)/268435456.0f) 
#define int2fix28(a) ((a)<<28);
// the fixed point value 4
#define FOURfix28 0x40000000 
#define SIXTEENTHfix28 0x01000000
#define ONEfix28 0x10000000

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

// shared memory 
key_t mem_key=0xf0;
int shared_mem_id; 
int *shared_ptr;
int shared_time;
int shared_note;
char shared_str[64];

// 8-bit color
#define rgb(r,g,b) ((((r)&7)<<5) | (((g)&7)<<2) | (((b)&3)))

// pixel macro
#define VGA_PIXEL(x,y,color) do{\
	char  *pixel_ptr ;\
	pixel_ptr = (char *)vga_pixel_ptr + ((y)<<10) + (x) ;\
	*(char *)pixel_ptr = (color);\
} while(0)
	
// mandelbrot iteration max
#define max_count 1000

// mandelbrot arrays
fix28 Zre, Zim, Cre, Cim, Zre_temp, Zim_temp;
fix28 Zre_sq, Zim_sq ;
fix28 x[640], y[480];
int i, j, count, total_count;

// measure time
struct timeval t1, t2;
double elapsedTime;
	
int main(void)
{
	//int x1, y1, x2, y2;

	// Declare volatile pointers to I/O registers (volatile 	// means that IO load and store instructions will be used 	// to access these pointer locations, 
	// instead of regular memory loads and stores) 

	// === shared memory =======================
	// with video process
	shared_mem_id = shmget(mem_key, 100, IPC_CREAT | 0666);
 	//shared_mem_id = shmget(mem_key, 100, 0666);
	shared_ptr = shmat(shared_mem_id, NULL, 0);

  	
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
	h2p_lw_virtual_base = mmap( NULL, HW_REGS_SPAN, ( PROT_READ | PROT_WRITE ), MAP_SHARED, fd, HW_REGS_BASE );	
	if( h2p_lw_virtual_base == MAP_FAILED ) {
		printf( "ERROR: mmap1() failed...\n" );
		close( fd );
		return(1);
	}
    

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
	vga_pixel_virtual_base = mmap( NULL, FPGA_ONCHIP_SPAN, ( 	PROT_READ | PROT_WRITE ), MAP_SHARED, fd, 			FPGA_ONCHIP_BASE);	
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
	char text_top_row[40] = "DE1-SoC ARM/FPGA\0";
	char text_bottom_row[40] = "Cornell ece5760\0";
	char num_string[50], time_string[20] ;

	//VGA_text (34, 1, text_top_row);
	//VGA_text (34, 2, text_bottom_row);
	// clear the screen
	VGA_box (0, 0, 639, 479, 0x1c);
	// clear the text

	VGA_text_clear();

	// x increment
	for (i=0; i<640; i++) {
		x[i] = float2fix28(-2.0f + 3.0f * (float)i/640.0f) ;
		//printf("%f\n", x[i]);
	}
	
	// y increment
	for (j=0; j<480; j++) {
		y[j] = float2fix28(-1.0f + 2.0f * (float)j/480.0f) ;
		//printf("%f\n", y[j]);
	}
/*	
	// x increment
	for (i=0; i<640; i++) {
		x[i] = float2fix28(0.2f + 0.3f * (float)i/640.0f) ;
		//printf("%f\n", x[i]);
	}
	
	// y increment
	for (j=0; j<480; j++) {
		y[j] = float2fix28(-0.10f + 0.20f * (float)j/480.0f) ;
		//printf("%f\n", y[j]);
	}
*/	

	
	while(1) 
	{
 
    	// start timer
    gettimeofday(&t1, NULL);
	
  	// zero global counter
  	total_count = 0 ;
  	
  	fix28 center = float2fix28(-0.25f);
  	fix28 radius2 = float2fix28(0.25f);
  	fix28 q;
		
		for (i=0; i<640; i++) {
			for (j=0; j<480; j+=1) {
				Zre = Zre_sq = 0 ;
				Zim = Zim_sq = 0 ;
				Cre = x[i];
				Cim = y[j];
				//count = 0 ;
				// detect secondary bulb
				 if ((multfix28(Cre+ONEfix28,Cre+ONEfix28)+multfix28(Cim,Cim))<SIXTEENTHfix28) {
					 count=max_count;
				 }
				//detect big circle
				 else if ((multfix28(Cre-center,Cre-center)+multfix28(Cim,Cim))<radius2) {
					 count=max_count;
				 }
				 else count = 0;
				
				// iterate to find convergence, or not
				while (count++ < max_count){
					//update the complex iterator
					Zim = (multfix28(Zre,Zim)<<1) + Cim ;
					Zre = Zre_sq - Zim_sq + Cre ;
					Zre_sq = multfix28(Zre, Zre) ;
					Zim_sq = multfix28(Zim, Zim);
					// check non-convergence
					if ((Zre_sq + Zim_sq) >= FOURfix28) break;
				}
				total_count += count ;
				if (count>=max_count) VGA_PIXEL(i,j,rgb(0,0,2));
				else if (count>=(max_count>>1)) VGA_PIXEL(i,j,rgb(7,0,0)); // e0
				else if (count>=(max_count>>2)) VGA_PIXEL(i,j,rgb(7,2,0)); //e0
				else if (count>=(max_count>>3)) VGA_PIXEL(i,j,0xc0); //e0
				else if (count>=(max_count>>4)) VGA_PIXEL(i,j,0xc0); //c0
				else if (count>=(max_count>>5)) VGA_PIXEL(i,j,0xa0); //a0
				else if (count>=(max_count>>6)) VGA_PIXEL(i,j,0x80); //80
				else if (count>=(max_count>>7)) VGA_PIXEL(i,j,0x24); //40
				else VGA_PIXEL(i,j,0x24); // dark gray
			}
		}
		VGA_text (10, 1, text_top_row);
	    VGA_text (10, 2, text_bottom_row);
		
		// stop timer
		gettimeofday(&t2, NULL);
		elapsedTime = (t2.tv_sec - t1.tv_sec) * 1000.0;      // sec to ms
		elapsedTime += (t2.tv_usec - t1.tv_usec) / 1000.0;   // us to ms
		sprintf(num_string, "total interations = %d     ", total_count);
		sprintf(time_string, "T = %6.0f mSec  ", elapsedTime);
		VGA_text (10, 3, num_string);
		VGA_text (10, 4, time_string);
   
   VGA_box (0, 0, 639, 479, 0x1c);
		
	} // end while(1)
} // end main

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
			pixel_ptr = (char *)vga_pixel_ptr + (row<<10)    + col ;
			// set pixel color
			*(char *)pixel_ptr = pixel_color;		
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
				pixel_ptr = (char *)vga_pixel_ptr + (row<<10) + col ;
				// set pixel color
				*(char *)pixel_ptr = pixel_color;
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
		pixel_ptr = (char *)vga_pixel_ptr + (y<<10)+ x; 
		// set pixel color
		*(char *)pixel_ptr = c;	
		 
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
