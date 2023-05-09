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
#define VEL_PIO                   0x30
#define HIT_PIO                   0x40
#define NPARTICLES_PIO            0x50
#define SW_P_PIO                  0x60
#define SW_V_PIO                  0x70
#define SW_N_PIO                  0x80
#define SW_T_PIO                  0x90

volatile unsigned int* delay_pio_ptr = NULL;
volatile unsigned int* box_pio_ptr = NULL;
volatile unsigned char* rst_pio_ptr = NULL;
volatile unsigned int* vel_pio_ptr = NULL;
volatile unsigned int* hit_pio_ptr = NULL;
volatile unsigned int* nparticles_pio_ptr = NULL;
volatile unsigned char* sw_p_pio = NULL;
volatile unsigned char* sw_v_pio = NULL;
volatile unsigned char* sw_n_pio = NULL;
volatile unsigned char* sw_t_pio = NULL;

int float2fix(float);
int float2fix(float a) { return (int)(a*262144); }

float fix2float(int);
float fix2float(int a) { return ((float)a) / 262144; }

int temp_delay = 10000000;
int temp_box = 100;
int temp_vel = 2; 
int temp_nparticles = 100;
int choose_int = 0;   // which setting to change
int choose_param = 0; // which gas paramter to change
int temp_press;
int temp_temp; 


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
    printf("0: Print Params, 1: Change Params -- ");
    scanf("%i", &choose_int);

    switch ( choose_int ) {
    
      case 0: // print params
        printf("\nPressure (# wall collisions): %d\n", *(hit_pio_ptr));
        printf("Volume (Box Size): %d\n", temp_box);
        printf("# of Particles: %d\n", temp_nparticles);
        printf("Temp (particle speed in pixels): %d\n\n", temp_vel);
        break;
      
      case 1: // Set params
        
        // p & v
        if ( *(sw_p_pio) && *(sw_v_pio) ) {
        
          printf("\nChange Param -- 0: Pressure, 1: Volume -- ");
          scanf("%i", &choose_param);
          
          // presure change, volume adjust
          if ( choose_param == 0 ) {
            printf("\nInput Pressure: ");
            scanf("%i", &temp_press);
            
            printf("\nAdjusting volume....\n\n");
            
            int direction = 0; 
            int oscillation_count = 0;
            
            while ( abs( temp_press - *(hit_pio_ptr) ) > 10 && temp_box < 350 && temp_box > 40 && oscillation_count < 2) {
            
              int temp_flag = *(hit_pio_ptr) - temp_press;
                  
              // pressure is too high
              if ( ( temp_flag > 10 ) && temp_box < 350 ) {
              
                if ( direction == 1 ){
                  oscillation_count += 1; 
                }
                direction = -1;
                
                temp_box += 10;
              } else if ( temp_box > 40 ) {
              
                if ( direction == -1 ){
                    oscillation_count += 1; 
                }
                direction = 1;
              
                temp_box -= 10;
              }
                
              *(box_pio_ptr) = temp_box;
              *(rst_pio_ptr) = 0;
              usleep( 1 );
            	*(rst_pio_ptr) = 1; 
              
              printf("Updating pressure...\n\n");
              int temp_val = *(hit_pio_ptr);
              while ( *(hit_pio_ptr) == temp_val ); // wait for change in collisions
              printf("New Volume = %d\n", temp_box);
              printf("Current pressure = %d\n\n", *(hit_pio_ptr));
            }
            
          // volume change, pressure adjust
          } else {
            printf("\nInput Volume: ");
            scanf("%i", &temp_box);
            temp_press = *(hit_pio_ptr);
            *(box_pio_ptr) = temp_box;
            *(rst_pio_ptr) = 0;
            usleep( 1 );
          	*(rst_pio_ptr) = 1; 
            printf("\nUpdating pressure....\n\n");
            while ( temp_press == *(hit_pio_ptr) );
            printf("New Pressure = %d\n\n", *(hit_pio_ptr));
          }
        
        // p & n
        } else if ( *(sw_p_pio) && *(sw_n_pio) ) {
        
          printf("\nChange Param -- 0: Pressure, 1: # Particles -- ");
          scanf("%i", &choose_param);
          
          // presure change, particles adjust
          if ( choose_param == 0 ) {
            printf("\nInput Pressure: ");
            scanf("%i", &temp_press);
            
            printf("\nAdjusting # particles....\n\n");
            
            int direction = 0; 
            int oscillation_count = 0;
            
            while ( abs( temp_press - *(hit_pio_ptr) ) > 10 && temp_nparticles < 240 && temp_nparticles > 10 && oscillation_count < 2 ) {
                  
              int temp_flag = *(hit_pio_ptr) - temp_press;
              
              // pressure is too high
              if ( ( temp_flag > 10 ) && temp_nparticles > 10 ){
                if ( direction == 1 ){
                    oscillation_count += 1; 
                  }
                  direction = -1;
                  
                  temp_nparticles -= 5; 
              }
                
              else if ( temp_nparticles < 240 ){
              
               if ( direction == -1 ){
                    oscillation_count += 1; 
                }
                direction = 1;
              
                temp_nparticles += 5;
              }
                
                
              *(nparticles_pio_ptr) = temp_nparticles;
              *(rst_pio_ptr) = 0;
              usleep( 1 );
            	*(rst_pio_ptr) = 1; 
             
              printf("Updating pressure...\n\n");
              int temp_val = *(hit_pio_ptr);
              while ( *(hit_pio_ptr) == temp_val ); // wait for change in collisions
              printf("New # Particles = %d\n", temp_nparticles);
              printf("Current pressure = %d\n\n", *(hit_pio_ptr));
            }
            
          // particles change, pressure adjust
          } else {
            printf("\nInput # of Particles: ");
            scanf("%i", &temp_nparticles);
            temp_press = *(hit_pio_ptr); 
            *(nparticles_pio_ptr) = temp_nparticles;
            *(rst_pio_ptr) = 0;
            usleep( 1 );
          	*(rst_pio_ptr) = 1;
            printf("\nUpdating pressure....\n\n");
            while ( temp_press == *(hit_pio_ptr) );
            printf("New Pressure = %d\n\n", *(hit_pio_ptr));
          }
        
        // p & t
        } else if ( *(sw_p_pio) && *(sw_t_pio) ) {
        
          printf("\nChange Param -- 0: Pressure, 1: Temp -- ");
          scanf("%i", &choose_param);
          
          // presure change, temp adjust
          if ( choose_param == 0 ) {
            printf("\nInput Pressure: ");
            scanf("%i", &temp_press);
            
            printf("\nAdjusting temp....\n\n");
            
            int direction = 0; 
            int oscillation_count = 0;
            
            while ( abs( temp_press - *(hit_pio_ptr) ) > 10 && temp_vel < 10 && temp_vel > 1 && oscillation_count < 2) {
            
              int temp_flag = *(hit_pio_ptr) - temp_press;
              
              // pressure is too high
              if ( ( temp_flag > 10 ) && temp_vel > 1 ) {
                if ( direction == 1 ){
                  oscillation_count += 1; 
                }
                direction = -1; 
                
                temp_vel -= 1;
              } else if ( temp_vel < 10 ) {
                
                if ( direction == -1 ){
                    oscillation_count += 1; 
                }
                direction = 1; 
                
                temp_vel += 1;
              }
              
              *(vel_pio_ptr) = temp_vel;
              *(rst_pio_ptr) = 0;
              usleep( 1 );
            	*(rst_pio_ptr) = 1; 
             
              printf("Updating pressure...\n\n");
              int temp_val = *(hit_pio_ptr);
              while ( *(hit_pio_ptr) == temp_val ); // wait for change in collisions
              printf("New temp = %d\n", temp_vel);
              printf("Current pressure = %d\n\n", *(hit_pio_ptr));
            }
          // temp change, pressure adjust
          } else {
            printf("Input Temp: ");
            scanf("%i", &temp_vel);
            temp_press = *(hit_pio_ptr);
            *(vel_pio_ptr) = temp_vel; 
            printf("\nUpdating pressure....\n\n");
            while ( temp_press == *(hit_pio_ptr) );
            printf("New Pressure = %d\n\n", *(hit_pio_ptr));
          }
        
        // v & n
        } else if ( *(sw_v_pio) && *(sw_n_pio) ) {
        
          printf("\nChange Param -- 0: Volume, 1: # Particles -- ");
          scanf("%i", &choose_param);
          
          // volume change, particles adjust
          if ( choose_param == 0 ) {
            printf("\nInput Volume: ");
            scanf("%i", &temp_box);
            temp_press = *(hit_pio_ptr);
            *(box_pio_ptr) = temp_box;
            *(rst_pio_ptr) = 0;
            usleep( 1 );
          	*(rst_pio_ptr) = 1;
           
            printf("\nPressure goal = %d\n\n", temp_press);
            printf("Updating pressure....\n\n");
            while ( temp_press == *(hit_pio_ptr) );
            printf("Adjusting # particles....\n\n");
            
            int direction = 0; 
            int oscillation_count = 0;
           
            while ( abs( temp_press - *(hit_pio_ptr) ) > 10 && temp_nparticles < 240 && temp_nparticles > 10 && oscillation_count < 2) {
            
              int temp_flag = *(hit_pio_ptr) - temp_press;
                  
              // pressure is too high
              if ( ( temp_flag > 10 ) && temp_nparticles > 10 ){
                if ( direction == 1 ){
                  oscillation_count += 1; 
                }
                direction = -1; 
                temp_nparticles -= 5;
              }
                
              else if ( temp_nparticles < 240 ){
              
                if ( direction == -1 ){
                    oscillation_count += 1; 
                }
                direction = 1; 
                
                temp_nparticles += 5;
              }
                
                
              *(nparticles_pio_ptr) = temp_nparticles;
              *(rst_pio_ptr) = 0;
              usleep( 1 );
            	*(rst_pio_ptr) = 1; 
             
              printf("Updating pressure...\n\n");
              int temp_val = *(hit_pio_ptr);
              while ( *(hit_pio_ptr) == temp_val ); // wait for change in collisions
              printf("New # Particles = %d\n", temp_nparticles);
              printf("Current pressure = %d\n\n", *(hit_pio_ptr));
            }

          // particles change, volum adjust
          } else {
            printf("Input # of Particles: ");
            scanf("%i", &temp_nparticles);
            *(nparticles_pio_ptr) = temp_nparticles;
            temp_press = *(hit_pio_ptr);
            *(rst_pio_ptr) = 0;
            usleep( 1 );
          	*(rst_pio_ptr) = 1; 
            
            printf("\nPressure goal = %d\n\n", temp_press);
            printf("Updating pressure....\n\n");
            while ( temp_press == *(hit_pio_ptr) );
            printf("Adjusting volume....\n\n");
            
            int direction = 0; 
            int oscillation_count = 0; 
           
            while ( (abs( temp_press - *(hit_pio_ptr) ) > 10 ) && temp_box < 350 && temp_box > 40 && oscillation_count < 2) {
            
              int temp_flag = *(hit_pio_ptr) - temp_press;
                  
              // pressure is too high
              if ( ( temp_flag > 10 ) && temp_box < 350 ) {
                if ( direction == 1 ){
                  oscillation_count += 1; 
                }
                direction = -1; 
                
                temp_box += 10;
              } else if ( temp_box > 40 ) {
              
                if ( direction == -1 ){
                    oscillation_count += 1; 
                }
                direction = 1; 
                
                temp_box -= 10;
              }
                
              *(box_pio_ptr) = temp_box;
              *(rst_pio_ptr) = 0;
              usleep( 1 );
            	*(rst_pio_ptr) = 1; 
             
              printf("Updating pressure...\n\n");
              int temp_val = *(hit_pio_ptr);
              while ( *(hit_pio_ptr) == temp_val ); // wait for change in collisions
              printf("New Volume = %d\n", temp_box);
              printf("Current pressure = %d\n\n", *(hit_pio_ptr));
            }
          }
        
        // v & t
        } else if ( *(sw_v_pio) && *(sw_t_pio) ) {
        
          printf("\nChange Param -- 0: Volume, 1: Temp -- ");
          scanf("%i", &choose_param);
        
          // volume change, temp adjust
          if ( choose_param == 0 ) {
            printf("Input Volume: ");
            scanf("%i", &temp_box);
            temp_press = *(hit_pio_ptr);
            *(box_pio_ptr) = temp_box;
            *(rst_pio_ptr) = 0;
            usleep( 1 );
          	*(rst_pio_ptr) = 1; 
            
            printf("\nPressure goal = %d\n\n", temp_press);
            printf("Updating pressure....\n\n");
            while ( temp_press == *(hit_pio_ptr) );
            printf("Adjusting temperature....\n\n");
            
            int direction = 0; 
            int oscillation_count = 0; 
           
            while ( abs( temp_press - *(hit_pio_ptr) ) > 10 && temp_vel < 10 && temp_vel > 1 && oscillation_count < 2 ) {
            
              int temp_flag = *(hit_pio_ptr) - temp_press;
                  
              // pressure is too high
              if ( ( temp_flag > 10 ) && temp_vel > 1 ){
                if ( direction == 1 ){
                  oscillation_count += 1; 
                }
                direction = -1; 
                
                temp_vel -= 1;
              }
                
              else if ( temp_vel < 10 ){
                if ( direction == -1 ){
                    oscillation_count += 1; 
                }
                
                direction = 1; 
                
                temp_vel += 1;
              }
                
                
              *(vel_pio_ptr) = temp_vel;
              *(rst_pio_ptr) = 0;
              usleep( 1 );
            	*(rst_pio_ptr) = 1; 
             
              printf("Updating pressure...\n\n");
              int temp_val = *(hit_pio_ptr);
              while ( *(hit_pio_ptr) == temp_val ); // wait for change in collisions
              printf("New Temp = %d\n", temp_vel);
              printf("Current pressure = %d\n\n", *(hit_pio_ptr));
            }
            
          // temp change, volume adjust
          } else {
            printf("\nInput Temp: ");
            scanf("%i", &temp_vel);
            temp_press = *(hit_pio_ptr);
            *(vel_pio_ptr) = temp_vel;
            
            printf("\nPressure goal = %d\n\n", temp_press);
            printf("Updating pressure....\n\n");
            while ( temp_press == *(hit_pio_ptr) );
            printf("Adjusting volume....\n\n");
            
            int direction = 0; 
            int oscillation_count = 0; 
            
            while ( abs( temp_press - *(hit_pio_ptr) ) > 10 && temp_box < 350 && temp_box > 40 && oscillation_count < 2 ) {
            
              int temp_flag = *(hit_pio_ptr) - temp_press;
                  
              // pressure is too high
              if ( ( temp_flag > 10 ) && temp_box < 350 ){
              
                if ( direction == 1 ){
                  oscillation_count += 1; 
                }
                direction = -1; 
                temp_box += 10;
              }
                
              else if ( temp_box > 40 ){
                if ( direction == -1 ){
                    oscillation_count += 1; 
                }
                
                direction = 1; 
                temp_box -= 10;
                
              }
                
                
              *(box_pio_ptr) = temp_box;
              *(rst_pio_ptr) = 0;
              usleep( 1 );
            	*(rst_pio_ptr) = 1; 
             
              printf("Updating pressure...\n\n");
              int temp_val = *(hit_pio_ptr);
              while ( *(hit_pio_ptr) == temp_val ); // wait for change in collisions
              printf("New Volume = %d\n", temp_box);
              printf("Current pressure = %d\n\n", *(hit_pio_ptr));
            }
          }
        
        // n & t
        } else if ( *(sw_n_pio) && *(sw_t_pio) ) {
        
          printf("\nChange Param -- 0: # Particles, 1: Temp -- ");
          scanf("%i", &choose_param);
        
          // particles change, temp adjust
          if ( choose_param == 0 ) {
            printf("\nInput # of Particles: ");
            scanf("%i", &temp_nparticles);
            temp_press = *(hit_pio_ptr);
            *(nparticles_pio_ptr) = temp_nparticles;
            *(rst_pio_ptr) = 0;
            usleep( 1 );
          	*(rst_pio_ptr) = 1;  
            
            printf("\nPressure goal = %d\n\n", temp_press);
            printf("Updating pressure....\n\n");
            while ( temp_press == *(hit_pio_ptr) );
            printf("Adjusting temperature....\n\n");
            
            int direction = 0; 
            int oscillation_count = 0; 
           
            while ( abs( temp_press - *(hit_pio_ptr) ) > 10 && temp_vel < 10 && temp_vel > 1 && oscillation_count < 2) {
            
              int temp_flag = *(hit_pio_ptr) - temp_press;
                  
              // pressure is too high
              if ( ( temp_flag > 10 ) && temp_vel > 1 ){
                
                if ( direction == 1 ){
                  oscillation_count += 1; 
                }
                direction = -1; 
                  
                temp_vel -= 1;
              }
              else if ( temp_vel < 10 ){
              
                if ( direction == -1 ){
                    oscillation_count += 1; 
                }
                
                direction = 1; 
                temp_vel += 1;
              }
                
              *(vel_pio_ptr) = temp_vel;
              *(rst_pio_ptr) = 0;
              usleep( 1 );
            	*(rst_pio_ptr) = 1; 
             
              printf("Updating pressure...\n\n");
              int temp_val = *(hit_pio_ptr);
              while ( *(hit_pio_ptr) == temp_val ); // wait for change in collisions
              printf("New Temp = %d\n", temp_vel);
              printf("Current pressure = %d\n\n", *(hit_pio_ptr));
            }
          // temp change, particles adjust
          } else {
            printf("Input Temp: ");
            scanf("%i", &temp_vel);
            temp_press = *(hit_pio_ptr);
            *(vel_pio_ptr) = temp_vel;
            
            printf("\nPressure goal = %d\n\n", temp_press);
            printf("Updating pressure....\n\n");
            while ( temp_press == *(hit_pio_ptr) );
            printf("Adjusting # particles....\n\n");
            
            int direction = 0; 
            int oscillation_count = 0; 
            
            while ( abs( temp_press - *(hit_pio_ptr) ) > 10 && temp_nparticles < 240 && temp_nparticles > 10 && oscillation_count < 2 ) {
            
              int temp_flag = *(hit_pio_ptr) - temp_press;
                  
              // pressure is too high
              if ( ( temp_flag > 10 ) && temp_nparticles > 10 ){
              
                if ( direction == 1 ){
                  oscillation_count += 1; 
                }
                direction = -1; 
                
                temp_nparticles -= 5;
              }
              else if ( temp_nparticles < 240 ){
              
                if ( direction == -1 ){
                    oscillation_count += 1; 
                }
                
                direction = 1; 
                
                temp_nparticles += 5;
              }
                
                
              *(nparticles_pio_ptr) = temp_nparticles;
              *(rst_pio_ptr) = 0;
              usleep( 1 );
            	*(rst_pio_ptr) = 1; 
              
              printf("Updating pressure...\n\n");
              int temp_val = *(hit_pio_ptr);
              while ( *(hit_pio_ptr) == temp_val ); // wait for change in collisions
              printf("New # Particles = %d\n", temp_nparticles);
              printf("Current pressure = %d\n\n", *(hit_pio_ptr));
            }
          }
        }
        break;
      
      case 2: // x, y, z, init values
        printf("Wall hits: ");
        printf("%i\n", *(hit_pio_ptr));
        break;
      
      case 3: // x, y, z, init values
        printf("Input delay: ");
        scanf("%i", &temp_delay);
        *(delay_pio_ptr) = temp_delay;
        *(rst_pio_ptr) = 0;
        usleep( 1 );
      	*(rst_pio_ptr) = 1; 
        break;
      
      case 4: // x, y, z, init values
        printf("Input nparticles: ");
        scanf("%i", &temp_nparticles);
        *(nparticles_pio_ptr) = temp_nparticles;
        *(rst_pio_ptr) = 0;
        usleep( 1 );
      	*(rst_pio_ptr) = 1; 
        break;
      
      case 5: // x, y, z, init values
        printf("Speed: ");
        scanf("%i", &temp_vel);
        *(vel_pio_ptr) = temp_vel;
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
  vel_pio_ptr = (unsigned int *)(h2p_lw_virtual_base + VEL_PIO);
  hit_pio_ptr = (unsigned int *)(h2p_lw_virtual_base + HIT_PIO);
  nparticles_pio_ptr = (unsigned int *)(h2p_lw_virtual_base + NPARTICLES_PIO);
  sw_p_pio = (unsigned char *)(h2p_lw_virtual_base + SW_P_PIO);
  sw_v_pio = (unsigned char *)(h2p_lw_virtual_base + SW_V_PIO);
  sw_n_pio = (unsigned char *)(h2p_lw_virtual_base + SW_N_PIO);
  sw_t_pio = (unsigned char *)(h2p_lw_virtual_base + SW_T_PIO);
 
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
  *(vel_pio_ptr) = temp_vel;
  *(nparticles_pio_ptr) = temp_nparticles;
  
  *(rst_pio_ptr) = 0;
  usleep( 1 );
	*(rst_pio_ptr) = 1;
 
  printf("\n");
 
//  while (1) {
//    printf("Hit Counter: %d\n", *(hit_pio_ptr));
//    usleep(10000);
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



