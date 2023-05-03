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
#include <pthread.h>
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
#define DELAY_PIO                 0x00
#define BOX_PIO                   0x10
#define RST_PIO                   0x20
#define RHO_PIO                   0x30
#define NROWS_PIO                 0x40
#define RHO_0_PIO                 0x50

volatile unsigned int* delay_pio_ptr = NULL;
volatile unsigned int* box_pio_ptr = NULL;
volatile unsigned char* rst_pio_ptr = NULL;
volatile unsigned int* rho_pio_ptr = NULL;
volatile unsigned int* nrows_pio_ptr = NULL;
volatile signed int* rho_0_pio_ptr = NULL;

int float2fix(float);
int float2fix(float a) { return (int)(a*262144); }

float fix2float(int);
float fix2float(int a) { return ((float)a) / 262144; }

int temp_delay = 10000000;
int temp_box = 200;
float temp_ampl = 0.4;
float temp_rho_0 = 0.25;
int choose_int = 0;   // which setting to change

int max(int a, int b);
int max(int a, int b) {
  if ( a > b )
    return a;
  return b;
}

///////////////////////////////////////////////////////////////
// scan thread
///////////////////////////////////////////////////////////////

void * scan_thread() {
  
  while (1) {
  
    // Which category to change?
    printf("0: delay, 1: box size -- ");
    scanf("%i", &choose_int);

    switch ( choose_int ) {
    
      case 0: // x, y, z, init values
        printf("Delay in cycles: ");
        scanf("%i", &temp_delay);
        *(delay_pio_ptr) = temp_delay;
       
        break;
        
      case 1: // sigma, beta, rho parameters
        printf("Box Size: ");
        scanf("%d", &temp_box);
        *(box_pio_ptr) = temp_box;
        *(rst_pio_ptr) = 0;
        usleep( 1 );
      	*(rst_pio_ptr) = 1;
              
        break;
    }
  }
}

// =============================================
// Main
// =============================================
int main(void)
{

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
  delay_pio_ptr = (unsigned int *)(h2p_lw_virtual_base + DELAY_PIO);
  box_pio_ptr = (unsigned int *)(h2p_lw_virtual_base + BOX_PIO);
  rst_pio_ptr = (unsigned char *)(h2p_lw_virtual_base + RST_PIO);
  rho_pio_ptr = (unsigned int *)(h2p_lw_virtual_base + RHO_PIO);
  nrows_pio_ptr = (unsigned int *)(h2p_lw_virtual_base + NROWS_PIO);
  rho_0_pio_ptr = (signed int *)(h2p_lw_virtual_base + RHO_0_PIO);
 
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
	
 
  *(delay_pio_ptr) = temp_delay;
  *(box_pio_ptr) = temp_box;
  *(rst_pio_ptr) = 0;
  usleep( 1 );
	*(rst_pio_ptr) = 1;
 
//  while (1) {
//    printf("Output Val = %f\n", fix2float(*(output_pio_ptr)) );
//  }
 
  // thread identifiers
   pthread_t thread_scan;
   
   // For portability, explicitly create threads in a joinable state 
	 // thread attribute used here to allow JOIN
	 pthread_attr_t attr;
	 pthread_attr_init( &attr );
	 pthread_attr_setdetachstate( &attr, PTHREAD_CREATE_JOINABLE );
	
	 // now the threads
   pthread_create( &thread_scan, NULL, scan_thread, NULL );

   pthread_join( thread_scan, NULL );
   return 0;
} // end main



