  PROCESSOR 6502

  include "vcs.h"
  include "macro.h"

  seg.u Variables
  org $80
P0Height ds 1     ;defines space 1 byte
P1Height ds 1     ;defines space 1 byte

  seg code
  org $F000

Reset: 
  CLEAN_START                   ;macro to clean memory and TIA

  LDX #$80                      ;blue backgroud color
  STX COLUBK          

  LDA #%1111                    ;white playfield color
  STA COLUPF

  lda #10                       ;A = 10
  sta P0Height                  ;P0Height = 10
  sta P1Height                  ;P1Height = 10

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; We set the TIA registers for the colors of P0 and P1
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
  LDA #$48                       ;player 0 color light red
  STA COLUP0

  LDA #$C6                       ;player 1 color light green
  STA COLUP1

  ldy #%00000010                 ; CTRLPF D1 set 1 to means score
  sty CTRLPF

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; Start a new frame by configuring VBLANK and VSYNC
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
StartFrame: 
  lda #2
  sta VBLANK                    ;turn VBLANK on
  sta VSYNC                     ;turn VSYNC on

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  REPEAT 3
    STA WSYNC
  REPEND

  LDA #0
  STA VSYNC

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; Let the TIA output the 37 recommend lines of VBLANK
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
  REPEAT 37
    STA WSYNC
  REPEND

  LDA #0
  STA VBLANK

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; Draw the 192 visible scanlines
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
VisibleScanlines:
  ; Draw 10 scalines at the top of the frame
  REPEAT 10
    sta WSYNC
  REPEND

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; Displays 10 scanlines for the scoreboard number
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
  ldy #0
ScoreboardLoop:
  lda NumberBitmap,Y
  sta PF1
  sta WSYNC
  INY
  cpy #10
  bne ScoreboardLoop

  lda #0
  sta PF1     ;diable playfield
  
  ; Draw 50 empty scanlines betwee scoreboard and player
  REPEAT 50
    sta WSYNC
  REPEND

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; Displays 10 scanlines for the Player 0 graphics
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
  ldy #0
Player0Loop:
  lda PlayerBitmap,Y
  sta GRP0
  sta WSYNC
  INY
  cpy P0Height
  bne Player0Loop

  lda #0
  sta GRP0    ;disable player 0 graphics

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; Displays 10 scanlines for the Player 1 graphics
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
  ldy #0
Player1Loop:
  lda PlayerBitmap,Y
  sta GRP1
  sta WSYNC
  INY
  cpy P1Height
  bne Player1Loop

  lda #0
  sta GRP1    ;disable player 0 graphics


  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; Draw the remaining 102 scanlines
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
  REPEAT 102
    sta WSYNC
  REPEND


  REPEAT 30
    sta WSYNC
  REPEND
  
  
  JMP StartFrame


  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; Defines an array of bytes to draw the player.
  ; We add thes bytes in the last ROM addresses
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
  org $FFE8
PlayerBitmap:
  .byte #%01111110
  .byte #%11111111
  .byte #%10011001
  .byte #%11111111
  .byte #%11111111
  .byte #%11111111
  .byte #%10111101
  .byte #%11000011
  .byte #%11111111
  .byte #%01111110

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; Defines an array of bytes to draw the scoreboard number.
  ; We add thes bytes in the last ROM addresses
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
  org $FFF2
NumberBitmap:
  .byte #%00001110
  .byte #%00001110
  .byte #%00000010
  .byte #%00000010
  .byte #%00001110
  .byte #%00001110
  .byte #%00001000
  .byte #%00001000
  .byte #%00001110
  .byte #%00001110
 

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; Complete ROM size
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
  org $FFFC
  .word Reset
  .word Reset