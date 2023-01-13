
;==============================================================================
; title program
;==============================================================================

.include "include/global.inc"
;.include "include/scene_adv_common.inc"

;===================================
; 
;===================================

.memorymap
   defaultslot     0
   
   slotsize        $4000
   slot            0       $4000
   slotsize        $2000
   slot            1       $8000
   slotsize        $2000
   slot            2       $A000
   slotsize        $2000
   slot            3       $C000
.endme

.rombankmap
  bankstotal $1F
  
  banksize $4000
  banks $1
  banksize $2000
  banks $1E
.endro

.emptyfill $FF

.background ROMNAME

;======================================================================
; 
;======================================================================

.unbackground $2700 $3FFF
.unbackground $5900 $5FFF

.define freeBanksBase -1

;.define baseOffset $4000
;.define bankSize $2000

;.macro makeFixedPointer ARGS ptr
;  .dw (ptr&$1FFF)+((:ptr)*bankSize)+baseOffset
;.endm

.define bank0 0
.define bank2 freeBanksBase+$2
.define bank3 freeBanksBase+$3
.define bank4 freeBanksBase+$4
.define bank5 freeBanksBase+$5
.define bank6 freeBanksBase+$6
.define bank7 freeBanksBase+$7
.define bank8 freeBanksBase+$8
.define bank9 freeBanksBase+$9
.define bankA freeBanksBase+$A
.define bankB freeBanksBase+$B
.define bankC freeBanksBase+$C
.define bankD freeBanksBase+$D
.define bankE freeBanksBase+$E
.define bankF freeBanksBase+$F
.define bank10 freeBanksBase+$10
.define bank11 freeBanksBase+$11
.define bank12 freeBanksBase+$12
.define bank13 freeBanksBase+$13
.define bank14 freeBanksBase+$14
.define bank15 freeBanksBase+$15
.define bank16 freeBanksBase+$16
.define bank17 freeBanksBase+$17
.define bank18 freeBanksBase+$18
.define bank19 freeBanksBase+$19
.define bank1A freeBanksBase+$1A
.define bank1B freeBanksBase+$1B
.define bank1C freeBanksBase+$1C
.define bank1D freeBanksBase+$1D
.define bank1E freeBanksBase+$1E
.define bank1F freeBanksBase+$1F

;=====
; load new menu graphics
;=====

.define newMenuGrpSrcBank $B
.define newMenuGrpSrcOffset $0
.define newMenuGrpSrcPtr $A000+newMenuGrpSrcOffset
.define newMenuGrpDstAddr $4800
; must be divisible by $100
.define newMenuGrpSize $1700

.bank 0 slot 0
.orga $591B
.section "new grp 1" overwrite
  jmp loadNewMenuGrp
.ends

.bank 0 slot 0
.section "new grp 2" free
  loadNewMenuGrp:
    ; src bank
    lda #newMenuGrpSrcBank
    clc 
    adc $6D.b
    tam #$20
    ina 
    tam #$40
    ; src
    lda #<newMenuGrpSrcPtr
    sta $20.b
    lda #>newMenuGrpSrcPtr
    sta $21.b
    lda #$00
    sta $F7.b
    sta $0000.w
    ; dst = vram $4000
    lda #<newMenuGrpDstAddr
    sta $0002.w
    lda #>newMenuGrpDstAddr
    sta $0003.w
    lda #$02
    sta $F7.b
    sta $0000.w
    ; size
    ldx #((newMenuGrpSize+$FF)/$100)
    ; loop
    --:
      cly 
      ; loop
      -:
        lda ($20.b),Y
        sta $0002.w
        iny 
        lda ($20.b),Y
        sta $0003.w
        iny 
        bne -
      inc $21.b
      dex 
      bne --
    
    ; make up work
    pla
    tam #$40
    jmp $591E
.ends

;=====
; use new menu sprite defs
;=====

.define titleSpriteDefsPtrBase $C000

.bank bank2 slot 2
.orga $B63A+($13*$2)
.section "new sprite defs tables 1" overwrite
  .dw (newOptions0Def&$1FFF)+titleSpriteDefsPtrBase
  .dw (newOptions1Def&$1FFF)+titleSpriteDefsPtrBase
  .dw (newOptions2Def&$1FFF)+titleSpriteDefsPtrBase
.ends

.bank bank2 slot 2
.orga $B63A+($16*$2)
.section "new sprite defs tables 2" overwrite
  .dw (newFiles0ColorDef&$1FFF)+titleSpriteDefsPtrBase
  .dw (newFiles1ColorDef&$1FFF)+titleSpriteDefsPtrBase
  .dw (newFiles2ColorDef&$1FFF)+titleSpriteDefsPtrBase
  .dw (newFiles3ColorDef&$1FFF)+titleSpriteDefsPtrBase
  .dw (newFiles4ColorDef&$1FFF)+titleSpriteDefsPtrBase
.ends

.bank bank2 slot 2
.orga $B63A+($1C*$2)
.section "new sprite defs tables 3" overwrite
  .dw (newFiles0OffDef&$1FFF)+titleSpriteDefsPtrBase
  .dw (newFiles1OffDef&$1FFF)+titleSpriteDefsPtrBase
  .dw (newFiles2OffDef&$1FFF)+titleSpriteDefsPtrBase
  .dw (newFiles3OffDef&$1FFF)+titleSpriteDefsPtrBase
  .dw (newFiles4OffDef&$1FFF)+titleSpriteDefsPtrBase
.ends

;=====
; new menu sprite defs
;=====

.bank bank2 slot 2
.section "new sprite defs 1" free
  newOptions0Def: .incbin "out/grp/title_options_0_spr.bin"
  newOptions1Def: .incbin "out/grp/title_options_1_spr.bin"
  newOptions2Def: .incbin "out/grp/title_options_2_spr.bin"
  newFiles0ColorDef: .incbin "out/grp/title_files_0_spr.bin"
  newFiles1ColorDef: .incbin "out/grp/title_files_1_spr.bin"
  newFiles2ColorDef: .incbin "out/grp/title_files_2_spr.bin"
  newFiles3ColorDef: .incbin "out/grp/title_files_3_spr.bin"
  newFiles4ColorDef: .incbin "out/grp/title_files_4_spr.bin"
  newFiles0OffDef: .incbin "out/grp/title_files_0_off_spr.bin"
  newFiles1OffDef: .incbin "out/grp/title_files_1_off_spr.bin"
  newFiles2OffDef: .incbin "out/grp/title_files_2_off_spr.bin"
  newFiles3OffDef: .incbin "out/grp/title_files_3_off_spr.bin"
  newFiles4OffDef: .incbin "out/grp/title_files_4_off_spr.bin"
.ends

;=====
; adjust menu cursor positions
;=====

.bank 0 slot 0
.orga $5ECB
.section "menu cursor pos 1" overwrite
  ; base y-pos for main menu
  lda #$80-1
.ends

.bank 0 slot 0
.orga $5FAA
.section "menu cursor pos 2" overwrite
  ; base y-pos
  adc #$80-1
.ends

.bank 0 slot 0
.orga $5FC1
.section "menu cursor pos 3" overwrite
  ; base y-pos for load menu
  lda #$70-1
.ends

.bank 0 slot 0
.orga $60FA
.section "menu cursor pos 4" overwrite
  ; base y-pos
  adc #$70-1
.ends

.bank 0 slot 0
.orga $654A
.section "menu cursor pos 5" overwrite
  ; base y-pos for main menu (reset)
  adc #$80-1
.ends

.bank 0 slot 0
.orga $6629
.section "menu cursor pos 6" overwrite
  ; base y-pos for load menu (reset)
  adc #$70-1
.ends

;=====
; load new bonus menu graphics
;=====

.define newBonusMenuGrpOffset $8400
.define newBonusMenuGrpSize $1C00
.define newBonusMenuGrpBank newBonusMenuGrpOffset/$2000
.define newBonusMenuGrpPointer $C000+(newBonusMenuGrpOffset&$1FFF)

.bank 0 slot 0
.orga $5A5D
.section "new bonus menu grp 1" overwrite
  lda #newBonusMenuGrpBank
.ends

.bank 0 slot 0
.orga $5A7C
.section "new bonus menu grp 2" overwrite
  lda #<newBonusMenuGrpPointer
  sta $20.b
  lda #>newBonusMenuGrpPointer
  sta $21.b
.ends

.bank 0 slot 0
.orga $5A84
.section "new bonus menu grp 3" overwrite
  ldx #((newBonusMenuGrpSize+$FF)/$100)
.ends

;======================================================================
; backup utility
;======================================================================

.define nextCharWidthB $4A
.define charTopFillerRows 2
.define nextChar1bppBuffer $36A9
.define nextChar1bppBufferSize 32

;===================================
; new strings
;===================================

.include "asm/gen/backutil.inc"

;===================================
; redirect printing to new strings
;===================================

.bank 0 slot 0
.orga $4EA7
.section "use new strings 1" overwrite
  jmp redirectToNewString
.ends

.bank 0 slot 0
.section "use new strings 2" free
  redirectToNewString:
    ; $48 = old string pointer
    lda $36CC.w
    sta $48.b
    lda $36CD.w
    sta $49.b
    
    ; read new string pointer from first two bytes of old location
    lda ($48.b)
    sta $36CC.w
    ldy #1
    lda ($48.b),Y
    sta $36CD.w
    
    ; make up work
    jsr $4B69
    jmp $4EAA
.ends

;===================================
; use 8-bit encoding
;===================================

.bank 0 slot 0
.orga $4EE6
.section "new text encoding 1" overwrite
;  adc #$02
  adc #$01
.ends

;===================================
; use new font
;===================================

.bank 0 slot 0
.section "use new font 1" free
  fontStd:
    .incbin "out/font/font_narrow.bin"
  
  fontAlt:
    .incbin "out/font/font.bin"
  
  fontWidthStd:
    .incbin "out/font/fontwidth_narrow.bin"
  
  fontWidthAlt:
    .incbin "out/font/fontwidth.bin"
  
  fontEmphOn:
    .db $00
.ends

.bank 0 slot 0
.orga $497B
.section "use new font 2" overwrite
  ; convert raw glyph index to table offset
  lda $11.b
  sta @emphSpCheckInstr+1.w
  sec
  sbc #fontBaseOffset
  tay
  
  ;=====
  ; multiply font table offset by 10 to get src offset in font data
  ;=====
  
  ; multiply by 2, saving result separately for future use
  asl
  sta @fontFinalAdd1+1.w
  stz $13.b
  
  ; shift left twice to get (raw * 8)
  asl
  rol $13.b
  asl
  rol $13.b
  
  ; add base pointer for font data
  clc
  adc #<fontStd
  sta $12.b
  lda $13.b
  adc #>fontStd
  sta $13.b
  
  ; add (raw * 2) to (raw * 8) to get (raw * 10)
  @fontFinalAdd1:
  lda #$00
  clc
  adc $12.b
  sta $12.b
  
;    @fontFinalAdd2:
;    lda #$00
  cla
  adc $13.b
  sta $13.b
    
  ; if font emph on, move to alt font
  lda fontEmphOn.w
  beq +
    lda #<(fontAlt-fontStd)
    clc
    adc $12.b
    sta $12.b
    lda #>(fontAlt-fontStd)
    adc $13.b
    sta $13.b
  +:
  
  ;=====
  ; look up width
  ;=====
  
  ; if font emph on, use alt font table
  lda fontEmphOn.w
  beq +
  ; also use standard width for spaces
  @emphSpCheckInstr:
  lda #$00
  cmp #code_space
  beq +
    lda fontWidthAlt.w,Y
    ; +1, we're using this for situations where
    ; the base font is spaced too tightly
    ina
    bra ++
  +:
    lda fontWidthStd.w,Y
  ++:
  
  ; save width
;  sta currentCharWidth.w
;  sta currentCharRawGlyphWidth.w
  sta nextCharWidthB.b
  
  ; HACK: game doesn't like if last character goes to exactly a pattern boundary,
  ; so in that case, add an extra pixel of width
  ; check if next char == terminator
  ; (HACK: assumes no control codes at end of string, but we can probably
  ; accommodate that for the limited use case here)
/*  lda $10.b
  bne +
    ; check if ((pixelSubX + newCharW) & 0x7) == 1
    lda $85.b
    clc
    adc nextCharWidthB.b
    and #$07
    bne +
      inc nextCharWidthB.b
  +:*/
  
  ;=====
  ; copy character data to dst buffer
  ;=====
  
  lda #(charTopFillerRows*2)
  sta @cpxInstr+1.w
  
  @addFillerRows:
  clx
  -:
    stz nextChar1bppBuffer.w,X
    inx
    @cpxInstr:
    cpx #$00
    bne -
  
  cly
  -:
    ; copy left part
    lda ($12.b),Y
    sta nextChar1bppBuffer.w,X
    inx
    
    ; blank right part
    stz nextChar1bppBuffer.w,X
    inx
    
    iny
    cpy #bytesPerRawFontChar
    bne -
  
  ; blank remaining rows of buffer
  -:
    stz nextChar1bppBuffer.w,X
    inx
    cpx #nextChar1bppBufferSize
    bne -
  
  jmp $4A99
.ends

;===================================
; use new font width
;===================================

;.bank 0 slot 0
;.orga $4BE7
;.section "new font width 1" overwrite
;  jmp $4C2C
;.ends

;===================================
; repurpose op 0C (half-width print)
; for switching to wide font
;===================================

.bank 0 slot 0
.orga $4E6F
.section "alt font switch 1" overwrite
  lda fontEmphOn.w
  eor #$FF
  sta fontEmphOn.w
  
  ; ++src
  inc $48.b
  bne +
    inc $49.b
  +:
  
  jmp $4EA2
.ends
















