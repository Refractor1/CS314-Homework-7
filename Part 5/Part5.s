.global _start
_start:

.equ ADDR_Front_Buffer, 0xFF203020
.equ ADDR_Slider_Switches, 0xFF200040

# SDRAM memory locations. Each will be the same memory size as the Front Buffer

 .equ VGA_Back_Buffer1, 0xC1000000
 .equ VGA_End_Back1, 0xC103C280

 .equ VGA_Back_Buffer1_Line, 0xC101E12C

 .equ VGA_Back_Buffer2, 0xC2000000
 .equ VGA_End_Back2, 0xC203C280

# colour values for the Pixel buffer

 .equ red,  0xF100
 .equ blue,  0x001F
 .equ green,  0x07E0
 .equ yellow,  0xFFE0
 .equ white,  0xFFFF
 .equ black,  0x0000

 .equ y_Shift, 0x3FB
# Fill back buffer1 memory locations with the colour red
 ldr  r2, =black
 ldr  r3, =VGA_Back_Buffer1
 ldr  r4, =VGA_End_Back1

# counter to increment through each back buffer1 memory location until 256k locations have been filled with red Pixel value

  mov  r5, #0
 count1y:
  
  ldr  r5, =0x140
 count1x: 
  strh r2, [r3], #2
  sub  r5, #1
  cmp  r5, #0
  bne  count1x
  cmp  r3, r4
  beq  hax1              //Skip over extra pixel if we are at the limit
  strh r2, [r3]
  add  r3, #0x180
 hax1:
  cmp  r3, r4
  ble  count1y

  ldr  r2, =blue
  ldr  r3, =VGA_Back_Buffer1_Line

  mov  r6, #20
  mov  r5, #0
 countLiney:

  ldr r5, =0x28
  countLinex:
  strh r2, [r3], #2
  sub  r5, #1
  cmp  r5, #0
  bne  countLinex

  sub  r6, r6, #1
  cmp  r6, #0
  add  r3, r3, #0xB0
  add  r3, r3, #0x300
  bne  countLiney


# Fill back buffer2 memory locations with the colour green

 ldr r2, =green
 ldr r3, =VGA_Back_Buffer2
 ldr r4, =VGA_End_Back2

# counter to increment through each back buffer2 memory location until 256k locations have been filled with green Pixel value

 count2y:
  
  ldr  r5, =0x140
 count2x: 
  strh r2, [r3], #2
  sub  r5, #1
  cmp  r5, #0
  bne  count2x
  cmp  r3, r4
  beq  hax2              //Skip over extra pixel if we are at the limit
  strh r2, [r3]
  add  r3, #0x180
 hax2:
  cmp  r3, r4
  ble  count2y

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

# change pointer to back buffer2 

 mov r4, r3      // keep track of  present back buffer
 str r6, [r5]    // swap buffer

# Wait for status bit to go low. This indicates the pointer is properly set

 swapcheck2:
 ldr r3, [r5, #12]   // load status bit
 ands r3,r3, r6
 bne swapcheck2

 b check
