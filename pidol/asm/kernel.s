
;.include "sys/pce_arch.s"
;.include "base/macros.s"

.include "include/global.inc"

/*.memorymap
   defaultslot     0
   ; ROM area
   slotsize        $2000
   slot            0       $0000
   slot            1       $2000
   slot            2       $4000
   slot            3       $6000
   slot            4       $8000
   slot            5       $A000
   slot            6       $C000
   slot            7       $E000
.endme */

; could someone please rewrite wla-dx to allow dynamic bank sizes?
; thanks
.memorymap
   defaultslot     0
   
   slotsize        $10000
   slot            0       $0000
.endme

;.rombankmap
;  bankstotal $2
;  
;  banksize $6000
;  banks $1
;  banksize $2000
;  banks $1
;.endro

.rombankmap
  bankstotal $4
  
  ; bank 0 = main area, 4000-8000
  ; bank 1 = gamescript module, 8000-A000
  ; bank 2 = extra area 1, 8000-A000
  ; bank 3 = extra area 2, 8000-A000
  banksize $10000
  banks $4
.endro

.emptyfill $FF

.background "kernel_asm.bin"

;===================================
; unbackgrounds
;===================================

; main area
; free space
.unbackground $0+$7F6A+$8 $0+$7FFF
; disused checkCharCompression and fetchNextScriptSeqOrSpace routines
.unbackground $0+$59CE $0+$5A29
; disused bit of stretched text font lookup routine
.unbackground $0+$66B1 $0+$66E6
; disused bits of old vertical stretch routines
.unbackground $65DE $65F9
.unbackground $6635 $665E
; old text compression data
.unbackground $0+$6EA7 $0+$6EC3
; extra font glyphs not in bios
;.unbackground $0+$785F $0+$78B8
; font decoding table
;.unbackground $0+$7A1B $0+$7A68
.unbackground $0+$785F $0+$7A68

; extra area 1
; free space
.unbackground $20000+$9D34+$10 $20000+$9FFF

; extra area 2
; free space
.unbackground $30000+$8000 $30000+$97FF
.unbackground $30000+$9E34+$10 $30000+$9FFF

;===================================
; new stuff
;===================================

.define stretchedTextCharWidth 8
.define charTopFillerRows 1

.define gamescr_newTextOp $FE

.define newAreaTextscrBaseBankOffset -2

.define freeArea1MemPage $6B
.define freeArea2MemPage $6C
; TODO
;.define advSceneExtraMemPageBase $78

.define expectedMpr3Value $69

;===================================
; old routines
;===================================

.define printNextChar $5924
.define outputFontChar $5A2A

.define updateAndSendCachePart $5E1B

.define incScriptPtr $6BB2

.define advance22ByYLinesInBat $7E8F
.define addYTo22InBat $7EBA
.define subYFrom22InBat $7ED0

;===================================
; old memory locations
;===================================

.define vregSelectB $6A

.define currentAreaBaseSectorH $2973
.define currentAreaBaseSectorL $2974
.define currentAreaBaseSectorM $2975

.define advModeOn $29CB

; buffer for 1bpp data of next glyph to be printed
.define nextChar1bppBuffer $2D4F
  .define nextChar1bppBufferSize 32

.define msgBoxTargetSlotAddr $31C0
.define msgBoxVisFlagsAddr $3380

.define boxBaseTileNum $3A65
  .define boxBaseTileNumLo boxBaseTileNum+0
  .define boxBaseTileNumHi boxBaseTileNum+1
.define scriptPtr $3A67
  .define scriptPtrLo scriptPtr+0
  .define scriptPtrHi scriptPtr+1
.define currentBoxBatAddr $3A69
  .define currentBoxBatAddrLo currentBoxBatAddr+0
  .define currentBoxBatAddrHi currentBoxBatAddr+1

.define autoSpacesLeft $3A6C
.define boxRowPatternSpacing $3A6D
  .define boxRowPatternSpacingLo boxRowPatternSpacing+0
  .define boxRowPatternSpacingHi boxRowPatternSpacing+1
.define currentBoxTileNum $3A6F
  .define currentBoxTileNumLo currentBoxTileNum+0
  .define currentBoxTileNumHi currentBoxTileNum+1

.define currentLineNum $3A71
; originally, this was simply a counter of the number of characters
; on the current line. it's now been repurposed to track the pixel x-position
; on the current line for VWF calculations.
.define currentCharX $3A73
.define boxBaseBatAddr $3A75
  .define boxBaseBatAddrLo boxBaseBatAddr+0
  .define boxBaseBatAddrHi boxBaseBatAddr+1
.define textColor $3A77
.define textShadowColor $3A7B
.define textScale $3A7C
.define forceInstaPrint $3A7F

.define currentScriptBaseBank $3A84

; the game engine has some sort of capability for managing multiple
; boxes of text simultaneously; this value is intended to be set
; to either 0x00 or 0x20 and then used as an index into a pair of
; consecutive 0x20-byte structs representing box state to allow for this.
; however, it appears that this feature is never actually used.
; presumably, it's recycled code from a previous game.
.define scriptIndex $3AE5

.define text4bppConvBuffer $3B19

.define scriptContinueFlag $3B79
.define textDelayCounter $3B7B
.define stretchedTextPrintState $3B7E

.define scriptActive $3B85
.define printedLineCharCountArray $3B86

; formerly "currentCharIsCompressed"; this was originally used to track
; whether the current character being printed was compressed so that
; the stretched-text print routines could determine how many bytes to
; rewind the script to get the same character to be printed multiple times
; as part of the printing process.
; we use it for the similar task of flagging whether DTE encoding is active
; or not.
;.define currentCharIsCompressed $3B89
.define dteSequenceActive $3B89

;===================================
; macros
;===================================

.macro doStdTrampolineCall ARGS dst
  jsr trampolineCallExtraArea2
    .dw dst
.endm

;==============================================================================
; 
;==============================================================================

.bank 0 slot 0
.section "trampoline call 1" free

  ; WARNING: not interrupt safe!
  ;          code that runs from interrupts should handle this separately
  trampolineCallExtraArea2:
    ; save A
    sta @restoreIncomingInstr+1.w
  
    ; fetch call addr from stack
    ; lo
    pla
    ; add 3 to get correct offset
;    clc
;    adc #3
    sta @loadInstruction+1.w
    ; hi
    pla
;    adc #0
    sta @loadInstruction+2.w
    
    phx
      ldx #1
      -:
        @loadInstruction:
        lda $0000.w,X
        sta @callInstruction.w,X
        
        inx
        cpx #3
        bne -
    plx
    
    ; load in target bank
    tma #$10
    pha
      lda #freeArea2MemPage
      tam #$10
        
        ; save return address in case the routine we call also
        ; needs to do a trampoline and overwrites it
        lda @loadInstruction+1.w
        pha
        lda @loadInstruction+2.w
        pha
          ; restore A to initial value
          @restoreIncomingInstr:
          lda #$00
          ; call target routine
          @callInstruction:
          jsr $0000
          ; save return value
          sta @restoreRetInstr+1.w
        pla
        sta @loadInstruction+2.w
        pla
        sta @loadInstruction+1.w
    pla
    tam #$10
    
    ; advance return address past pointer
    inc @loadInstruction+1.w
    bne +
      inc @loadInstruction+2.w
    +:
    inc @loadInstruction+1.w
    bne +
      inc @loadInstruction+2.w
    +:
    
    ; push return address to stack
    lda @loadInstruction+2.w
    pha
    lda @loadInstruction+1.w
    pha
    
    ; restore return value
    @restoreRetInstr:
    lda #$00
    rts
    
    @temp:
      .db $00
    
.ends

;==============================================================================
; new base area for new textscripts
;==============================================================================

; this approach doesn't work -- textscripts with no text content are
; deliberately ignored when dumping the script, and so have not
; had their pointers updated to the format for the new scripts.
; this is fine for adv blocks, but breaks area blocks.
; so instead, the modified pointers have also had their opcode modified
; to a new value which we can check for.
/*.bank 1 slot 0
.orga $8EF2
.section "new base bank for area textscripts 1" overwrite
  ; compute area textscript offsets from the start of the area block,
  ; not from two banks in, so we can use unused parts of those first
  ; two banks for additional text storage
;  lda #$0A
  lda #$08
.ends*/

.bank 1 slot 0
.orga $8387
.section "new base bank for area textscripts 1" overwrite
  jmp doNewGamescrOpCheck
.ends

.bank 0 slot 0
.section "new base bank for area textscripts 2" free
  doNewGamescrOpCheck:
    ; check for new ops
    cmp #gamescr_newTextOp
    bne +
      ldy #$01
      bra handleGamescrNewTextOp
    +:
    ; make up work
    asl
    rol $19.b
    jmp $838A
  
  handleGamescrNewTextOp:
    ; check if script already active (i.e. bank adjustment already made)
    lda scriptActive.w
    beq +
      ; run corresponding part of handler
      jmp $8F14
    +:
    
    ; run normal op 3E handler
    jsr $8ED5
    ; preserve return value
    pha
      ; move base bank back if not in adv mode
      lda advModeOn.w
      bne +
        lda currentScriptBaseBank.w
        clc
        adc #newAreaTextscrBaseBankOffset
        sta currentScriptBaseBank.w
      +:
    pla
    @done:
    rts
.ends

;==============================================================================
; new printing
;==============================================================================

;===================================
; don't write to the former
; currentCharIsCompressed variable,
; which we have repurposed as
; dteSequenceActive
;===================================

; rolled into another fix
;.bank 0 slot 0
;.orga $57EC
;.section "no currentCharIsCompressed 1" overwrite
;  nop
;  nop
;  nop
;.ends

;.bank 0 slot 0
;.orga $59F2
;.section "no currentCharIsCompressed 2" overwrite
;  nop
;  nop
;  nop
;.ends

;===================================
; no auto linebreaks
;===================================

; this is checked in two different places and handled in
; two different ways...not sure if both are actually used

.bank 0 slot 0
.orga $5950
.section "no auto linebreak 1" overwrite
  jmp $596F
.ends

.bank 0 slot 0
.orga $5C1E
.section "no auto linebreak 2" overwrite
  jmp $5C65
.ends

;===================================
; advance script pointer correctly
;===================================

; regular printing
; (now rolled into other hacks)
;.bank 0 slot 0
;.orga $5B4F
;.section "advance script ptr 1" overwrite
;  doStdTrampolineCall advanceScriptPtrToNextChar
;  jmp $5B60
;.ends

;===================================
; handle DTE sequences
;===================================

; regular printing
.bank 0 slot 0
.orga $596F
.section "new std text lookup 1" overwrite
;  jsr peekNextScriptChar
  doStdTrampolineCall peekNextScriptChar
  jmp $59A5
.ends

;===================================
; supplemental dte and font stuff
;===================================

.bank 0 slot 0
.section "new text lookup 1" free
/*  peekNextScriptChar:
    stz nextScriptCharIsDte.w
    lda ($2012)
    bmi @notDte
      inc nextScriptCharIsDte.w
      doStdTrampolineCall doDteLookup
    @notDte:
    sta $10.b
    rts*/
  
  nextScriptCharIsDte:
    .db $00
  
  ; width e.g. to advance drawing position per char output iteration
  ; normally this is the character's true width, but may be
  ; overriden in some circumstances (auto-spaces, stretched printing)
  currentCharWidth:
    .db $00
  
  ; actual raw width of current glyph (used for stretched printing)
  currentCharRawGlyphWidth:
    .db $00
.ends

.bank 3 slot 0
.section "new text lookup 2" free
  ; $12 = current script pointer
  ; sets:
  ; - $10 to the new target character
  ;   (accounting for DTE if needed)
  ; - nextScriptCharIsDte as appropriate
  peekNextScriptChar:
    ; if spaces mode on, act as though next char is a space
    lda autoSpacesLeft.w
    beq +
      lda #code_space
      bra @notDte
    +:
    
    stz nextScriptCharIsDte.w
    lda ($12.b)
    bpl @notDte
      inc nextScriptCharIsDte.w
      jsr doDteLookup
    @notDte:
    sta $10.b
    rts
  
  ; advances script ptr to next character (accounting for DTE sequences).
  ; !! must be preceded by a call to peekNextScriptChar!
  ;    this depends on the state of nextScriptCharIsDte
  advanceScriptPtrToNextChar:
    lda nextScriptCharIsDte.w
    bne +
    @incAndDone:
      inc scriptPtr+0.w
      bne ++
        inc scriptPtr+1.w
      ++:
      rts
    +:
    
    lda #$01
    eor dteSequenceActive.w
    sta dteSequenceActive.w
    ; if we were previously on the second character of a DTE sequence,
    ; increment script pointer; otherwise, leave it where it is
    beq @incAndDone
    rts
  
  ; undoes the effect of the most recent call to advanceScriptPtrToNextChar.
  ; !! must be preceded by a call to advanceScriptPtrToNextChar,
  ;    and come before before next call to peekNextScriptChar!
  rewindScriptPtrToPrevChar:
    ; check whether last char was dte
    lda nextScriptCharIsDte.w
    bne +
    @decAndDone:
    ; if not, move script pointer back
      lda scriptPtr+0.w
      dec scriptPtr+0.w
      cmp #$00
      bne ++
        dec scriptPtr+1.w
      ++:
      rts
    +:
    
    lda #$01
    eor dteSequenceActive.w
    sta dteSequenceActive.w
    ; if we are now on the second character of a DTE sequence,
    ; decrement script pointer; otherwise, leave it where it is
    bne @decAndDone
    rts
    
  ; A = raw DTE code (0x80-based)
  ; returns A = corresponding character based on state of dteSequenceActive
  ;             (first character if zero, second character otherwise)
  ; trashes X
  doDteLookup:
    ; convert raw DTE code to array index
;    sec
;    sbc #$80
    asl
    tax
    
    ; if dte sequence active, target second character of pair
    lda dteSequenceActive
    beq +
      inx
    +:
    
    lda dteTable.w,X
    rts
  
  dteTable:
    .incbin "out/script/script_dictionary.bin"
.ends

;===================================
; do bold font op check
;===================================

.bank 0 slot 0
.orga $57E9
.section "font emph toggle 1" overwrite
  jmp doFontEmphToggleCheck
.ends

.bank 0 slot 0
.section "font emph toggle 2" free
  doFontEmphToggleCheck:
    cmp #fontEmphToggleOp
    beq +
      ; make up work
      jsr printNextChar
      jmp $57EC
    +:
    doStdTrampolineCall doFontEmphToggleCheck_ext
    jmp $57EF
  
  fontEmphOn:
    .db $00
.ends

.bank 3 slot 0
.section "font emph toggle 3" free
  doFontEmphToggleCheck_ext:
    ; toggle emph flag
    lda fontEmphOn.w
    eor #$FF
    sta fontEmphOn.w
    
    ; if textShadowColor == 0x0E (standard 4/4/4 light gray shadow),
    ; change it to 0x0D (which is one shade darker, 3/3/3),
    ; and vice versa.
    ; the normal font is fine with the brighter shade, but the bold one
    ; is hard to read.
    ldx scriptIndex
    lda textShadowColor.w,X
    cmp #$0E
    bne +
      dec textShadowColor.w,X
      bra @shadowSetDone
    +:
    cmp #$0D
    bne @shadowSetDone
      inc textShadowColor.w,X
    @shadowSetDone:
    
    ; advance script
    inc scriptPtrLo.w
    bne +
      inc scriptPtrHi.w
    +:
    
    ; set script continue flag
    lda #$01
    sta scriptContinueFlag.w
    rts
.ends

;===================================
; font lookup
;===================================

.bank 0 slot 0
.section "new font char lookup 1" free
  getFontChar:
    doStdTrampolineCall fetchNextFontChar
    rts
  
  getFontChar_stretchedMode:
    bsr getFontChar
    ; override width with hardcoded monospace
    lda #stretchedTextCharWidth
    sta currentCharWidth.w
;    asl currentCharWidth.w
    rts
.ends

.bank 3 slot 0
.section "new font char lookup 2" free
  ; $10 = next font raw glyph index (0x20-based)
  ; sets:
  ; - nextChar1bppBuffer to 1bpp data of target glyph
  ; - currentCharWidth to pixel width of target glyph
  ; trashes $10-11
  fetchNextFontChar:
    ; convert raw glyph index to table offset
    lda $10.b
    sta @emphSpCheckInstr+1.w
    sec
    sbc #fontBaseOffset
;    sta $10.b
    tay
    
    ;=====
    ; multiply font table offset by 10 to get src offset in font data
    ;=====
    
    ; multiply by 2, saving result separately for future use
    asl
    sta @fontFinalAdd1+1.w
    ; the input will not be greater than 0x80, so the high byte
    ; from multiplying by 2 will always be zero; we don't need to
    ; bother explicitly computing it here
;    lda $11.b
;    rol
;    sta @fontFinalAdd2+1.w
    stz $11.b
    
    ; shift left twice to get (raw * 8)
    asl
    rol $11.b
    asl
    rol $11.b
    
    ; add base pointer for font data
    clc
    adc #<fontStd
    sta $10.b
    lda $11.b
    adc #>fontStd
    sta $11.b
    
    ; add (raw * 2) to (raw * 8) to get (raw * 10)
    @fontFinalAdd1:
    lda #$00
    clc
    adc $10.b
    sta $10.b
    
;    @fontFinalAdd2:
;    lda #$00
    cla
    adc $11.b
    sta $11.b
    
    ; if font emph on, move to alt font
    lda fontEmphOn.w
    beq +
      lda #<(ovlScene_font-fontStd)
      clc
      adc $10.b
      sta $10.b
      lda #>(ovlScene_font-fontStd)
      adc $11.b
      sta $11.b
    +:
    
    ;=====
    ; look up width
    ;=====
    
    ; if auto-space mode on, do not get width from table;
    ; it is overriden with the needed value before this routine is called
    lda autoSpacesLeft.w
    bne @noWidthLookup
      ; if font emph on, use alt font table
      lda fontEmphOn.w
      beq +
      ; also use standard width for spaces
      @emphSpCheckInstr:
      lda #$00
      cmp #code_space
      beq +
        lda ovlScene_fontWidthTable.w,Y
        bra ++
      +:
        lda fontWidthStd.w,Y
      ++:
      
      sta currentCharWidth.w
      sta currentCharRawGlyphWidth.w
    @noWidthLookup:
    
    ;=====
    ; copy character data to dst buffer
    ;=====
    
    ; $15-16 = dst buffer pointer
;    lda #<nextChar1bppBuffer+2
;    sta $15.b
;    lda #>nextChar1bppBuffer+2
;    sta $16.b
    
/*    clx
    cly
    -:
      ; copy left part
      lda ($10.b),Y
      sta nextChar1bppBuffer+2.w,X
      inx
      
      ; blank right part
      stz nextChar1bppBuffer+2.w,X
      inx
      
      iny
      cpy #bytesPerRawFontChar
      bne -
    
    ; blank last 5 rows of buffer
    -:
      stz nextChar1bppBuffer+2.w,X
      inx
      cpx #nextChar1bppBufferSize-2
      bne -

    ; blank first row of buffer
    stz nextChar1bppBuffer+0.w
    stz nextChar1bppBuffer+1.w*/
    
    ; offset data by 1 row from top of pattern under normal conditions.
    ; if in four-line box mode and on an odd-numbered line,
    ; offset by 5 rows to allow for compositing with the line above.
    lda #(charTopFillerRows*2)
    sta @cpxInstr+1.w
    lda fourLineBoxOn.w
    beq +
      ldx scriptIndex.w
      lda currentLineNum.w,X
      lsr
      bcc +
      @do5RowOffset:
        lda #((charTopFillerRows+4)*2)
        sta @cpxInstr+1.w
      bra @addFillerRows
    +:
    
    ; if in insta-print mode, offset 2 rows so that the 3-line
    ; menus and signs are more vertically centered in the box
    lda forceInstaPrint.w
    beq +
      lda no3RowOffset.w
      bne +
      @do3RowOffset:
        lda #((charTopFillerRows+2)*2)
        sta @cpxInstr+1.w
    +:
    
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
      lda ($10.b),Y
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
    
    
    rts
  
  fontStd:
    .incbin "out/font/font.bin"
  
  ; HACK: skip characters beyond $60, which are not needed here
  ovlScene_font:
    .incbin "out/font/font_scene.bin" READ $320
  
  fontWidthStd:
    .incbin "out/font/fontwidth.bin"
  
  ovlScene_fontWidthTable:
    .incbin "out/font/fontwidth_scene.bin"
.ends

;.bank 0 slot 0
;.orga $78B9
;.section "new font char lookup 1" overwrite SIZE 6
;  doStdTrampolineCall fetchNextFontChar
;  rts
;.ends

;.bank 0 slot 0
;.orga $78B9
;.section "new font char lookup replace 1" overwrite
;  jmp getFontChar
;.ends

;===================================
; use new font lookup
;===================================

; standard printing
.bank 0 slot 0
.orga $59A5
.section "use new font char lookup 1" overwrite
  jsr getFontChar
.ends

;===================================
; compute currentCharX in pixels
; rather than characters
;===================================

; non-stretched printing
.bank 0 slot 0
.orga $5B86
.section "currentCharX as pixels 1" overwrite
;  jsr addCurrentCharWidthToCurrentX
  ; do not update in middle of routine
  ; (we still need to reference the original value)
  nop
  nop
  nop
.ends

.bank 0 slot 0
.orga $5A2A
.section "currentCharX as pixels 2" overwrite
  jmp outputFontChar_newStart
.ends

;.bank 0 slot 0
;.orga $5CF7
;.section "currentCharX as pixels 3" overwrite
;  jmp outputFontChar_newEnd
;.ends

.bank 0 slot 0
.section "currentCharX as pixels 4" free
;  addStretchSpacingToCurrentX:
;    ; TODO: is this the value we want?
;    lda #8
;    bra addCurrentCharWidthToCurrentX@altEntry
    
  addCurrentCharWidthToCurrentX:
    lda currentCharWidth.w
    @altEntry:
    clc
    adc currentCharX.w,X
    sta currentCharX.w,X
    rts
  
  outputFontChar_newStart:
    stz mainPatternSkipOn.w
    ; make up work
    tma #$20
    pha
    jmp $5A2D
  
;  outputFontChar_newEnd:
;    ldx scriptIndex
;    bsr addCurrentCharWidthToCurrentX
;    ; make up work
;    pla
;    tam #$20
;    rts
  
  standardPrint_extraOutputFontChar:
    ; make up work
    jsr outputFontChar
    
    ; flag left-cache clear as no longer needed
    stz leftCacheClearNeeded.w
    ; add x-pos to current char x
    bra addCurrentCharWidthToCurrentX
.ends

.bank 0 slot 0
.orga $59A8
.section "currentCharX as pixels 5" overwrite
  jsr standardPrint_extraOutputFontChar
.ends

;===================================
; correctly compute char left shift
; based on currentCharX
;===================================

.bank 0 slot 0
.orga $5A3F
.section "correct char left shift 1" overwrite
  jmp computeCharLeftShift
.ends

.bank 0 slot 0
.section "correct char left shift 2" free
  computeCharLeftShift:
    ; currently, A = raw currentCharX (which is nonzero)
    
    ; if (currentCharX % 8) == 0, no shift needed
    and #$07
    bne +
;      jmp $5A94
      ; TODO: any special stretched-text handling?
      
      ; skip some now-irrelevant position correction code
      jmp $5ACD
    +:
    
    ; compute (8 - (currentCharX % 8))
    ; this is the needed leftward shift
    sta @subInstr+1.w
    lda #8
    sec
    @subInstr:
    sbc #$00
    
    ; save result and jump to normal shift logic
    sta $10.b
;    jmp $5A49
    ; skip some now-irrelevant stretched text code
    jmp $5A59
.ends

;===================================
; correctly advance target pattern
; for vwf
;===================================

.bank 0 slot 0
.orga $5B39
.section "correct target char pattern update 1" SIZE $40 overwrite
  
  doStdTrampolineCall doCharPrintAdvanceChecks

;  doStdTrampolineCall canMainCharPatternBeSkipped
  ; check return value to see if main printing can be skipped
  and #$FF
  beq +
    ; skip
    inc mainPatternSkipOn.w
;    jmp $5C70
  +:
  ; resume normal logic
  jmp $5B81
  
  mainPatternSkipOn:
    .db $00
  
/*  ; advance to next char
  ; TODO: will probably change usage of auto spaces in the future
  lda autoSpacesLeft.w,X
  bne +
    doStdTrampolineCall advanceScriptPtrToNextChar
  +:
  
  ; if (currentCharX/8) != (nextCharX/8),
  ; and (nextCharX % 8) != 0,
  ; advance a pattern
  lda currentCharX.w
  pha
    clc
    adc currentCharWidth.w
    sta temp_nextCharX.w
    lsr
    lsr
    lsr
    sta @cmpInstr+1.w
  pla
;  lsr
;  lsr
;  lsr
  
  ; if ((currentCharX % 8) == 0),
  ; advance a pattern
  and #$07
  beq @advance
  
  lda currentCharX.w
  lsr
  lsr
  lsr
  @cmpInstr:
  cmp #$00
  beq @noAdvance
  lda temp_nextCharX.w
  and #$07
  beq @noAdvance
  ; TODO: exception needed for stretched text?
  @advance:
    doStdTrampolineCall advanceCharTarget1Pattern
  @noAdvance:

;  lda currentCharX.w
;  and #$07
;  beq +
  doStdTrampolineCall canMainCharPatternBeSkipped
  and #$FF
  beq +
    ; skip
    jmp $5C70
  +:
  ; resume normal logic
  jmp $5B79
  
  temp_nextCharX:
  .db $00*/
.ends

.bank 3 slot 0
.section "correct target char pattern update 2" free
  canMainCharPatternBeSkipped:
    ; if currentCharX is not pattern-aligned,
    ; and (((nextCharX + 7)/8) - (currentCharX/8)) < 2,
    ; then the target character will not enter the main pattern transfer
    ; area and that step should be skipped
    
;    ldx scriptIndex
    lda currentCharX.w,X
    and #$07
    beq @no
    
    lda currentCharX.w,X
    lsr
    lsr
    lsr
    sta @sbcInstr+1.w
    
    lda temp_nextCharX.w
    clc
    adc #7
    lsr
    lsr
    lsr
    
    sec
    @sbcInstr:
    sbc #$00
    cmp #2
    bcs @no
    @yes:
      lda #$FF
      rts
    @no:
      lda #$00
      rts
  
  advanceCharTarget1Pattern:
    ; tile data
    lda currentBoxTileNumLo.w,X
    clc 
;    adc #$20
    adc #$10
    sta currentBoxTileNumLo.w,X
    lda currentBoxTileNumHi.w,X
    adc #$00
    sta currentBoxTileNumHi.w,X
    
    ; bat position
    lda currentBoxBatAddrLo.w,X
    sta $0022
    lda currentBoxBatAddrHi.w,X
    sta $0023
    ldy #$01
    jsr addYTo22InBat
    lda $0022
    sta currentBoxBatAddrLo.w,X
    lda $0023
    sta currentBoxBatAddrHi.w,X
    
    rts
  
  doCharPrintAdvanceChecks:
    ; advance to next char if not printing auto-spaces
    lda autoSpacesLeft.w,X
    bne +
      jsr advanceScriptPtrToNextChar
    +:
    
    jsr advanceCharPatternIfNeeded
    
    ; copy tile num?? to $22.
    ; this needs to happen unconditionally
    lda $0024
    sta $0022
    lda $0025
    sta $0023
    
    ; return result
    jmp canMainCharPatternBeSkipped
    
  advanceCharPatternIfNeeded:
    ; do not advance a pattern if doing stretched text printing
;    lda textScale.w,X
;    bne @noAdvance

    ; if (currentCharX/8) != (nextCharX/8),
    ; and (nextCharX % 8) != 0,
    ; advance a pattern
    lda currentCharX.w,X
    pha
      clc
      adc currentCharWidth.w
      sta temp_nextCharX.w
      lsr
      lsr
      lsr
      sta @cmpInstr+1.w
  
      ; HACK: if currentCharWidth > 8, advance one pattern,
      ; and if we're at a pattern boundary, advance another one.
      ; (font symbols are only up to 8 pixels wide, but a few of them have
      ; an advance width of 9 or possibly more; this will allow widths
      ; of up to 15 to be handled correctly)
      lda currentCharWidth.w
      cmp #9
      bcc +
        lda currentCharX.w,X
        and #$07
        bne ++
          jsr advanceCharTarget1Pattern
        ++:
        pla
        jmp @advance
      +:
    pla
  ;  lsr
  ;  lsr
  ;  lsr
  
/*    lda currentCharWidth.w
    cmp #9
    bcc +
      ; if at a pattern boundary, advance twice
      lda currentCharX.w,X
      and #$07
      bne ++
        jsr advanceCharTarget1Pattern
      ++:
      bra @advance
    +:*/
    
    ; if ((currentCharX % 8) == 0),
    ; advance a pattern
    and #$07
    beq @advance
    
    lda currentCharX.w,X
    lsr
    lsr
    lsr
    @cmpInstr:
    cmp #$00
    beq @noAdvance
    lda temp_nextCharX.w
    and #$07
    beq @noAdvance
    ; TODO: exception needed for stretched text?
    @advance:
      jsr advanceCharTarget1Pattern
    @noAdvance:
    rts
    
    temp_nextCharX:
    .db $00
.ends

;===================================
; reduce width of transferred main
; pattern data for each char from
; 16 pixels to 8
; (unless char width > 8 and at pattern boundary)
;===================================

/*; UR pattern
.bank 0 slot 0
.orga $5BC5
.section "reduced-width main char data transfers 1" overwrite
  ; jump past the normal transfer call
;  jmp $5C14
  jmp $5C17
.ends

; LR pattern
.bank 0 slot 0
.orga $5BE9
.section "reduced-width main char data transfers 2" overwrite
  ; jump past the normal transfer call
;  jmp $5C14
  jmp $5C17
.ends*/

; UR pattern
.bank 0 slot 0
.orga $5BC5
.section "reduced-width main char data transfers 1" overwrite
  jmp doDoubleWidthPrintCheck
.ends

; LR pattern
.bank 0 slot 0
.orga $5BE9
.section "reduced-width main char data transfers 2" overwrite
  jmp doDoubleWidthPrintCheck
.ends

.bank 0 slot 0
.section "reduced-width main char data transfers 3" free
  doDoubleWidthPrintCheck:
    lda currentCharWidth.w
    cmp #9
    bcc +
      lda currentCharX.w,X
      and #$07
      bne +
        jmp $5C14
    +:
    ; do nothing
    jmp $5C17
.ends

;===================================
; skip main char pattern transfer
; if not needed
;===================================

.bank 0 slot 0
.orga $5C14
.section "skip main char transfer if not needed 1" overwrite
  jsr checkForMainCharTransferSkip
.ends

.bank 0 slot 0
.section "skip main char transfer if not needed 2" free
  checkForMainCharTransferSkip:
    lda mainPatternSkipOn.w
    bne +
    ; if transfer not being skipped
      ; decide whether to composite new text with cache for previous 12px line
      ; or overwrite it
      stz charPatternSendCacheCompositeOn.w
      
      ; ignore for stretched text
      lda textScale.w,X
      bne @done
      
      ; if current state >= 2 (i.e. targeting lower pattern),
      ; don't enable composite mode.
      ; otherwise, run normal checks
      lda $1A.b
      cmp #2
      bcs @done
        ; check if current line x <= previous line's length
        ; (cache is not cleared between boxes, and we don't want to
        ; pick up garbage from the preceding line of the previous box)
        ldx currentRealLinebreakLineNum.w
;        cmp printedLineCharCountArray-1.w,X
        lda printedLineCharCountArray-1.w,X
        clc
        adc #7
        and #$F8
        sta @cmpInstr+1.w
        
        lda currentCharWidth.w
        cmp #9
        bcc @noWideTransfer
        ; if character width > 8, do additional checks to ensure
        ; correct behavior for case where we are pattern-aligned
        ; and overlapping the end of the previous line
          ; if state == 0 (UL), cap width at 8;
          ; otherwise, use real value
          lda $1A.b
          beq @firstPartOfWideTransfer
            lda currentCharWidth.w
            bra @noWideTransfer
          @firstPartOfWideTransfer:
          lda #8
        @noWideTransfer:
        clc
        adc currentCharX.w
        @cmpInstr:
        cmp #$00
        
        beq @success
        bcs @done
        @success:
          jsr setCharPatternSendCacheCompositeState
      ; make up work
      @done:
      jmp $5CFB
    +:
    rts
  
  setCharPatternSendCacheCompositeState:
    ; enable composite if in four-line box mode and on odd-numbered line
    phx
      lda fourLineBoxOn.w
      beq @done
        ldx scriptIndex.w
        lda currentLineNum.w,X
        lsr
        bcc @done
          inc charPatternSendCacheCompositeOn.w
    @done:
    plx
    rts
    
.ends

;===================================
; four-line box composite check for
; sub area of char transfer
;===================================

.bank 0 slot 0
.orga $5CC5
.section "char sub area four-line composite check 1" overwrite
  jsr checkForSubCharTransferComposite
.ends

.bank 0 slot 0
.section "char sub area four-line composite check 2" free
  checkForSubCharTransferComposite:
    stz charPatternSendCacheCompositeOn.w
    
    ; don't composite if generating stretched text
    lda textScale.w,X
    bne @done
      ; check state
      lda $1A.b
      ; 0 = lower tile, 1 = upper
      beq @done
        jsr setCharPatternSendCacheCompositeState
    @done:
    ; make up work
    jmp updateAndSendCachePart
.ends

;===================================
; compute number of patterns per line
; correctly in insta-print mode
;===================================

.bank 0 slot 0
.orga $6923
.section "correct insta-print line length 1" overwrite
  ; compute (pixelWidth + 7) / 8 to get pattern count
  clc
  adc #7
  lsr
  lsr
  lsr
  sta $12.b
  jmp $693B
.ends

;==============================================================================
; new auto-space mode
;==============================================================================

; rather than generate a specified number of spaces
; as the original game does, our goal is to fill
; the current line to a specified X-position using spaces
; - if the target position is 0xFF, space to the next 8-pixel boundary
;   (needed for stretched-text modes)

.bank 0 slot 0
.orga $6A06
.section "new auto-space 1" SIZE $1B overwrite
  doStdTrampolineCall handleNextAutoSpace
  rts
  
  finishAutoSpaceInit:
    doStdTrampolineCall finishAutoSpaceInit_ext
    jmp $69D8
.ends

.bank 0 slot 0
.orga $6A00
.section "new auto-space 2" overwrite
  ; don't immediately call printNextChar
  jmp finishAutoSpaceInit
.ends

.bank 3 slot 0
.section "new auto-space 3" free
;  finishAutoSpaceInit:
  finishAutoSpaceInit_ext:
    lda autoSpacesLeft
    
    ; if autoSpacesLeft == 0xFF, width is whatever we need to reach
    ; the next pattern boundary
    cmp #$FF
    bne +
      ; if already pattern-aligned, do nothing
      lda currentCharX.w,X
      and #$07
      bne @alignNeeded
        stz autoSpacesLeft.w,X
        bra @done
      @alignNeeded:
      
      sta @sbcInstr+1.w
      
      lda #8
      sec
      @sbcInstr:
      sbc #$00
      
      @nextPatCompDone:
      sta autoSpacesLeft.w
      bra @done
    +:
    
    ; compute target width
    lda autoSpacesLeft.w,X
    sec
    sbc currentCharX.w,X
    bcs @noOverflow
      cla
    @noOverflow:
    
    sta autoSpacesLeft.w,X
    
    @done:
    rts
.ends

.bank 3 slot 0
.section "new auto-space 4" free
  handleNextAutoSpace:
    ; A = autoSpacesLeft (which is initialized and nonzero)
    
    ; advance to next pattern boundary if not there
    ; (being pattern-aligned speeds up printing)
    lda currentCharX.w
    and #$07
    beq +
      ; compute pixels needed to get pattern alignment
      sta @sbcInstr+1.w
      
      lda #8
      sec
      @sbcInstr:
      sbc #$00
      
      ; if <= remaining width, print that amount
      cmp autoSpacesLeft.w,X
      bcc @doTransfer
      beq @doTransfer
    +:
    
    ; print up to 8 pixels
    lda autoSpacesLeft.w,X
    beq @done
    cmp #9
    bcc +
      lda #8
    +:
    
    @doTransfer:
    ; print space of target width
    sta currentCharWidth.w
    stz textDelayCounter.w
    jsr printNextChar
    
    ; autoSpacesLeft.w -= width
    ldx scriptIndex
    lda autoSpacesLeft.w,X
    sec
    sbc currentCharWidth.w
    sta autoSpacesLeft.w,X
    bne @notDone
    @done:
      ; if everything printed, finish up
      jsr incScriptPtr
      jsr incScriptPtr
      lda #$01
      sta scriptContinueFlag.w
    @notDone:
    rts
.ends

;==============================================================================
; stretched text
;==============================================================================

/*; stretched printing (monospace)
.bank 0 slot 0
.orga $67DC
.section "currentCharX as pixels stretched 1" overwrite
  ; finish up after printing done
  jsr addStretchSpacingToCurrentX
  nop
  nop
  nop
;  doStdTrampolineCall updateXAfterStretchPrint
;  nop
.ends*/

/*.bank 3 slot 0
.section "currentCharX as pixels stretched 2" free
  updateXAfterStretchPrint:
    ; advance by a pattern
;    jsr advanceCharTarget1Pattern
    ; update x position accordingly
    jmp addStretchSpacingToCurrentX
.ends */

.bank 0 slot 0
.orga $6769
.section "stretched printing 1" overwrite
  ; after finishing line, move tile pos back 2 tiles, not 4
;  sbc #$40
  sbc #$20
.ends

.bank 0 slot 0
.orga $6780
.section "stretched printing 2" overwrite
  ; after finishing line, move bat position back 2 tiles, not 4
;  ldy #$04
  ldy #$02
.ends

; stretched printing (when done with all iterations of target character)
.bank 0 slot 0
.orga $67CE
.section "stretched printing 3" SIZE $14 overwrite
  ; advance script pointer to next character
  doStdTrampolineCall advanceScriptPtrToNextChar
  ; advance currentCharX
;  jsr addStretchSpacingToCurrentX
  jmp $67E2
.ends

; more of above
.bank 0 slot 0
.orga $6823
.section "stretched printing 4" overwrite
  jsr doStretchPrintEnd_extraEnd
.ends

.bank 0 slot 0
.section "stretched printing 5" free
  doStretchPrintEnd_extraEnd:
    ; make up work
    dec $3AF8.w
    
    doStdTrampolineCall updateCharPosAfterStretchText
    rts
.ends

.bank 3 slot 0
.section "stretched printing 6" free
  updateCharPosAfterStretchText:
    ; move back 2 tiles (the amount advanced while printing)
    lda currentBoxTileNumLo.w,X
    sec 
    sbc #$20
    sta currentBoxTileNumLo.w,X
    lda currentBoxTileNumHi.w,X
    sbc #$00
    sta currentBoxTileNumHi.w,X
    ; target bat position -= 2 tiles
    lda currentBoxBatAddrLo.w,X
    sta $22.b
    lda currentBoxBatAddrHi.w,X
    sta $23.b
    ldy #$02
    jsr subYFrom22InBat
    lda $22.b
    sta currentBoxBatAddrLo.w,X
    lda $23.b
    sta currentBoxBatAddrHi.w,X
    
    ; set currentCharWidth to true value
    ; and advance by that amount twice
    lda currentCharRawGlyphWidth.w
    sta currentCharWidth.w
    
    jsr advanceCharPatternIfNeeded
    lda temp_nextCharX.w
    sta currentCharX.w
    
    ; NOTE: the game's double-width algorithm results in an extra
    ; pixel of space on the right side compared to non-stretched text;
    ; uncomment this line to make it flush instead
;    dec currentCharWidth.w

    jsr advanceCharPatternIfNeeded
    lda temp_nextCharX.w
    sta currentCharX.w
    
    ; HACK: if currentCharRawGlyphWidth == 9,
    ; and (currentCharX % 8) == 1 or 2,
    ; then the next character print on the line needs
    ; to clear the cache for its left-side area rather than
    ; compositing with it.
    ; this is because the double-width send only covers a 16-pixel area
    ; in width.
    and #$07
    cmp #1
    beq +
    cmp #2
    bne @done
    +:
      lda currentCharRawGlyphWidth.w
      cmp #9
      bne @done
        lda #$FF
        sta leftCacheClearNeeded.w
    @done:
    rts
.ends

.bank 0 slot 0
.section "stretched printing 7" free
  leftCacheClearNeeded:
    .db $00
.ends

;===================================
; stretched printing font lookup
;===================================

; new font lookup
.bank 0 slot 0
.orga $66E7
.section "stretched printing new font lookup 1" overwrite
  jsr getFontChar_stretchedMode
.ends

;===================================
; stretched printing script pointer rewind
;===================================

.bank 0 slot 0
.orga $67B1
.section "rewind script ptr stretched printing 1" overwrite
  doStdTrampolineCall rewindScriptPtrToPrevChar
  jmp $67C2
.ends

;===================================
; stretched printing dte
;===================================

.bank 0 slot 0
.orga $66A9
.section "new std text lookup stretched 1" SIZE 8 overwrite
  doStdTrampolineCall peekNextScriptChar
  jmp $66E7
.ends

;===================================
; correctly send right half of data
;===================================

; double mode
.bank 0 slot 0
.orga $65D0
.section "stretched text double width send 1" overwrite
;  ldx $6E8B,Y
  ldx newStretchTargetTable_double.w,Y
.ends

; triple mode
.bank 0 slot 0
.orga $6627
.section "stretched text double width send 2" overwrite
;  ldx $6E8F,Y
  ldx newStretchTargetTable_triple.w,Y
.ends

.bank 0 slot 0
.section "stretched text double width send 3" free
  newStretchTargetTable_double:
;    .db $00,$01
;    .db $10,$11
    ; ignore right half of input data (which is empty, as all characters
    ; are no more than 8px wide) and instead target the left half twice
;    .db $00,$00
;    .db $10,$10
    ; furthermore, separate source rows by 6px rather than 8px
    ; to fit the new vertical stretch algorithm used by the translation
    .db $00,$00
    .db $0A,$0A
    
  newStretchTargetTable_triple:
;    .db $00,$01
;    .db $0A,$0B
;    .db $14,$15
    ; ignore right half
;    .db $00,$00
;    .db $0A,$0A
;    .db $14,$14
    ; furthermore, separate by 4px to suit new algorithm
    .db $00,$00
    .db $08,$08
    .db $10,$10
  
  swapStretchConvIfNeeded:
    lda stretchedTextPrintState.w
    lsr
    lda $6E96.w,X
    bcs @swap
    @noSwap:
      jmp $6726
    @swap:
;    lda $6E96.w,X
;    ora text4bppConvBuffer.w,Y
;    sta text4bppConvBuffer.w,Y
;    lda $6E95,X
;    ora $3B1A,Y
;    sta $3B1A,Y
    
;    ora $3B1A.w,Y
;    sta $3B1A.w,Y
    lda $6E95.w,X
    ora $3B19.w,Y
    sta $3B19.w,Y
    jmp $6735
.ends

.bank 0 slot 0
.orga $6723
.section "stretched text double width send 4" overwrite
  jmp swapStretchConvIfNeeded
.ends

;===================================
; when transferring stretched-text patterns,
; clear cache content for target pattern if:
; - on a left-side transfer of stretch other than the upper-left, and
; - previous character was not stretched
; FIXME: this could produce erroneous erasure of stretched text in niche
; situations involving two groups of stretched text separated by less than
; 8 pixels of regular text.
; however, such situations are unlikely to arise in practice.
;===================================

.bank 0 slot 0
.orga $5E46
.section "stretched text cache clear check 1" overwrite
  jmp doStretchedTextCacheClearCheck
.ends

.bank 0 slot 0
.section "stretched text cache clear check 2" free
  doStretchedTextCacheClearCheck:
    ; make up work
;    adc #$A0
;    sta $25.b
    tam #$20
    cly 
    
    ; left-cache clear flagged as needed?
    lda leftCacheClearNeeded.w
    beq @noLeftCacheClear
      ; if text scaling off, clear
      lda textScale.w
      beq @clear
      
      ; if on left side of scaled character, clear
      lda stretchedTextPrintState.w
      lsr
      bcc @clear
    @noLeftCacheClear:
    
    ; stretched mode on?
    lda textScale.w
    beq @normal
      ; if previous character was stretched, handle normally
      lda prevCharWasStretched.w
      bne @normal
        ; check current state
        lda stretchedTextPrintState.w
        ; if 0 (upper-left) transfer, always handle normally
        beq @normal
        ; otherwise, if odd (right side), handle normally
        lsr
        bcs @normal
        @clear:
          ; use empty pattern instead of cache
          cla
          -:
            sta $3AF9.w,Y
            sta text4bppConvBuffer.w,Y
            iny 
            cpy #$20
            bne -
          jmp $5E57
    @normal:
    ; do normal transfer
    jmp $5E49
  
  updatePrevCharStretchNormal:
    ; do not update for stretched printing
    ; (because this is called multiple times per stretched character,
    ; and we need to only update it after the full print is done)
    lda textScale.w
    bne +
      stz prevCharWasStretched.w
    +:
    rts
  
  updatePrevCharStretchStretched:
    lda textScale.w
    sta prevCharWasStretched.w
    ; FIXME?
    stz leftCacheClearNeeded.w
    
    ; make up work
    ldy stretchedTextPrintState.w
    rts
  
  prevCharWasStretched:
    .db $00
.ends

; update whether previous character was stretched
; after call to printNextChar in main print routine.
; NOTE: also disables overwriting the new DTE flag out of convenience
; TODO: doesn't cover the auto-space op, but that shouldn't matter.
;       also, the first character in a box or on a line will get whatever
;       value was left at the end of the previous box/line, but the
;       first character never needs to be composited, so it works out
.bank 0 slot 0
.orga $57EC
.section "stretched text cache clear check 3" overwrite
  jsr updatePrevCharStretchNormal
.ends

; update prevCharWasStretched after entirely printing a stretched character
.bank 0 slot 0
.orga $67CB
.section "stretched text cache clear check 4" overwrite
  jsr updatePrevCharStretchStretched
.ends

;===================================
; modify vertical stretching to look
; more even with the new font
;===================================

.bank 3 slot 0
.section "new vertical stretch 1" free
  doNewDoubleStretch:
    ; the original algorithm evenly doubles the full 16px height of
    ; the target pattern to 32px.
    ; we instead triple the height of rows 1-10 of the input, which contain the 10px
    ; high font char, for 30px of output, with the top two rows blanked
    ; for a total of 32px.
    ; this gets complicated because it means the scaling no longer aligns
    ; cleanly to a 16x16 grid and is asymmetric between the top and bottom
    ; halves of the character.
    
    ; if generating upper half of character,
    lda stretchedTextPrintState.w
    cmp #2
    bcc @topHalf
    @bottomHalf:
      ; copy first input line to first output line
      lda text4bppConvBuffer+0.w
      sta nextChar1bppBuffer+0.w
      lda text4bppConvBuffer+1.w
      sta nextChar1bppBuffer+1.w
      
      ; for remaining 15 output rows, triple 5 lines,
      ; starting at input row 1 and output row 1
      
      ; set final output pos
      lda #$20
      sta @yCmpInstr+1.w
      ; Y = initial output pos
      ldy #$02
      bra @ready
    @topHalf:
      ; blank top two rows of output
      stz nextChar1bppBuffer+0.w
      stz nextChar1bppBuffer+1.w
      stz nextChar1bppBuffer+2.w
      stz nextChar1bppBuffer+3.w
      ; copy last line of input to last two rows of output
      lda text4bppConvBuffer+(5*2)+0.w
      sta nextChar1bppBuffer+28.w
      sta nextChar1bppBuffer+30.w
      lda text4bppConvBuffer+(5*2)+1.w
      sta nextChar1bppBuffer+29.w
      sta nextChar1bppBuffer+31.w
      
      ; for the 12 output rows in between, triple 4 lines,
      ; starting at input row 1 and output row 2
      
      ; set final output pos
      lda #$1C
      sta @yCmpInstr+1.w
      ; Y = initial output pos
      ldy #$04
    @ready:
    
    ; X = input pos
    ; (skipping first row, which is either skipped or specially handled)
    ldx #(1*2)
    -:
      ; copy left half to consecutive rows
      lda text4bppConvBuffer.w,X
      sta nextChar1bppBuffer+0.w,Y
      lda text4bppConvBuffer.w,X
      sta nextChar1bppBuffer+2.w,Y
      lda text4bppConvBuffer.w,X
      sta nextChar1bppBuffer+4.w,Y
      ; advance input/output to right half
      inx 
      iny 
      
      ; copy right half to consecutive rows
      lda text4bppConvBuffer.w,X
      sta nextChar1bppBuffer+0.w,Y
      lda text4bppConvBuffer.w,X
      sta nextChar1bppBuffer+2.w,Y
      lda text4bppConvBuffer.w,X
      sta nextChar1bppBuffer+4.w,Y
      ; advance input/output to next line
      inx 
      iny 
      
      ; advance 2 additional lines in output (for a total of 3)
      iny 
      iny 
      iny 
      iny 
      
      @yCmpInstr:
      cpy #$00
      bne -
    rts
  
  doNewTripleStretch:
    ; the original algorithm evenly triples the full 16px height of
    ; the target pattern to 48px.
    ; we instead quadruple rows 0-11 of the input for 48px of output.
    
    ; X = input pos
    ; Y = output pos
    cly
    clx
    -:
      ; copy left half to consecutive rows
      lda text4bppConvBuffer.w,X
      sta nextChar1bppBuffer+0.w,Y
      lda text4bppConvBuffer.w,X
      sta nextChar1bppBuffer+2.w,Y
      lda text4bppConvBuffer.w,X
      sta nextChar1bppBuffer+4.w,Y
      lda text4bppConvBuffer.w,X
      sta nextChar1bppBuffer+6.w,Y
      ; advance input/output to right half
      inx 
      iny 
      
      ; copy right half to consecutive rows
      lda text4bppConvBuffer.w,X
      sta nextChar1bppBuffer+0.w,Y
      lda text4bppConvBuffer.w,X
      sta nextChar1bppBuffer+2.w,Y
      lda text4bppConvBuffer.w,X
      sta nextChar1bppBuffer+4.w,Y
      lda text4bppConvBuffer.w,X
      sta nextChar1bppBuffer+6.w,Y
      ; advance input/output to next line
      inx 
      iny 
      
      ; advance 3 additional lines in output (for a total of 4)
      iny 
      iny 
      iny 
      iny 
      iny 
      iny 
      
      cpy #$20
      bne -
    rts
.ends

.bank 0 slot 0
.orga $65D6
.section "new vertical stretch 2" SIZE 8 overwrite
  doStdTrampolineCall doNewDoubleStretch
  jmp $65FA
.ends

.bank 0 slot 0
.orga $662D
.section "new vertical stretch 3" SIZE 8 overwrite
  doStdTrampolineCall doNewTripleStretch
  jmp $666B
.ends

;==============================================================================
; four-line text box
;==============================================================================

;===================================
; reassign unused (hopefully) op13
; as a three-line linebreak
;===================================

.bank 0 slot 0
.orga $5831
.section "new op13 1" overwrite
  .dw newOp13Handler
.ends

.bank 0 slot 0
.section "new op13 2" free
  newLinebreakHandler:
    ; if insta-print on, handle as three-line linebreak
    ldx scriptIndex.w
    lda forceInstaPrint.w,X
    bne newOp13Handler@start
    
    lda #$01
    bra newOp13Handler@altEntry
  
  newOp13Handler:
    ; HACK: due to the particularly problematic line area-0x2F6-0xA113,
    ; we need to be able to toggle the extra offset used for three-line
    ; mode off.
    ; with no easy way to extend the scripting system at this point,
    ; a sequence of three [br3] commands in a row (which should
    ; never legitimately occur) is now treated as a toggle for this behavior.
    doStdTrampolineCall doMultiBr3Check
    cmp #$00
    beq +
      rts
    +:
    
    @start:
    ; do 3-line linebreak
    cla
    @altEntry:
    sta fourLineBoxOn.w
;    ldx scriptIndex.w
;    ldy currentLineNum.w,X
;    jmp $634D
    jmp $6347
  
  fourLineBoxOn:
    .db $00
.ends

.bank 3 slot 0
.section "new op13 3" free
  doMultiBr3Check:
    lda scriptPtrLo.w
    sta $20.b
    lda scriptPtrHi.w
    sta $21.b
    
    ldy #$01
    lda ($20.b),Y
    cmp #$13
    bne +
      iny
      lda ($20.b),Y
      cmp #$13
      bne +
        lda no3RowOffset.w
        eor #$FF
        sta no3RowOffset.w
        
        ; scriptptr += 2
        ; (it will be incremented again in the call below)
;        lda $20.b
;        clc
;        adc #2
;        sta scriptPtrLo.w
;        cla
;        adc $21.b
;        sta scriptPtrHi.w
        jsr incScriptPtr
        jsr incScriptPtr
        ; set script continue flag and increment pointer.
        ; as a side effect, this will also return nonzero to indicate
        ; the op sequence was handled
        jmp $633E
    +:
    ; return zero to indicate not handled
    cla
    rts
    
  no3RowOffset:
    .db $00
.ends

;===================================
; modify linebreak op to handle
; four-line logic
;===================================

.bank 0 slot 0
.orga $580F
.section "new linebreak handler 1" overwrite
  .dw newLinebreakHandler
.ends

; this replaces the no force-pause-on-box-overflow check
; (pretty sure it's not used anyway)
.bank 0 slot 0
.orga $6359
.section "new linebreak handler 2" SIZE $D overwrite
  jmp doNewLinebreakLogic
.ends

.bank 0 slot 0
.section "new linebreak handler 3" free
  doNewLinebreakLogic:
    ; reset cache clear flag
    ; (TODO: probably not needed)
    stz leftCacheClearNeeded.w
    
    lda fourLineBoxOn.w
    bne +
      ; use original logic
      jmp $6366
    +:
    
    doStdTrampolineCall doFourLineLinebreak
    jmp $63BF
  
  currentRealLinebreakLineNum:
    .db $00
.ends

.bank 3 slot 0
.section "new linebreak handler 4" free
  doFourLineLinebreak:
    stz currentCharX.w,X
    
    ; new target offset is, depending on currentLineNum:
    ; - 01: (rowSpacing * 1)
    ; - 02: (rowSpacing * 3)
    ; - 03: (rowSpacing * 4)
    
    lda boxRowPatternSpacingHi.w,X
    sta $23.b
    sta $21.b
    lda boxRowPatternSpacingLo.w,X
    sta $22.b
    sta $20.b
    
    ; $10 = curentLineNum
    lda currentLineNum.w,X
    sta $10.b
    
    cmp #$01
    beq @rowSpacingCalcDone
      tay
      -:
        lda $22.b
        clc
        adc $20.b
        sta $22.b
        
        lda $23.b
        adc $21.b
        sta $23.b
        
        dey
        bne -
    @rowSpacingCalcDone:
    
    ; now, $22-23 = target row offset
    ; add to base tile number to get actual tile num target
    lda boxBaseTileNumLo.w,X
    clc 
    adc $22.b
    sta currentBoxTileNumLo.w,X
    lda boxBaseTileNumHi.w,X
    adc $23.b
    sta currentBoxTileNumHi.w,X

    jsr incScriptPtr
    
    ; repeat what we did for the target tile number with the target bat address
    lda boxBaseBatAddrLo.w,X
    sta $22.b
    lda boxBaseBatAddrHi.w,X
    sta $23.b
    
;    ldy $10.b
;    jsr advance22ByYLinesInBat
;    ldy $10.b
;    jsr advance22ByYLinesInBat
    ; lines to advance per currentLineNum:
    ; - 01: 1
    ; - 02: 3
    ; - 03: 4
    ldy $10.b
    cpy #$01
    beq +
      iny
    +:
    jsr advance22ByYLinesInBat
    
    lda $22.b
    sta currentBoxBatAddrLo.w,X
    lda $23.b
    sta currentBoxBatAddrHi.w,X
    
    ; reset line number to 1 if it was 3 to avoid overflowing
    ; the line char count array (whose content doesn't matter
    ; outside of insta-print mode, which isn't used with this
    ; linebreak mode)
;    lda currentLineNum.w,X
    lda $10.b
    sta currentRealLinebreakLineNum.w
    cmp #$03
    bne +
      lda #$01
      sta currentLineNum.w,X
    +:
    rts
.ends

;===================================
; modify pattern send to composite with
; cache tile if flagged to do so
;===================================

.bank 0 slot 0
.orga $6D1C
.section "char vram send cache composite 1" overwrite
  jmp doCharPatternSendCacheCompositeCheck
.ends

.bank 0 slot 0
.section "char vram send cache composite 2" free
  doCharPatternSendCacheCompositeCheck:
    ; make up work
;    lda #$02
;    sta $6A.b
    sta $0000.w
    cly
    
    lda charPatternSendCacheCompositeOn.w
    bne +
      ; use original logic
      jmp $6D20
    +:
    
    ; composite with target cache pattern as it's sent
    -:
      lda ($20.b),Y
      ora ($26.b),Y
      sta $0002.w
      
;      lda ($20.b),Y
      sta ($26.b),Y
      iny 
      
      lda ($20.b),Y
      ora ($26.b),Y
      sta $0003.w
      
;      lda ($20.b),Y
      sta ($26.b),Y
      iny 
      
      cpy #$20
      bne -
    
    jmp $6D38
  
  charPatternSendCacheCompositeOn:
    .db $00
.ends

;===================================
; modify no-x-reset br (op 09) to
; flag four-line box mode as off
;===================================

.bank 0 slot 0
.orga $68B2
.section "br no x reset new 1" overwrite
  jmp doBrNoXResetNew
.ends

.bank 0 slot 0
.section "br no x reset new 2" free
  doBrNoXResetNew:
    stz fourLineBoxOn.w
    ; make up work
    jmp incScriptPtr
.ends

;===================================
; do not insta-print text if the
; end-insta-print op is encountered
; while insta-print mode is off
; (this occurs sometimes due to
; script bugs; it doesn't have any
; noticeable effect in the original
; game because it just reprints the
; current text box, but causes
; problems in the translation due to
; the new 4-line printing mode)
;===================================

.bank 0 slot 0
.orga $68EF
.section "fix bad insta print 1" overwrite
  jmp doBadInstaPrintCheck
.ends

.bank 0 slot 0
.section "fix bad insta print 2" free
  doBadInstaPrintCheck:
    lda forceInstaPrint.w,X
    beq +
      ; make up work
      stz forceInstaPrint.w,X
      jmp $68F2
    +:
    ; do nothing
    jmp $6949
.ends

;==============================================================================
; cutscene scripting
;==============================================================================

;===================================
; HACK: check for overflow when computing number of frames
; to delay until next scene event.
; this prevents an issue in mainline mednafen that causes
; many cutscenes to hang the game as a result of some
; unclear timing inaccuracy.
;===================================

.bank 1 slot 0
.orga $8B70
.section "mednafen scene timing fix 1" overwrite
  jmp checkObjSceneTimerOverflow_op29_op31
.ends

.bank 1 slot 0
.orga $8CB5
.section "mednafen scene timing fix 2" overwrite
  jmp checkObjSceneTimerOverflow_op29_op31
.ends

.bank 0 slot 0
.section "mednafen scene timing fix 3" free
;    bsr checkObjSceneTimerOverflow
;    ; make up work
;    lda #$83
;    rts
  
;  checkObjSceneTimerOverflow:
  checkObjSceneTimerOverflow_op29_op31:
    ; HACK: assume that if high byte of delay timer is >= 0xFC,
    ; overflow has occurred
    ldy #7
    lda ($10.b),Y
    cmp #$FC
    bcc +
      ; scene timer -= amount by which timer overflowed
/*    sei
        dey
        lda sceneTimerLo.w
        clc
        adc ($10.b),Y
        sta sceneTimerLo.w
        iny
        lda sceneTimerHi.w
        adc ($10.b),Y
        sta sceneTimerHi.w
      cli*/
      
      ; force delay timer to zero
      cla
      sta ($10.b),Y
      dey
      sta ($10.b),Y
    +:
    ; make up work
    lda #$83
    rts
.ends

;==============================================================================
; rcr interrupt processing
;==============================================================================

;===================================
; required defines
;===================================

.redefine newRcrPicEndLine $A0
.redefine newRcrStartLine $A8
.redefine newRcrEndLine newRcrStartLine+32
.redefine defaultSubtitleBaseY $B8

;===================================
; if original rcr system not on,
; schedule our new interrupts
; if they're enabled
;===================================

.bank 0 slot 0
.orga $4267
.section "rcr enable 1" overwrite
;  jmp checkRcrEnableOrigOff
  jmp startIntCode_checkRcrEnableOrigOff
.ends

.bank 0 slot 0
.section "rcr enable 2" free
  checkRcrEnableOrigOff:
    ; make up work
;    lda #$06
;    sta $0000.w
    st0 #vdp_regRcr
    
    lda newRcrOn.w
    bne +
      ; use original logic
      jmp $426C
    +:
    
    ; set target rcr line (-1 so we can set up for next line)
    st1 #<(newRcrPicEndLine+rcrBaseLine-1)
    st2 #>(newRcrPicEndLine+rcrBaseLine-1)
    ; set state to waiting for new start
    ; (skipping waiting for orig end, since orig is not in use)
    lda #newRcr_state_waitingForPicEnd
    sta newRcrState.w
    
    jmp $4276
  
  newRcrOn:
    .db $00
  newRcrState:
    .db $00
.ends

;===================================
; if original rcr system is on,
; schedule our new interrupts
; if they're applicable
;===================================

.define rcrStructsControlBaseB $77
.define rcrStructsMainBaseB $7F

.bank 0 slot 0
.orga $4334
.section "rcr orig end check 1" overwrite
  jmp startIntCode_checkRcrEnableOrigOn
.ends

.bank 0 slot 0
.section "rcr orig end check 2" free
  checkRcrEnableOrigOn:
    ; make up work
    ; check high byte of next rcr target
    lda $88.b,X
    bmi +
    ; if high bit of high byte of next rcr target set
      ; use original logic
      jmp $4338
    +:
    
    ; end of original rcr interrupts reached
    
    ; if subtitles aren't on, do nothing
    lda subtitleDisplayOn.w
    beq @done
    
/*    ; check if new rcr on
    lda newRcrOn.w
    beq @done
      lda rcrStructsMainBaseB+0.b,X
      sec
      sbc #<(newRcrPicEndLine-1)
;      sta @check1Instr+1.w
      lda rcrStructsMainBaseB+1.b,X
      and #$7F
      sbc #>(newRcrPicEndLine-1)
;      sta @check2Instr+1.w
      
      ; if last rcr < pic end line, wait for pic end line
      ; and do rest of normal new interrupt handling.
      ; otherwise, assume no action needed (i.e. the image is deliberately
      ; being cropped to a height that will include the subtitle area).
      ; TODO: is this assumption correct?
      ;       for these in-engine scenes, it should be,
      ;       as the bottom of the screen is kept covered with a solid
      ;       layer of sprites for the message window.
      bcs @done
      
      @startWaitForPicEnd:
      ; inc should be fine, but let's play it safe
;      inc newRcrState.w
      lda #newRcr_state_waitingForPicEnd
      sta newRcrState.w
      ; set up next line target
      st0 #vdp_regRcr
      st1 #<(newRcrPicEndLine+rcrBaseLine-1)
      st2 #>(newRcrPicEndLine+rcrBaseLine-1)*/
    
    ; check if new rcr on
    lda newRcrOn.w
    beq @done
      ; if last rcr < pic end line, wait for pic end line
      ; and do rest of normal new interrupt handling.
      ; otherwise, assume no action needed (i.e. the image is deliberately
      ; being cropped to a height that will include the subtitle area).
      ; TODO: is this assumption correct?
/*      lda rcrStructsMainBaseB+0.b,X
      sec
      sbc #<(newRcrPicEndLine-1)
;      sta @check1Instr+1.w
      lda rcrStructsMainBaseB+1.b,X
      and #$7F
      sbc #>(newRcrPicEndLine-1)
;      sta @check2Instr+1.w
      bcc @done*/
/*      ; branch if upper byte less
      lda rcrStructsMainBaseB+1.b,X
      and #$7F
      cmp #>(newRcrPicEndLine-1)
      bcc @startWaitForPicEnd
      ; branch if lower byte less
      lda rcrStructsMainBaseB+0.b,X
      cmp #<(newRcrPicEndLine-1)
      bcs @done*/
      ; if +7 nonzero, the target line is still in raw RCR format
      ; and needs to be converted by subtracting 0x40.
      ; the high byte of the result will always be 0, so we don't need
      ; to bother with it.
      lda rcrStructsMainBaseB+7.b,X
      beq +
        lda rcrStructsMainBaseB+0.b,X
        sec
        sbc rcrBaseLine
        sta rcrStructsMainBaseB+0.b,X
;        bcs +
;          dec rcrStructsMainBaseB+1.b,X
      +:
      
      lda rcrStructsMainBaseB+0.b,X
      cmp #<(newRcrPicEndLine-1)
      bcs @not_startWaitForPicEnd
        ; inc should be fine, but let's play it safe
  ;      inc newRcrState.w
        lda #newRcr_state_waitingForPicEnd
        sta newRcrState.w
        ; set up next line target
        st0 #vdp_regRcr
        st1 #<(newRcrPicEndLine+rcrBaseLine-1)
        st2 #>(newRcrPicEndLine+rcrBaseLine-1)
        rts
      @not_startWaitForPicEnd:
      cmp #<(newRcrStartLine-1)
      bcs @not_startWaitForNewStart
        lda #newRcr_state_waitingForNewStart
        sta newRcrState.w
        ; set up next line target
;        st0 #vdp_regRcr
;        st1 #<(newRcrStartLine+rcrBaseLine-1)
;        st2 #>(newRcrStartLine+rcrBaseLine-1)
;        rts
        jsr turnOffBgAndSprites
        jmp setUpWaitingForNewStart
      @not_startWaitForNewStart:
      cmp #<(newRcrEndLine-1)
      bcs @done
        lda #newRcr_state_waitingForNewEnd
        sta newRcrState.w
        ; set up next line target
;        st0 #vdp_regRcr
;        st1 #<(newRcrEndLine+rcrBaseLine-1)
;        st2 #>(newRcrEndLine+rcrBaseLine-1)
        jsr turnOffBgAndTurnOnSprites
        jmp setUpWaitingForNewEnd
    @done:
    rts
.ends


;===================================
; new rcr handling logic
;===================================

.define origRcrEnableFlagB $77
.define vdpCrMemBackupB $F3

.bank 0 slot 0
.orga $42DB
.section "new rcr handler 1" overwrite
  jmp startIntCode_doNewRcrHandlerCheck
.ends

.bank 0 slot 0
.section "new rcr handler 2" free
  doNewRcrHandlerCheck:
    ; only use new logic if new rcr is on and state is nonzero
    ; (i.e. not waiting for end of original rcr handlers)
    lda newRcrOn.w
    beq @orig
    lda newRcrState.w
    bne @new
    @orig:
      ; use original logic
      lda origRcrEnableFlagB.b
      beq +
        jmp $42DF
      +:
      bra @done
    @new:
    
    ; jump to state handler
    jsr jumpToNewRcrStateHandler
    
    @done:
    ; return from interrupt
    jmp $42D2
  
  jumpToNewRcrStateHandler:
    dea
    asl
    tax
    jmp (newRcrStateHandlerTable.w,X)
  
  newRcrStateHandlerTable:
    .dw rcrStateHandler_waitingForPicEnd
    .dw rcrStateHandler_waitingForNewStart
    .dw rcrStateHandler_waitingForNewEnd
  
  rcrStateHandler_waitingForPicEnd:
    ; bg and sprites off
    bsr turnOffBgAndSprites
    
    ; if subtitles are not currently being displayed, stop here
    lda subtitleDisplayOn.w
    bne @nextState
    @stop:
      stz newRcrState.w
      rts
    @nextState:
    ; go to next state
    inc newRcrState.w
    ; set up next line target
    jmp setUpWaitingForNewStart
    
  rcrStateHandler_waitingForNewStart:
    ; bg off, sprites on
;    st0 #vdp_regCr
;    lda vdpCrMemBackupB.b
;    and #$7F
;    ora #$40
;    sta vdpCrMemBackupB.b
;    sta vdp_dataLo.w
    
    ; do not open non-cropped area if subtitles were not active on last frame.
    ; this prevents 1-frame glitches when activating subtitles.
    lda prevSubtitleDisplayOn.w
    beq rcrStateHandler_waitingForPicEnd@stop

    bsr turnOffBgAndTurnOnSprites
    
    ; go to next state
    inc newRcrState.w
    
    ; set up next line target
    jmp setUpWaitingForNewEnd
  
  rcrStateHandler_waitingForNewEnd:
    ; bg and sprites off
    bsr turnOffBgAndSprites
    
    ; reset state
    stz newRcrState.w
    rts
  
  turnOffBgAndTurnOnSprites:
    lda vdpCrMemBackupB.b
    and #$7F
    ora #$40
    bra turnOffBgAndSprites@finish
  
  turnOffBgAndSprites:
;    st0 #vdp_regCr
    lda vdpCrMemBackupB.b
    and #$3F
    @finish:
    st0 #vdp_regCr
    sta vdpCrMemBackupB.b
    sta vdp_dataLo.w
    rts
  
  setUpWaitingForNewStart:
    st0 #vdp_regRcr
    lda rcrCropTargetsMultipleLines.w
    bne @multiLine
      st1 #<(newRcrStartLine+rcrBaseLine-1+8)
      st2 #>(newRcrStartLine+rcrBaseLine-1+8)
      bra @lineSet
    @multiLine:
      st1 #<(newRcrStartLine+rcrBaseLine-1)
      st2 #>(newRcrStartLine+rcrBaseLine-1)
    @lineSet:
    rts
  
  setUpWaitingForNewEnd:
    st0 #vdp_regRcr
    lda rcrCropTargetsMultipleLines.w
    bne @multiLine
      st1 #<(newRcrEndLine+rcrBaseLine-1-8)
      st2 #>(newRcrEndLine+rcrBaseLine-1-8)
      bra @lineSet
    @multiLine:
      st1 #<(newRcrEndLine+rcrBaseLine-1)
      st2 #>(newRcrEndLine+rcrBaseLine-1)
    @lineSet:
    rts
    
.ends

;==============================================================================
; subtitle engine
;==============================================================================

;===================================
; required defines
;===================================

.define newZpFreeReg $10
.define newZpScriptReg $12

.define fixedBank 0
.define freeBank 3

.define fixedSlot 0
.define freeSlot 0

.define defaultSubtitleScriptPtr $0000
.define defaultSubtitleEngineOn $00

; TODO: not specific to this engine?
.define satMemBuf $2ACF
.define currentSpriteCount $9FFB
  
;.bank 0 slot 0
;.section "scene adv mem 1" free
;  ovlScene_subtitleEngineOn:
;    .db $00
;  ovlScene_rcrCropTargetsMultipleLines:
;    .db $00
;  ovlScene_subtitleDisplayOn:
;    .db $00
;.ends

; labels defined elsewhere:
; - ovlScene_font
; - ovlScene_fontWidthTable
; - newRcrOn

;===================================
; required includes
;===================================

.include "include/scene_adv_common.inc"

;===================================
; optional defines
;===================================

.define includeScriptBoxFadeLogic 1

;===================================
; required extra routines
;===================================

; WARNING: for use in interrupts!
;          do not use outside of them, and do not use them in cases
;          where one interrupt can interrupt another.
;          otherwise, saved values may be trashed at any time during execution.
/*.bank 0 slot 0
.section "scene adv routines 1" free
  ovlScene_setUpStdBanks:
    tma #$10
    sta ovlScene_restoreOldBanks@slot3+1.w
    tma #$20
    sta ovlScene_restoreOldBanks@slot4+1.w
    tma #$40
    sta ovlScene_restoreOldBanks@slot5+1.w
    
    lda #freeArea2MemPage
    tam #$10
;    ina
    lda #advSceneBaseBank
    tam #$20
    ina
    tam #$40
    
    rts
  
  ovlScene_restoreOldBanks:
    @slot3:
    lda #$00
    tam #$10
    @slot4:
    lda #$00
    tam #$20
    @slot5:
    lda #$00
    tam #$40
    
    rts
.ends*/

/*; TEST
.bank 3 slot 0
.section "scene adv routines 2" free
  ; FIXME
  subtitleScriptData:
    ;=====
    ; init
    ;=====
    
    cut_setPalette $08
    
;    SYNC_varTime 1 60
  
    ;=====
    ; we can't send anything too early or it screws up the game's
    ; regular graphics loading, so idle until it's safe to proceed
    ;=====
    
;    cut_waitForFrame $0140
    cut_waitForFrame 60
    
    cut_startNewString $01E0
    .db $21,$22,$23,$24,$25,$26,$27,$28,$29
    .db sceneOp_finishCurrentLine
;    .incbin "include/subintro/string300015.bin"
    cut_waitForFrame 120
    cut_swapAndShowBuf
    
    cut_startNewString $01E8
    .db $29,$28,$27,$26,$25,$24,$23,$22,$21
    .db sceneOp_br
    .db $2A,$2B,$2C,$2D,$2E,$2F
    .db sceneOp_finishCurrentLine
    cut_waitForFrame 240
    cut_swapAndShowBuf
    
    ; "galaxy fraulein legend yuna"
;    cut_startNewString $01BC
;    .incbin "include/subintro/string300015.bin"
;    
;    cut_waitForFrame $034F
;    cut_swapAndShowBuf
;    
;    cut_waitForFrame $0420
;    cut_subsOff
;    cut_swapAndShowBuf
;    
;    ; "watashi wa atsui"
;    cut_startNewString $01BC
;    .incbin "include/subintro/string300001.bin"
;    
;    cut_waitForFrame $1192
;    cut_subsOff
    
    cut_terminator
    
.ends*/

;===================================
; patches to use engine
;===================================

; vsync injection
.bank 0 slot 0
.orga $42CF
.section "scene adv vsync injection 1" overwrite
  jsr doAdvSceneCall
.ends

; MOVED to guaranteed-available area for interrupt safety
/*.bank 0 slot 0
.section "scene adv vsync injection 2" free
  doAdvSceneCall:
    ; do nothing if subtitle engine not on
;    lda subtitleEngineOn.w
;    beq @done
      jsr ovlScene_setUpStdBanks
      ; restores old banks when done
      jsr newSyncLogic
  ;    jsr ovlScene_restoreOldBanks
    @done:
    ; make up work
    jmp $E0E1
.ends*/

;===================================
; increment sync var for adpcm start
;===================================

.bank 1 slot 0
.orga $8B13
.section "scene adv sync var 1" overwrite
  jmp doAcpdmSyncVarInc
.ends

.bank 0 slot 0
.section "scene adv sync var 2" free
  doAcpdmSyncVarInc:
;    doStdTrampolineCall doAcpdmSyncVarIncExt
    doStdTrampolineCall incrementSyncVarCounterExt
    ; make up work
    lda #$89
    rts
.ends

/*.bank 3 slot 0
.section "scene adv sync var 3" free
  doAcpdmSyncVarIncExt:
;    lda syncFrameCounter+0.w
;    sta syncFrameCounterAtLastVarSync+0.w
;    lda syncFrameCounter+1.w
;    sta syncFrameCounterAtLastVarSync+1.w
;    inc syncVar.w
    jsr incrementSyncVarCounterExt
    rts
.ends*/

;===================================
; increment sync var for scene timer set
;===================================

/*.bank 1 slot 0
.orga $8D1E
.section "scene adv sync var timer set 1" overwrite
  jmp doSetSceneTimerVarInc
.ends

.bank 0 slot 0
.section "scene adv sync var timer set 2" free
  doSetSceneTimerVarInc:
;    doStdTrampolineCall doAcpdmSyncVarIncExt
    doStdTrampolineCall incrementSyncVarCounterExt
    ; make up work
    lda #$03
    rts
.ends*/

;===================================
; transfer generated sprites
;===================================

.bank 1 slot 0
.orga $9DB1
.section "scene adv sprite generation 1" SIZE 11 overwrite
  doStdTrampolineCall sendSubtitleSprites
  sta currentSpriteCount.w
  jmp $9DBC
.ends

.bank 3 slot 0
.section "scene adv sprite generation 2" free
  sendSubtitleSprites:
    ; make up work
    ; set up data dst
    lda #<satMemBuf
    sta $14.b
    lda #>satMemBuf
    sta $15.b
    
    lda subtitleEngineOn.w
    beq @noSceneSprites
    lda subtitleDisplayOn.w
    beq @noSceneSprites
    lda currentSubtitleSpriteAttributeQueueSize.w
    beq @noSceneSprites
      ; save size to transfer instruction
;      sta @transferCmd+5.w
      sta @loopSizeInstr+1.w
      
      ; set target crop for frame
;      lda rcrCropTargetsMultipleLines.w
;      sta currentFrame_rcrCropTargetsMultipleLines.w
      
      ; add size to base dst
      lda $14.b
      clc
      adc currentSubtitleSpriteAttributeQueueSize.w
      sta $14.b
      bcc +
        inc $15.b
      +:
      
      ; set src address
      lda currentSubtitleSpriteAttributeQueuePtr+0.w
      sta @transferCmd+1.w
      lda currentSubtitleSpriteAttributeQueuePtr+1.w
      sta @transferCmd+2.w
      
      clx
      -:
        @transferCmd:
        lda $0000.w,X
        sta satMemBuf.w,X
        
        inx
        @loopSizeInstr:
        cpx #$00
        bne -
      
      ; return initial currentSpriteCount
      txa
      lsr
      lsr
      lsr
    @noSceneSprites:
    rts
.ends

;===================================
; flag vram writes
;===================================

.bank 1 slot 0
.orga $8502
.section "scene flag vram writes 1" overwrite
  doStdTrampolineCall doSceneVramWriteFlagStart_vramWrite
  nop
.ends

.bank 3 slot 0
.section "scene flag vram writes 2" free
  setBlockVramWrites:
    tma #$20
    pha
    lda #freeArea2MemPage
    tam #$20
      inc (blockVramWrites+$2000).w
    pla
    tam #$20
    rts
  
  clearBlockVramWrites:
    tma #$20
    pha
    lda #freeArea2MemPage
    tam #$20
      stz (blockVramWrites+$2000).w
    pla
    tam #$20
    rts
  
  doSceneVramWriteFlagStart_vramWrite:
    jsr setBlockVramWrites
    
    ; make up work
    lda ($12.b),Y
    sta $0018
    lda #$05
    rts
  
  doSceneVramWriteFlagEndExt_vramWrite:
    jsr clearBlockVramWrites
    
    ; make up work
    lda #$88
    rts
  
  doSceneVramWriteFlagStart_tilemapWrite:
    jsr setBlockVramWrites
    
    ; make up work
    lda #$05
    sta $6A.b
    sta $0000.w
    rts
  
  doSceneVramWriteFlagEndExt_tilemapWrite:
    jsr clearBlockVramWrites
    
    ; make up work
    lda #$8B
    rts
.ends

.bank 1 slot 0
.orga $85D1
.section "scene flag vram writes 3" overwrite
  jmp doSceneVramWriteFlagEnd_vramWrite
.ends

.bank 0 slot 0
.section "scene flag vram writes 4" free
  doSceneVramWriteFlagEnd_vramWrite:
    doStdTrampolineCall doSceneVramWriteFlagEndExt_vramWrite
    rts
.ends

;===================================
; flag tilemap writes
;===================================

.bank 1 slot 0
.orga $8682
.section "scene flag tilemap writes 1" overwrite
  doStdTrampolineCall doSceneVramWriteFlagStart_tilemapWrite
  nop
  nop
.ends

.bank 1 slot 0
.orga $86FD
.section "scene flag tilemap writes 2" overwrite
  jmp doSceneVramWriteFlagEnd_tilemapWrite
.ends

.bank 0 slot 0
.section "scene flag tilemap writes 3" free
  doSceneVramWriteFlagEnd_tilemapWrite:
    doStdTrampolineCall doSceneVramWriteFlagEndExt_tilemapWrite
    rts
.ends

;===================================
; set up subtitle script when
; starting adv (if needed)
;===================================

.bank 1 slot 0
.orga $9541
.section "start adv subs if needed 1" SIZE 5 overwrite
  doStdTrampolineCall doAdvSubsSetup_makeup
;  jmp $954B
.ends

.bank 3 slot 0
.section "start adv subs if needed 2" free
  doAdvSubsSetup_makeup:
    jsr doAdvSubsSetup
    
    ; make up work
    lda #$10
    sta $333E.w
;    lda #$01
;    sta $3330.w
    rts
    
    
  doAdvSubsSetup:
    ; load in sub bank
    tma #$20
    pha
    lda #advSceneBaseBank
    tam #$20
      ; check for presence of magic bytes at end of bank
      lda advSceneBlockStartPtr+advScenePresentMarkerBlockOffset+0.w
      cmp #advScenePresentMarkerA
      bne @noSubs
      lda advSceneBlockStartPtr+advScenePresentMarkerBlockOffset+1.w
      cmp #advScenePresentMarkerB
      bne @noSubs
        ; set script pointer
        ; NOTE: we assume subtitle engine is off at this point;
        ; otherwise, this would need interrupts disabled to be 100% safe
        lda advSceneBlockStartPtr+advScenePointerBlockOffset+0.w
        sta subtitleScriptPtr+0.w
        lda advSceneBlockStartPtr+advScenePointerBlockOffset+1.w
        sta subtitleScriptPtr+1.w
        
        ; reset for new script
        jsr resetForScriptStart
        
        inc subtitleEngineOn.w
      @noSubs:
    pla
    tam #$20
    rts
.ends

;===================================
; actual engine
;===================================

.include "include/scene_adv.inc"

;==============================================================================
; case 2b ayaka flashback line subtitles
;==============================================================================

;===================================
; activate subtitles when target line started
;===================================

.bank 1 slot 0
.orga $8AF1
.section "ayaka flashback start 1" SIZE 5 overwrite
  doStdTrampolineCall doAyakaFlashbackStartCheck
.ends

.bank 3 slot 0
.section "ayaka flashback start 2" free
  doAyakaFlashbackStartCheck:
    ; make up work
    stz $FB.b
    
    ; check if the adpcm that's about to be loaded is
    ; the one we want (start sector 0x011E88)
    lda $18.b
    cmp #$01
    bne @done
    lda $19.b
    cmp #$88
    bne @done
    lda $1A.b
    cmp #$1E
    bne @done
      ; activate subtitles
      
      ; set script pointer
      lda #<ayakaFlashbackSubs
      sta subtitleScriptPtr+0.w
      lda #>ayakaFlashbackSubs
      sta subtitleScriptPtr+1.w
      
      ; reset for new script
      jsr resetForScriptStart
      inc subtitleEngineOn.w
    
    @done:
    ; make up work
    jmp AD_TRANS
.ends

;===================================
; script
;===================================

.bank 3 slot 0
.section "ayaka flashback script 1" free
  ayakaFlashbackSubs:
    SCENE_setUpAutoPlace $2E $10
    
    ; cropping on
;    cut_setCropOn $01
    
    ; text box off
    SCENE_textBoxOff
    
    ; sprite palette $C isn't used during this scene
    ; and is cleared afterwards
    cut_setPalette $0C
    
    ; start writing line before doing initial sync,
    ; so it will be ready to go by the time the clip
    ; has actually started playing
    
    ; "hey, hey, papa!"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/ayaka-flashback-0.bin"
    
    SYNC_varTime 1 $1C
    
    cut_setPalette $0C
    
    ;=====
    ; wait until safe start point
    ;=====
    
;    cut_waitForFrameMinSec 0 0.100
  
    ;=====
    ; data
    ;=====
    
    cut_waitForFrameMinSec 0 0.467
    cut_swapAndShowBuf
    
    ; "ayaka's made"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/ayaka-flashback-1.bin"
    cut_waitForFrameMinSec 0 1.912
    cut_swapAndShowBuf
    
;    cut_waitForFrameMinSec 0 4.836
;    cut_subsOff
  
    ;=====
    ; done
    ;=====
    
    ; wait for end of scene
    cut_waitForFrameMinSec 0 5.300
    cut_subsOff
    
    ; text box on
;    SCENE_textBoxOn
    SCENE_textBoxOnWithDelay 60
    ; cropping off
;    cut_setCropOn $00
    
    cut_terminator
.ends

;==============================================================================
; art gallery tongue twister show subtitles
;==============================================================================

;===================================
; save id of cd track to be played
;===================================

.bank 1 slot 0
.orga $8A5C
.section "cd track start save inc 1" SIZE 6 overwrite
  doStdTrampolineCall doCdTrackIdSave
  nop
.ends

.bank 3 slot 0
.section "cd track start save inc 2" free
  doCdTrackIdSave:
    ; make up work
    lda $18.b
    sta $F8.b
    ; save played CD track to sync id
    sta lastSyncId.w
    
    @done:
    lda $19.b
    rts
.ends

;===================================
; increment sync counter on successful cd track start
;===================================

.bank 1 slot 0
.orga $8A73
.section "cd track start sync inc 1" SIZE 6 overwrite
  doStdTrampolineCall doCdTrackSyncInc
  nop
.ends

.bank 3 slot 0
.section "cd track start sync inc 2" free
  doCdTrackSyncInc:
    jsr incrementSyncVarCounterExt
    
    ; save played CD track to sync id
;    ldy #01
;    lda ($12.b),Y
;    sta lastSyncId.w
    
    @done:
    ; make up work
    cla
    jsr CD_FADE
    lda #$84
    rts
.ends

;===================================
; start script when needed
;===================================

.bank 1 slot 0
.orga $8A52
.section "art gallery tongue twister start 1" SIZE 8 overwrite
  doStdTrampolineCall doTongueTwisterStartCheck
  jmp $8A5C
.ends

.bank 3 slot 0
.section "art gallery tongue twister start 2" free
  doTongueTwisterStartCheck:
    ; make up work
    -:
      lda ($12.b),Y
      sta $2017.w,Y
      iny
      cpy #$04
      bne -
     
    ; are we in the art gallery?
    ; (area == 0x356)
    lda currentAreaBaseSectorH.w
    bne @done
    lda currentAreaBaseSectorM.w
    cmp #$03
    bne @done
    lda currentAreaBaseSectorL.w
    cmp #$56
    bne @done
    
      ; TEST: always play track 1
;      lda #$01
;      sta $18.b
;      lda #$02
;      sta $19.b
      
      ; check if target track num is 1
      lda $18.b
      cmp #$01
      bne @done
      
      ; save playing track num
;      lda $18.b
;      sta lastPlayedCdTrackNum.w
      
      ; copy in data to normal position in adv bank
      tma #$20
      pha
      tma #$40
      pha
      lda #advSceneBaseBank
      tam #$20
      lda #$71
      tam #$40
        ; FIXME: is it okay if this is uninterruptable?
        tii $DA00,$BA00,$0600
      pla
      tam #$40
      pla
      tam #$20
      
      ; stop any existing subtitles
;      stz subtitleEngineOn.w
      lda subtitleEngineOn.w
      beq +
        jsr cancelActiveScript
      +:
      
      ; activate new subtitles
      jsr doAdvSubsSetup
    
    @done:
    rts
  
;  lastPlayedCdTrackNum:
;    .db $00
.ends

;===================================
; handle script cancellation gracefully
;===================================

.bank 1 slot 0
.orga $8B16
.section "art gallery tongue twister end 1" SIZE 5 overwrite
  doStdTrampolineCall doTongueTwisterEndCheck
.ends

.bank 3 slot 0
.section "art gallery tongue twister end 2" free
  cancelActiveScript:
    stz subtitleEngineOn.w
    stz subtitleDisplayOn.w
    
    ; fade in dialogue box if faded out (message box not on)
    sei
    nop
      ; edge case: if message box is CURRENTLY fading in or out,
      ; invert its level polarity to reverse the effect at the
      ; current position
      lda boxFadeLevel.w
      beq +
        ; remove pending delays
        bpl @pos
        @neg:
          cmp #-8
          bcs ++
            lda #-8
            bra ++
        @pos:
          cmp #8
          bcs ++
            lda #8
        ++:
        
        eor #$FF
        ina
        sta boxFadeLevel.w
        bra @fadeCheckDone
      +:
      
      ; do nothing if message box already on
;        lda msgBoxTargetSlotAddr.w
      lda msgBoxVisFlagsAddr.w
      and #$80
      bne @fadeCheckDone
        ; fade in
        lda #-8
        sta boxFadeLevel.w
    @fadeCheckDone:
    cli
    @done:
    rts
  
  doTongueTwisterEndCheck:
    ; make up work
    lda ($12.b),Y
    jsr CD_FADE
    
    ; check if script playing
    lda subtitleEngineOn.w
    beq @done
    ; check if fade that was performed targeted pcm
    lda ($12.b),Y
    cmp #$08
    beq @cancelScript
    cmp #$0C
    bne @done
    @cancelScript:
      jsr cancelActiveScript
    @done:
    rts
.ends

;==============================================================================
; last-minute hacks due to discovery that MPR3 is not guaranteed to be
; paged to $69 (second page of kernel) during interrupts
;==============================================================================

; it appears that the extremely rarely used graphics decompressor pages 
; the second kernel bank ($69) out of MPR3 at once point while leaving
; interrupts enabled. consequently, no code in an interrupt can depend
; on code in that bank.
; this decompressor is used e.g. in adv-0xC46 (and quite possibly nowhere else).
; therefore, we must make sure all our interrupt code jumps to an MPR2
; location first and ensures MPR3 is set to the needed value before continuing.

;===================================
; move some code from the old textscr
; op12/13 handler to the free bank
; to make space in MPR2 bank for what we need
;===================================

.bank 0 slot 0
.orga $5EF2
.section "old op12/13 handler move 1" SIZE 6 overwrite
  doStdTrampolineCall doRemovedOp1213Code
  rts
.ends

.bank 3 slot 0
.section "old op12/13 handler move 2" free
  doRemovedOp1213Code:
    lda scriptIndex.w
    pha 
      ; set script index to ((opcode - 0x12) << 5)
      lda ($20.b)
      sec 
      sbc #$12
      asl 
      asl 
      asl 
      asl 
      asl 
      sta scriptIndex.w
      tma #$20
      pha 
        lda #$07
        clc 
        adc $73.b
        tam #$20
        ldx scriptIndex.w
        lda boxBaseBatAddrLo.w,X
        sta $22.b
        lda boxBaseBatAddrHi.w,X
        sta $23.b
        ldy #$01
    ;    jsr moveBack22ByYLinesInBat [$7EA4]
        jsr $7EA4
        ldy #$02
    ;    jsr $7ED0
    ;    jsr subYFrom22InBat? [$7ED0]
        jsr $7ED0
    ;    ldy lineAutoWrapWidth [$3A72],X
        ldy $3A72.w,X
        lda $6E4E.w,Y
        ina
        sta $10.b
    ;    lda maxBoxLines? [$3A79],X
        lda $3A79.w,X
        ina
        asl 
        sta $11.b
        lda $3A7D.w,X
        sta $20.b
        lda $3A7E.w,X
        sta $21.b
        stz $12.b
        --:
          clx 
          -:
            lda #$00
        ;    sta selectedVdpReg [$006A]
            sta $6A.b
            sta $0000.w
            lda $22.b
            sta $0002.w
            lda $23.b
            sta $0003.w
            lda #$02
        ;    sta selectedVdpReg [$006A]
            sta $6A.b
            sta $0000.w
            cly 
            lda ($20.b),Y
            sta $0002.w
            iny 
            lda ($20.b),Y
            sta $0003.w
            ldy #$01
        ;    jsr addYTo22InBat [$7EBA]
            jsr $7EBA
            lda $20.b
            clc 
            adc #$02
            sta $20.b
            lda $21.b
            adc #$00
            sta $21.b
            inx 
            cpx $10.b
            bne -
          ldy $10.b
      ;    jsr subYFrom22InBat? [$7ED0]
          jsr $7ED0
          ldy #$01
      ;    jsr advance22ByYLinesInBat [$7E8F]
          jsr $7E8F
          inc $12.b
          lda $12.b
          cmp $11.b
          bne --
      pla 
      tam #$20
    pla
    sta scriptIndex.w
;    jsr incScriptPtr [$6BB2]
    jsr $6BB2
    lda #$01
;    sta scriptContinueFlag [$3B79]
    sta $3B79.w
    rts 
.ends

;===================================
; new guaranteed-available code area
;===================================

.bank 0 slot 0
.orga $5EF8
.section "new guaranteed code area 1" SIZE $A6 overwrite
  
  ;=====
  ; line interrupts.
  ; we don't need these in situations where MPR3 is paged out,
  ; so we just jump back to the original routines if it's
  ; not available.
  ;=====
  
  startIntCode_checkRcrEnableOrigOff:
    ; do nothing if MPR3 wrong
    tma #$08
    cmp #expectedMpr3Value
    beq +
      ; use original logic rather than new
      st0 #vdp_regRcr
      jmp $426C
    +:
    jmp checkRcrEnableOrigOff
  
  startIntCode_checkRcrEnableOrigOn:
    ; do nothing if MPR3 wrong
    tma #$08
    cmp #expectedMpr3Value
    beq +
      ; use original logic rather than new
      lda $88.b,X
      bpl ++
        jmp $4338
      ++:
      rts
    +:
    jmp checkRcrEnableOrigOn
    
  startIntCode_doNewRcrHandlerCheck:
    ; do nothing if MPR3 wrong
    tma #$08
    cmp #expectedMpr3Value
    beq +
      ; use original logic rather than new
      lda origRcrEnableFlagB.b
      beq ++
        jmp $42DF
      ++:
    +:
    jmp doNewRcrHandlerCheck
  
  ;=====
  ; vsync
  ;=====
  
  doAdvSceneCall:
    ; do nothing if subtitle engine not on
;    lda subtitleEngineOn.w
;    beq @done
      jsr ovlScene_setUpStdBanks
      ; restores old banks when done
      jsr newSyncLogic
  ;    jsr ovlScene_restoreOldBanks
    @done:
    ; make up work
    jmp $E0E1
  
  ; WARNING: for use in interrupts!
  ;          do not use outside of them, and do not use them in cases
  ;          where one interrupt can interrupt another.
  ;          otherwise, saved values may be trashed at any time during execution.
  ovlScene_setUpStdBanks:
    tma #$08
    sta ovlScene_restoreOldBanks@slot3+1.w
    tma #$10
    sta ovlScene_restoreOldBanks@slot4+1.w
    tma #$20
    sta ovlScene_restoreOldBanks@slot5+1.w
    tma #$40
    sta ovlScene_restoreOldBanks@slot6+1.w
    
    lda #expectedMpr3Value
    tam #$08
    lda #freeArea2MemPage
    tam #$10
  ;    ina
    lda #advSceneBaseBank
    tam #$20
    ina
    tam #$40
    
    rts

  ovlScene_restoreOldBanks:
    @slot3:
    lda #$00
    tam #$08
    @slot4:
    lda #$00
    tam #$10
    @slot5:
    lda #$00
    tam #$20
    @slot6:
    lda #$00
    tam #$40
    
    rts

  doTextSpeedCheck:
    cmp #3
    bcc +
    cmp #5
    bcs +
    ; if delay >= 3 and < 5
      lsr
      ina
    +:
    
    ; make up work
    sta textDelayCounter.w
    rts
.ends

;==============================================================================
; bump text speed up slightly
;==============================================================================

.bank 0 slot 0
.orga $5932
.section "text speed 1" overwrite
  jsr doTextSpeedCheck
.ends

.bank 0 slot 0
.orga $6855
.section "text speed 2" overwrite
  jsr doTextSpeedCheck
.ends










