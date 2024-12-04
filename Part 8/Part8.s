.equ ADDR_Front_Buffer, 0xFF203020
.equ ADDR_Push_Buttons, 0xFF20302C

# SDRAM memory locations. Each will be the same memory size as the Front Buffer

 .equ VGA_Back_Buffer1, 0xC1000000
 .equ VGA_End_Back1, 0xC103C280

 .equ VGA_Back_Buffer_Start, 0xC101E12C

 .equ VGA_Back_Buffer2, 0xC2000000
 .equ VGA_End_Back2, 0xC203C280

# colour values for the Pixel buffer

 .equ red,  0xF100
 .equ blue,  0x001F
 .equ green,  0x07E0
 .equ yellow,  0xFFE0
 .equ white,  0xFFFF
 .equ black,  0x0000

# Define masks as words instead of equates
xBitMask: .word 0x000003FE
yBitMask: .word 0x0003FC00
xBitMax:  .word 0x00000230
yBitMax:  .word 0x00037000

rectanglePosition: .word 0xC101E12C

.global _start
_start:
# Fill back buffer1 memory locations with the colour red
 ldr  r2, =black
 ldr  r3, =VGA_Back_Buffer1
 ldr  r4, =VGA_End_Back1

 b skipOverDraws
# counter to increment through each back buffer1 memory location until 256k locations have been filled with red Pixel value
drawBackground1:
  mov  r5, #0
 count1y:
  
  mov  r5, #0x140
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
  bx lr

  ldr  r3, =VGA_Back_Buffer_Start

 drawRectangle1:
  //Color selection and positioning
  ldr  r2, =blue
  //Size vertical of rectangle
  mov  r6, #20
  mov  r5, #0

  countLiney1:
  mov  r5, #0x28 //Size horizontal of rectangle
  countLinex1:
  strh r2, [r3], #2
  sub  r5, #1
  cmp  r5, #0
  bne  countLinex1
  sub  r6, r6, #1
  cmp  r6, #0
  add  r3, r3, #0xB0
  add  r3, r3, #0x300
  bne  countLiney1
  bx lr

# Fill back buffer2 memory locations with the colour green

 ldr r2, =black
 ldr r3, =VGA_Back_Buffer2
 ldr r4, =VGA_End_Back2

# counter to increment through each back buffer2 memory location until 256k locations have been filled with green Pixel value
drawBackground2:
  mov  r5, #0
 count2y:
  
  mov  r5, #0x140
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
  bx lr

  ldr  r3, =VGA_Back_Buffer_Start

 drawRectangle2:
  //Color selection
  ldr  r2, =blue
  //Size vertical of rectangle
  mov  r6, #20
  mov  r5, #0

  countLiney2:
  mov  r5, #0x28 //Size horizontal of rectangle
  countLinex2:
  strh r2, [r3], #2
  sub  r5, #1
  cmp  r5, #0
  bne  countLinex2
  sub  r6, r6, #1
  cmp  r6, #0
  add  r3, r3, #0xB0
  add  r3, r3, #0x300
  bne  countLiney2
  bx lr

skipOverDraws:
#  load pointer for back Buffer1

  ldr r5, =ADDR_Front_Buffer
  ldr r3, =VGA_Back_Buffer1
  str r3, [r5, #4] 	// set pointer location of back buffer1
  mov r6, #1
  str r6, [r5]          //  enable double buffering

# Make sure status bit goes low. This indicates the pointers are properly set

 swapcheck:
  ldr  r3,[r5, #12]
  ands r3,r3, r6
  bne  swapcheck

#  load pointer for back Buffer2

  ldr r3, =VGA_Back_Buffer2
  str r3, [r5, #4] 	//  set start location of Back Buffer2


# load slider switch value  

  ldr r0, =ADDR_Push_Buttons
  mov r8, #1
reDraw:
  // Draw to Buffer1
  ldr r2, =black
  ldr r3, =VGA_Back_Buffer1
  ldr r4, =VGA_End_Back1
  bl drawBackground1         // Draw background first
  ldr r5, =rectanglePosition
  ldr r3, [r5]              // Load rectangle position
  bl drawRectangle1         // Draw rectangle (without automatic movement)

check:
  ldr r1, [r0]              // Load pushbutton value
  and r1, r1, #1            // Mask for KEY3 (bit 3)
  cmp r1, r8                // Compare with previous state
  beq check                 // If same, keep checking
  
  // If we get here, the key state changed
  ldr r5, =rectanglePosition
  ldr r3, [r5]              // Load current position
  
  // Check if we've reached the maximum x position
  ldr r6, =xBitMax          // Load address of xBitMax
  ldr r6, [r6]              // Load the actual value from memory
  ldr r7, =xBitMask
  ldr r7, [r7]
  and r7, r3, r7
  cmp r7, r6                // Compare with maximum
  bge skip_movement         // Skip if we're at or past max
  
  add r3, r3, #0x2          // Move one pixel
  str r3, [r5]              // Store new position
skip_movement:
  mov r8, r1                // Update previous state

  // Draw to Buffer2
  ldr r2, =black
  ldr r3, =VGA_Back_Buffer2
  ldr r4, =VGA_End_Back2
  bl drawBackground2         // Draw background first
  ldr r5, =rectanglePosition
  ldr r3, [r5]
  bl drawRectangle2         // Draw rectangle (without automatic movement)
  mov r8, r1      // keep track of  present back buffer
  str r10, [r9]    // swap buffer

# Wait for status bit to go low. This indicates the pointer is properly set

 swapcheck2:
  ldr r1, [r9, #12]   // load status bit
  ands r1, r1, r10
  bne swapcheck2

  b reDraw
