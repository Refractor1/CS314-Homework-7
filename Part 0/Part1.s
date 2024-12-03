.equ ADDR_Front_Buffer, 0xFF203020
.equ ADDR_Slider_Switches, 0xFF200040

# SDRAM memory locations. Each will be the same memory size as the Front Buffer

 .equ VGA_Back_Buffer1, 0xC1000000
 .equ VGA_End_Back1, 0xC103FFFF

 .equ VGA_Back_Buffer2, 0xC2000000
 .equ VGA_End_Back2, 0xC203FFFF

# colour values for the Pixel buffer

 .equ red,  0xF100
 .equ blue,  0x001F
 .equ green,  0x07E0
 .equ yellow,  0xFFE0
 .equ white,  0xFFFF

# Fill back buffer1 memory locations with the colour red

 ldr  r2, =red
 ldr  r3, =VGA_Back_Buffer1
 ldr  r4, =VGA_End_Back1

# counter to increment through each back buffer1 memory location until 256k locations have been filled with red Pixel value

 count1:
  strh r2, [r3], #2
  cmp r3,r4
  ble  count1

# Fill back buffer2 memory locations with the colour green

 ldr r2, =green
 ldr r3, =VGA_Back_Buffer2
 ldr r4, =VGA_End_Back2

# counter to increment through each back buffer2 memory location until 256k locations have been filled with green Pixel value

 count2:
  strh r2, [r3], #2
  cmp  r3, r4
  ble count2

#  load pointer for back Buffer1

  ldr r5, =ADDR_Front_Buffer
  ldr r3, =VGA_Back_Buffer1
  str r3, [r5, #4] 	// set pointer location of back buffer1
  mov  r6, #1
  str r6, [r5]          //  enable double buffering

# Make sure status bit goes low. This indicates the pointers are properly set

 swapcheck:
 ldr r3,[r5, #12]
 ands r3,r3, r6
 bne swapcheck

#  load pointer for back Buffer2

  ldr r3, =VGA_Back_Buffer2
  str r3, [r5, #4] 	//  set start location of Back Buffer2


# load slider switch value  

  ldr r2,  =ADDR_Slider_Switches
  mov r4, #0

 check:
  ldr r3, [r2]
  and r3,r3, #1
  cmp r3,r4
  beq check 

#change pointer to back buffer2 

 mov r4, r3      // keep track of  present back buffer
 str r6, [r5]    // swap buffer

# Wait for status bit to go low. This indicates the pointer is properly set

 swapcheck2:
 ldr r3, [r5, #12]   #load status bit
 ands r3,r3, r6
 bne swapcheck2

 b check
