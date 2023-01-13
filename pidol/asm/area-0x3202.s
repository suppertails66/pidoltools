
;==============================================================================
; 
;==============================================================================

.include "include/global.inc"
.include "include/cafe_password.inc"

;===================================
; 
;===================================

.memorymap
   defaultslot     0
   
   slotsize        $2000
   slot            0       $8000
   slot            1       $A000
.endme

.rombankmap
  bankstotal $8
  
  banksize $2000
  banks $8
.endro

.emptyfill $FF

.background ROMNAME

;======================================================================
; 
;======================================================================

; free space
; HACK: generated script text has to go in these banks.
; the script generator has a hack that prevents these specific
; areas from being marked as usable for text, so we can use them
; for the extra resources needed for the new password system.
.unbackground $1E80 $1FFF
.unbackground $3D80 $3FFF

; disused space from removed diacritic handling
.unbackground $2A9F $2B2A

;=====
; use new password data
;=====

.bank 0 slot 0
.orga $9656
.section "new password list 1" overwrite
  lda #<newPasswordData
  sta $20.b
  lda #>newPasswordData
  sta $21.b
.ends

.bank 0 slot 0
.section "new password list 2" free
  newPasswordData:
    .incbin "out/script/strings/cafe-passwords-0.bin"
.ends

;=====
; extend length of password (bank 0)
;=====

; checking input for match after confirming password
.bank 0 slot 0
.orga $966D
.section "password length bank0 1" overwrite
  cpy #newPasswordLen
.ends

; checking input for match after confirming password (2)
.bank 0 slot 0
.orga $967F
.section "password length bank0 2" overwrite
  adc #newPasswordLen
.ends

; setting position of bottom-window cursor
.bank 0 slot 0
.orga $9305
.section "password length bank0 3" overwrite
  cmp #newPasswordLen
  bcc +
    lda #newPasswordLen-1
  +:
.ends

;=====
; extend length of password (bank 1)
;=====

; printing currently entered password
.bank 1 slot 0
.orga $8A8B
;.org $A8B
.section "password length bank1 1" overwrite
  cpx #newPasswordLen
.ends

; adding standard char to name
.bank 1 slot 0
.orga $8B5B
;.org $B5B
.section "password length bank1 2" overwrite
  cmp #newPasswordLen
.ends

; adding standard char to name (2)
.bank 1 slot 0
.orga $8B64
;.org $B64
.section "password length bank1 3" overwrite
  lda #newPasswordLen
.ends

;======================================================================
; new character draw
;======================================================================

.define passwordFontChar1bppDst $2D4F

;.define passwordFontCharLineOffset 5

;===================================
; new font lookup
;===================================

.bank 1 slot 0
.orga $8A27
.section "new print 1" SIZE $27 overwrite
  
  ;=====
  ; look up font char 1
  ;=====
  
  ; fetch next char
  lda nameEntryInputArray.w,X
  bpl +
  ; if next char negative (null position), treat as space
    lda #passwordSpaceValue
  +:
  
  phx
    jsr loadPasswordFontCharLeft
  plx
  
  ;=====
  ; look up font char 2
  ;=====
  
  ; fetch next char
  inx
  lda nameEntryInputArray.w,X
  bpl +
  ; if next char negative (null position), treat as space
    lda #passwordSpaceValue
  +:
  
  ; make up work
  phx
  
  ; load font char
  jsr loadPasswordFontCharRight
  
  ; make up work
  jmp $8A4E

.ends

.bank 1 slot 0
.section "new print 2" free
  newPasswordFont:
    .incbin "out/font/font_cafe.bin"
  
  ; A = char
  setUpPasswordFontSrcAddr:
    ; $22-23 = multiply by 8
    stz $23.b
    asl
    rol $23.b
    asl
    rol $23.b
    asl
    rol $23.b
    
    ; add font base
    clc
    adc #<newPasswordFont
    sta $22.b
    lda $23.b
    adc #>newPasswordFont
    sta $23.b
    rts
  
  ; A = char
  loadPasswordFontCharRight:
    jsr setUpPasswordFontSrcAddr
    
    ; copy top half
    cly
    clx
;    ldx #(passwordFontCharLineOffset*2)
    -:
      lda ($22.b),Y
      sta passwordFontChar1bppDst+1,X
;      stz passwordFontChar1bppDst+1,X
      
      inx
      inx
      iny
      cpy #8
      bne -
    
    rts
  
  ; A = char
  loadPasswordFontCharLeft:
    jsr setUpPasswordFontSrcAddr
    
    ; clear top 4 lines
    clx
/*    -:
      stz passwordFontChar1bppDst+0,X
      stz passwordFontChar1bppDst+1,X
      
      inx
      inx
      cpx #(passwordFontCharLineOffset*2)
      bne -*/
    
    ; copy top half
    cly
    -:
      lda ($22.b),Y
      sta passwordFontChar1bppDst+0,X
      stz passwordFontChar1bppDst+1,X
      
      inx
      inx
      iny
      cpy #8
      bne -
    
    ; clear remaining lines
    -:
      stz passwordFontChar1bppDst+0,X
      stz passwordFontChar1bppDst+1,X
      
      inx
      inx
;      iny
;      cpy #16
      cpx #32
      bne -
    
    rts
.ends

;=====
; position bottom window cursor correctly
;=====

.bank 0 slot 0
.orga $930B
.section "bottom window cursor pos 1" overwrite
  ; don't multiply target tile x by 2
;  asl
  nop
.ends

.bank 0 slot 0
.orga $9312
.section "bottom window cursor pos 2" overwrite
  jmp doExtraPasswordDisplayXOffset
.ends

.bank 0 slot 0
.section "bottom window cursor pos 3" free
  doExtraPasswordDisplayXOffset:
    clc
    adc #passwordDisplayExtraXOffset
    ; make up work
    sta $362E
    jmp $9315
.ends

;===================================
; no special diacritic handling,
;===================================

.bank 1 slot 0
.orga $8A9C
.section "no diacritics 1" overwrite
  jmp $8B2B
.ends

;===================================
; space->null remapping
;===================================

.bank 1 slot 0
.orga $8B54
.section "space to null remapping 1" overwrite
  jmp doSpaceNullRemapCheck
.ends

.bank 1 slot 0
.section "space to null remapping 2" free
  doSpaceNullRemapCheck:
    ; if input is space, remap to null.
    ; this allows trailing spaces to be ignored,
    ; and means that inputting all blanks is treated
    ; the same as inputting nothing.
    cmp #passwordSpaceValue
    bne +
      lda #passwordNullValue
    +:
    ; make up work
    sta nameEntryInputArray,X
    jmp $8B57
.ends

;===================================
; new "end" index
;===================================

;=====
; use new target index for "end" command (bank 0)
;=====

; checking what size to make cursor (double if on "end")
.bank 0 slot 0
.orga $92D7
.section "new end index bank0 1" overwrite
  cmp #passwordIndexEnd
.ends

;=====
; use new target index for "end" command (bank 1)
;=====

; checking if "end" option chosen
.bank 1 slot 0
.orga $8B43
.section "new end index bank1 1" overwrite
  cmp #passwordIndexEnd
.ends

; automatically choosing "end" if input buffer filled
.bank 1 slot 0
.orga $8B5F
.section "new end index bank1 2" overwrite
  lda #passwordIndexEnd
.ends

;===================================
; new "erase" index
;===================================

;=====
; use new target index for "erase" command (bank 1)
;=====

.bank 1 slot 0
.orga $8B2B
.section "new erase index bank1 1" overwrite
  cmp #passwordIndexErase
.ends

;===================================
; clean up extra memory for expanded password
; after validation complete
; (i don't think this is necessary, but might
; as well try to do this safely)
;===================================

.bank 0 slot 0
.orga $9690
.section "clean up extra memory 1" overwrite
  jmp doExtraMemCleanup
.ends

.bank 0 slot 0
.section "clean up extra memory 2" free
  doExtraMemCleanup:
    ; zero extra memory
    ; we have to clean up one extra position, as the game will actually
    ; write past the normal array end if a character is typed in
    ; while already at the end of the string
    .rept (newPasswordLen-oldPasswordLen)+1 INDEX count
      stz (nameEntryInputArray+oldPasswordLen+count).w
    .endr
    
    ; HACK: indices 9 and 10 of the password list, originally
    ; a spelling variation (that isn't needed in english),
    ; has been repurposed to allow an input of "THE BEAST"
    ; to be accepted the same as "BEAST".
    ; check if one of these indices was matched (output value is 10/11)
    ; and change output value to 2 if so, so scripts will treat them all identically
    lda $3AD6.w
    cmp #10
    beq @replace
    cmp #11
    bne +
    @replace:
      lda #2
      sta $3AD6.w
    +:
    
    ; make up work
    ply
    plx
    rts
.ends

;===================================
; raw cursor index->x/y mapping
;===================================

.bank 0 slot 0
.orga $9367
.section "cursor mapping 1" overwrite
  ; generate linear index mapping
  .rept passwordNumRows INDEX yCount
    .rept passwordCharsPerRow INDEX xCount
      ; x-pos has to be offset 2 patterns left for "end" option to align correctly
      .if ((yCount*passwordCharsPerRow)+xCount) == passwordIndexEnd
        ; X
        .db passwordCursorBaseTileX+(xCount*passwordCharsXSpacing)-2
        ; Y
        .db passwordCursorBaseTileY+(yCount*passwordCharsYSpacing)
      .else
        ; X
        .db passwordCursorBaseTileX+(xCount*passwordCharsXSpacing)
        ; Y
        .db passwordCursorBaseTileY+(yCount*passwordCharsYSpacing)
      .endif
    .endr
  .endr
.ends

;===================================
; cursor movement arrays
;===================================

.bank 0 slot 0
.orga $948B
.section "cursor move array: up 1" overwrite
  .rept passwordNumIndices INDEX pos
    .if pos < passwordCharsPerRow
      ; if on top row
      .db pos
    .else
      .db (pos-passwordCharsPerRow)
;      .if pos >= passwordIndexEnd
;        .db (pos-6)
;      .else
;        .db (pos-6)
;      .endif
    .endif
  .endr
.ends

.bank 0 slot 0
.orga $94CD
.section "cursor move array: down 1" overwrite
  .rept passwordNumIndices INDEX pos
    .if pos >= (passwordCharsPerRow*(passwordNumRows-1))
      ; if on bottom row
      .db pos
    .else
      .if (pos+passwordCharsPerRow) >= passwordNumIndices
        .db passwordIndexEnd
      .else
        .db (pos+passwordCharsPerRow)
      .endif
    .endif
  .endr
.ends

.bank 0 slot 0
.orga $950F
.section "cursor move array: left 1" overwrite
  .rept passwordNumIndices INDEX pos
    .if (pos#passwordCharsPerRow) == 0
      ; if on left column
      .db pos
    .else
      .db (pos-1)
    .endif
  .endr
.ends

.bank 0 slot 0
.orga $9551
.section "cursor move array: right 1" overwrite
  .rept passwordNumIndices INDEX pos
    .if (pos#(passwordCharsPerRow)) == (passwordCharsPerRow-1)
      ; if on right column
      .db pos
    .else
      .if (pos+1) >= passwordNumIndices
        .db passwordIndexEnd
      .else
        .db (pos+1)
      .endif
    .endif
  .endr
.ends



