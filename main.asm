;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SUBPIXELS OF YOUR MIND - A "SUBWAYS OF YOUR MIND" SNES MSU-1 TECH DEMO  ;
; Source code; Compile using WLA-DX 65816 compiler:                       ;
; The compile batch script is included in the source project.             ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.MEMORYMAP
  SLOTSIZE $8000
  DEFAULTSLOT 0
  SLOT 0 $8000
.ENDME

.ROMBANKSIZE $8000
.ROMBANKS $1
.16BIT

.SNESHEADER
  ID "FEX1"
  NAME "Fex SNES MSU-1 Demo  "

  LOROM

  CARTRIDGETYPE $00
  ROMSIZE 1
  SRAMSIZE $00
  COUNTRY $02
  LICENSEECODE $00
  VERSION $00
.ENDSNES

;Defining the native mode vectors:
.SNESNATIVEVECTOR
  COP reset
  BRK reset
  ABORT reset
  NMI nmi
  IRQ reset
.ENDNATIVEVECTOR

;Defining the emulation mode vectors:
.SNESEMUVECTOR
  COP reset
  ABORT reset
  NMI nmi
  RESET reset
  IRQBRK reset
.ENDEMUVECTOR

;Fill unused space with 0:
.EMPTYFILL $00

.bank $00 slot 0
.org $0000
.base $80

reset:

  ;Bringing the CPU to the native mode:
  sei
  clc
  xce

  ;8-bit accumulator and 16-bit index registers:
  rep #$10
  sep #$20

  ;Disable rendering for now (the Sun won't shine until the whole preparation is complete):
  lda #$80
  sta $2100

  ;Disable NMI:
  stz $4200

  ;Using background mode 5 for high resolution rendering:
  lda #$05
  sta $2105

  ;Disable mosaic effect:
  stz $2106

  ;Using 512x512 resolution for background #1:
  lda #$02
  sta $2107

  ;Set up the tileset for background #1:
  lda #$04
  sta $210b

  ;Set the position of background #1 to center the logo:
  lda #192
  sta $210d
  stz $210d
  lda #48
  sta $210e
  lda #1
  sta $210e

  ;Quick background loading:
  ldx #$8000
  ldy #$0000
  lda #$80
  sta $2115
  stz $2116
  stz $2117
- sty $2118
  inx
  bne -
  stz $2116
  stz $2117
- ldx BG, y
  stx $2118
  iny
  iny
  cpy #$200
  bne -

  ;Quick color palette loading:
  stz $2121
  ldx #0
- lda PALETTE, x
  sta $2122
  inx
  cpx #$200
  bne -

  ;Set the main and sub(way) screens:
  lda #$01
  sta $212c
  sta $212d

  ;Disable windows:
  stz $212e
  stz $212f

  ;Disable math color:
  stz $2130
  stz $2131
  stz $2132

  ;Enable screen interlacing:
  lda #%00000101
  sta $2133

  ;Enable NMI:
  lda #$80
  sta $4200

  ;Checking if the "S-MSU1" header is present:
- lda $2002
  cmp #$53
  bne -
- lda $2003
  cmp #$2D
  bne -
- lda $2004
  cmp #$4D
  bne -
- lda $2005
  cmp #$53
  bne -
- lda $2006
  cmp #$55
  bne -
- lda $2007
  cmp #$31
  bne -

  ;Waiting until the MSU-1 chip is free:
- lda $2000
  bit #%11000000
  bne -

  ;Music volume set to 100%:
  lda #$ff
  sta $2006
  
  ;Disable any music until we seek the audio track:
  lda #%00000000
  sta $2007

  ;Set audio track to #1 (our music is there):
  ldx #$0001
  stx $2004

  ;Enable and loop the track:
  lda #%00000011
  sta $2007

  ;Enable rendering (the Sun shone one more time):
  lda #$0f
  sta $2100

  ;Animation frame = 0;
  stz $00
  stz $01

- jmp -
    

nmi:

    ;DMA mode fixed:
    lda #%00001001
    sta $4300

    ;DMA to $2188:
    lda #$18
    sta $4301

    ;If the animation frame is 192 then reset it back to 0:
    lda $00
    cmp #192
    bne +
    stz $00
+

    ;Seek animation data:
    rep #$20
    lda $00
    and #$fe
    asl
    asl
    asl
    asl
    sta $2001
    sep #$20
    stz $2000
    stz $2003

    ;Waiting until the MSU-1 chip is free:
-   lda $2000
    bmi -

    ;DMA read from $2001
    ldx #$2001
    stx $4302
    stz $4304

    ;Size of data to transfer:
    ldx #$2000
    stx $4305
    stz $4307

    ;Set the VRAM pointer to $4000 (we're storing tileset data there):
    ldx #$4000
    stx $2116

    ;Fire DMA:
    lda #$01
    sta $420b

    ;+1 animation frame:
    inc $00

rti

PALETTE:
.incbin "palette.bin"

BG:
.incbin "bg.bin"