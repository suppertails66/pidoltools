
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
  bankstotal $3
  
  ; bank 0 = main area, 4000-8000
  ; bank 1 = ??? module, A000-C000
  ; bank 2 = script module, C000-E000
  banksize $10000
  banks $3
.endro

.emptyfill $FF

.background "credits_asm.bin"

;===================================
; unbackgrounds
;===================================

.unbackground $0+$5B80 $0+$5FFF
.unbackground $0+$6000 $0+$7FFF
.unbackground $10000+$B2F5 $10000+$BFFF

;===================================
; new stuff
;===================================

.define fixedAreaMemPage $68
.define freeAreaMemPage $6A

;===================================
; old routines
;===================================



;===================================
; old memory locations
;===================================

; if bit 1 of this is set, logo is drawn in corner
.define logoObjSlot_flags $357A

;===================================
; macros
;===================================

/*.macro doStdTrampolineCall ARGS dst
  jsr trampolineCallExtraArea2
    .dw dst
.endm*/

.macro fixWordLocs ARGS addr1, addr2, newVal
  .bank 2 slot 0
  .orga addr1
  .section "fixWordLocs \@ 1" overwrite
    .dw newVal
  .ends
  
  .bank 2 slot 0
  .orga addr2
  .section "fixWordLocs \@ 2" overwrite
    .dw newVal
  .ends
.endm

;==============================================================================
; 
;==============================================================================

/*.bank 0 slot 0
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
    
.ends*/

;===================================
; font lookup
;===================================

/*.bank 0 slot 0
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
.ends*/

.bank 0 slot 0
.section "new font char lookup 2" free
  
;  fontStd:
;    .incbin "out/font/font.bin"
  
  ovlScene_font:
    .incbin "out/font/font_scene.bin"
  
;  fontWidthStd:
;    .incbin "out/font/fontwidth.bin"
  
  ovlScene_fontWidthTable:
    .incbin "out/font/fontwidth_scene.bin"
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

/*.bank 1 slot 0
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
;    rts*/
  
/*;  checkObjSceneTimerOverflow:
  checkObjSceneTimerOverflow_op29_op31:
    ; HACK: assume that if high byte of delay timer is >= 0xFC,
    ; overflow has occurred
    ldy #7
    lda ($10.b),Y
    cmp #$FC
    bcc +*/
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
      
/*      ; force delay timer to zero
      cla
      sta ($10.b),Y
      dey
      sta ($10.b),Y
    +:
    ; make up work
    lda #$83
    rts
.ends*/

;==============================================================================
; subtitle engine
;==============================================================================

;===================================
; required defines
;===================================

.define newZpFreeReg $10
.define newZpScriptReg $12

.define fixedBank 0
.define freeBank 0

.define fixedSlot 0
.define freeSlot 0

;.define defaultSubtitleScriptPtr $0000
.define defaultSubtitleEngineOn $FF

; TODO: not specific to this engine?
.define satMemBuf $2ACF
; FIXME
;.define currentSpriteCount $9FFB
  
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

;===================================
; optional defines
;===================================

; no line flood -- sprites are displayed alongside credits
.define noDefaultLineFloodMode 1
.define alignSubsTowardBorder 1

.redefine defaultSubtitleBaseY 142+24-2
.redefine defaultSubtitleGroupTopToBottomGap 110+24-2

;.define extraSubtitleLeftOffsetFlag 1
;.define extraSubtitleLeftOffset 24

;===================================
; required includes
;===================================

.include "include/scene_adv_common.inc"

;===================================
; required extra routines
;===================================

; WARNING: for use in interrupts!
;          do not use outside of them, and do not use them in cases
;          where one interrupt can interrupt another.
;          otherwise, saved values may be trashed at any time during execution.
.bank 0 slot 0
.section "scene adv routines 1" free
  ovlScene_setUpStdBanks:
;    tma #$10
;    sta ovlScene_restoreOldBanks@slot3+1.w
;    tma #$20
;    sta ovlScene_restoreOldBanks@slot4+1.w
;    tma #$40
;    sta ovlScene_restoreOldBanks@slot5+1.w
    
;    lda #freeAreaMemPage
;    tam #$10
;    lda #freeAreaMemPage
;    tam #$20
;    ina
;    tam #$40
    
    rts
  
  ovlScene_restoreOldBanks:
;    @slot3:
;    lda #$00
;    tam #$10
;    @slot4:
;    lda #$00
;    tam #$20
;    @slot5:
;    lda #$00
;    tam #$40
    
    rts
  
  ; we don't use this, but it's less trouble to just define it here
  ; and ignore it than to set up conditional non-use in scene_adv
  newRcrOn:
    .db $00
.ends

;===================================
; patches to use engine
;===================================

; vsync injection
.bank 0 slot 0
.orga $4184
.section "scene adv vsync injection 1" overwrite
  jmp doAdvSceneCall
.ends

.bank 0 slot 0
.section "scene adv vsync injection 2" free
  doAdvSceneCall:
    ; make up work
    bbr5 $6C,+
      rmb5 $6C.b
      stz $0402.w
      stz $0403.w
      tia $2D95,$0404,$0380
    +:
    
    ; do nothing if subtitle engine not on
    lda subtitleEngineOn.w
    beq @done
      jsr ovlScene_setUpStdBanks
      ; restores old banks when done
      jsr newSyncLogic
  ;    jsr ovlScene_restoreOldBanks
    @done:
    
    ; make up work
    jmp $4196
.ends

;===================================
; increment sync var for cd play
;===================================

.bank 0 slot 0
.orga $530A
.section "scene adv sync var 1" overwrite
  jmp doAcpdmSyncVarInc
.ends

.bank 0 slot 0
.section "scene adv sync var 2" free
  doAcpdmSyncVarInc:
    jsr incrementSyncVarCounterExt
    ; make up work
    lda #$00
    jmp $E02D
.ends

;===================================
; transfer generated sprites
;===================================

.bank 0 slot 0
.orga $49CB
.section "scene adv sprite generation 1" overwrite
  jmp sendSubtitleSprites
.ends

.bank 0 slot 0
.section "scene adv sprite generation 2" free
  sendSubtitleSprites:
/*    ; disable logo if not on
    stz logoObjSlot_flags.w
    lda logoHidden.w
    bne @logoDone
      lda #$01
      sta logoObjSlot_flags
    @logoDone:*/
    
    lda subtitleDisplayOn.w
    beq @noSceneSprites
    lda currentSubtitleSpriteAttributeQueueSize.w
    beq @noSceneSprites
      ; save size to transfer instruction
      sta @loopSizeInstr+1.w
      
      ; add size to base dst
      lda $10.b
      clc
      adc currentSubtitleSpriteAttributeQueueSize.w
      sta $10.b
      bcc +
        inc $11.b
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
      
      ; "return" initial currentSpriteCount so it will be set below
      txa
      lsr
      lsr
      lsr
    @noSceneSprites:
    ; make up work
    ; set currentSpriteCount (zero if no subtitle sprites)
    sta $89.b
    ; set intial obj check slot?
    clx
    jmp $49CE
.ends

;===================================
; flag vram writes
;===================================

.bank 0 slot 0
.section "scene flag vram writes 1" free
  doSceneVramWriteFlagStart:
;    tma #$20
;    pha
;    lda #freeArea2MemPage
;    tam #$20
      inc blockVramWrites.w
;    pla
;    tam #$20
    
    ; make up work
;    lda ($12.b),Y
;    sta $0018
;    lda #$05
    rts
  
  doSceneVramWriteFlagEnd:
;    tma #$20
;    pha
;    lda #freeArea2MemPage
;    tam #$20
      stz blockVramWrites.w
;    pla
;    tam #$20
    
    ; make up work
;    lda #$88
    rts
.ends

.bank 0 slot 0
.orga $4F59
.section "scene flag vram writes 2" overwrite
  jmp flagVramWriteStart_text
.ends

.bank 0 slot 0
.orga $4FF6
.section "scene flag vram writes 3" overwrite
  jmp flagVramWriteEnd_text
.ends

.bank 0 slot 0
.section "scene flag vram writes 4" free
  flagVramWriteStart_text:
    jsr doSceneVramWriteFlagStart
    
    ; make up work
    stz $27.b
    lda $22.b
    jmp $4F5D
  
  flagVramWriteEnd_text:
    ; make up work
    cpx $22.b
    beq +
      jmp $4FDA
    +:
    jmp doSceneVramWriteFlagEnd
  
  flagVramWriteStart_text2:
    jsr doSceneVramWriteFlagStart
    
    ; make up work
    lda #$00
    sta $F7.b
    jmp $5041
  
  flagVramWriteEnd_text2:
    ; make up work
    cpx $24.b
    beq +
      jmp $5097
    +:
    jmp doSceneVramWriteFlagEnd
  
  flagVramWriteStart_text3:
    jsr doSceneVramWriteFlagStart
    
    ; make up work
    lda #$00
    sta $F7.b
    jmp $50DE
  
  flagVramWriteEnd_text3:
    ; make up work
    cpx $24.b
    beq +
      jmp $5126
    +:
    jmp doSceneVramWriteFlagEnd
  
  flagVramWriteStart_grp1:
    jsr doSceneVramWriteFlagStart
    
    ; make up work
    lda #$00
    sta $F7.b
    jmp $5A83
  
  flagVramWriteEnd_grp1:
    jsr doSceneVramWriteFlagEnd
    ; make up work
    lda #$07
    rts
.ends

.bank 0 slot 0
.orga $503D
.section "scene flag vram writes 5" overwrite
  jmp flagVramWriteStart_text2
.ends

.bank 0 slot 0
.orga $50A5
.section "scene flag vram writes 6" overwrite
  jmp flagVramWriteEnd_text2
.ends

.bank 0 slot 0
.orga $50DA
.section "scene flag vram writes 7" overwrite
  jmp flagVramWriteStart_text3
.ends

.bank 0 slot 0
.orga $5131
.section "scene flag vram writes 8" overwrite
  jmp flagVramWriteEnd_text3
.ends

.bank 0 slot 0
.orga $5A7F
.section "scene flag vram writes 9" overwrite
  jmp flagVramWriteStart_grp1
.ends

.bank 0 slot 0
.orga $5ABF
.section "scene flag vram writes 10" overwrite
  jmp flagVramWriteEnd_grp1
.ends

;===================================
; actual engine
;===================================

.include "include/scene_adv.inc"

;==============================================================================
; subtitle data
;==============================================================================

/*.bank 0 slot 0
.section "credits logo 1" free
  logoHidden:
    .db $00
.ends*/

.define logoSlideFrameCount 60
.define logoBaseX $90

;===================================
; actual engine
;===================================

.bank freeBank slot freeSlot
.section "script data" free
  defaultSubtitleScriptPtr:
    ;=====
    ; init
    ;=====
    
    SCENE_setUpAutoPlace $1B0 $20
    
    cut_setPalette $0D
    
    SYNC_varTime 1 $01
    
    ; cropping on
;    cut_setCropOn $01
  
    ;=====
    ; wait until safe start point
    ;=====
    
    cut_waitForFrameMinSec 0 3.000
  
    ;=====
    ; data
    ;=====
    
    ; "yoru ga fukete"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/credits-0.bin"
    
    ; slide logo off-screen
    cut_waitForFrameMinSec 0 23.333-0.40
    .rept logoSlideFrameCount INDEX count
      cut_writeMemWord $F8 $1572 logoBaseX+((256-logoBaseX)*(count/logoSlideFrameCount))
    .endr
    ; hide logo
    cut_writeMem $F8 $157A $00
    
    cut_waitForFrameMinSec 0 24.333
    ; hide logo
;    cut_writeMem $F8 $157A $00
;    cut_writeMem (scdBaseMemPage+((logoHidden-$4000)/$2000)), (logoHidden&$1FFF), $FF
    cut_swapAndShowBuf
    
    ; "kousou biru no machi"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/credits-1.bin"
    cut_waitForFrameMinSec 0 29.704
    cut_swapAndShowBuf
    
    ; "yume no shizuku"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/credits-2.bin"
    cut_waitForFrameMinSec 0 35.089
    cut_swapAndShowBuf
    
    ; "kurukuru mawashite"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/credits-3.bin"
    cut_waitForFrameMinSec 0 39.371
    cut_swapAndShowBuf
    
    ; "machi no hi ni"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/credits-4.bin"
    cut_waitForFrameMinSec 0 45.861
    cut_swapAndShowBuf
    
    ; "suteki na purezento"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/credits-5.bin"
    cut_waitForFrameMinSec 0 51.247
    cut_swapAndShowBuf
    
    ; "mada minu anata made"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/credits-6.bin"
    cut_waitForFrameMinSec 0 56.632
    cut_swapAndShowBuf
    
    ; "todoke kono omoi"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/credits-7.bin"
    cut_waitForFrameMinSec 1 1.347
    cut_swapAndShowBuf
    
    ; "koi no hinto wa"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/credits-8.bin"
    cut_waitForFrameMinSec 1 7.434
    cut_swapAndShowBuf
    
    ; "hitomi ga tegakari"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/credits-9.bin"
    cut_waitForFrameMinSec 1 12.819
    cut_swapAndShowBuf
    
    ; "nayande atsumeru"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/credits-10.bin"
    cut_waitForFrameMinSec 1 18.205
    cut_swapAndShowBuf
    
    ; "infomeeshon"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/credits-11.bin"
    cut_waitForFrameMinSec 1 23.591
    cut_swapAndShowBuf
    
    ; "koi o shiyou yo tsukitometai ne"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/credits-12.bin"
    cut_waitForFrameMinSec 1 28.977
    cut_swapAndShowBuf
    
    ; "abunai jiken"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/credits-14.bin"
    cut_waitForFrameMinSec 1 34.377
    cut_swapAndShowBuf
    
    ; "kakusareta shinjitsu o"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/credits-15.bin"
    cut_waitForFrameMinSec 1 39.763
    cut_swapAndShowBuf
    
    ; "sagashite mitsukedasou"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/credits-16.bin"
    cut_waitForFrameMinSec 1 45.149
    cut_swapAndShowBuf
    
    ; "koi o shiyou yo makikomaretai"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/credits-18.bin"
    cut_waitForFrameMinSec 1 50.535
    cut_swapAndShowBuf
    
    ; "abunai jiken"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/credits-20.bin"
    cut_waitForFrameMinSec 1 55.920
    cut_swapAndShowBuf
    
    ; "kono mama ja"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/credits-21.bin"
    cut_waitForFrameMinSec 2 1.306
    cut_swapAndShowBuf
    
    ; "yarusenai rainy night"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/credits-22.bin"
    cut_waitForFrameMinSec 2 6.707
    cut_swapAndShowBuf
    
    cut_waitForFrameMinSec 2 12.092
    cut_subsOff
    
    
    
    ; ****************** repeat **********************
    
    
    
    ; "koi o shiyou yo tsukitometai ne"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/credits-12.bin"
    cut_waitForFrameMinSec 2 33.650
    cut_swapAndShowBuf
    
    ; "abunai jiken"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/credits-14.bin"
    cut_waitForFrameMinSec 2 39.036
    cut_swapAndShowBuf
    
    ; "kakusareta shinjitsu o"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/credits-15.bin"
    cut_waitForFrameMinSec 2 44.422
    cut_swapAndShowBuf
    
    ; "sagashite mitsukedasou"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/credits-16.bin"
    cut_waitForFrameMinSec 2 49.793
    cut_swapAndShowBuf
    
    ; "koi o shiyou yo makikomaretai"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/credits-18.bin"
    cut_waitForFrameMinSec 2 55.208
    cut_swapAndShowBuf
    
    ; "abunai jiken"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/credits-20.bin"
    cut_waitForFrameMinSec 3 0.609
    cut_swapAndShowBuf
    
    ; "kono mama ja"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/credits-21.bin"
    cut_waitForFrameMinSec 3 5.980
    cut_swapAndShowBuf
    
    ; "yarusenai rainy night"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/credits-22.bin"
    cut_waitForFrameMinSec 3 11.365
    cut_swapAndShowBuf
    
    cut_waitForFrameMinSec 3 16.751
    cut_subsOff
    
    ; show logo
;    cut_writeMem $F8 $157A $01
;    cut_writeMem (scdBaseMemPage+((logoHidden-$4000)/$2000)) (logoHidden # $2000) $00
;    cut_writeMem (scdBaseMemPage+((logoHidden-$4000)/$2000)), (logoHidden&$1FFF), $00
    
    ; show logo
    cut_writeMem $F8 $157A $01
    ; slide logo on-screen
    .rept logoSlideFrameCount INDEX count
      cut_writeMemWord $F8 $1572 logoBaseX+((256-logoBaseX)*((logoSlideFrameCount-count)/logoSlideFrameCount))
    .endr
    ; -_-
    cut_writeMemWord $F8 $1572 logoBaseX
  
    ;=====
    ; done
    ;=====
    
    ; cropping off
;    cut_setCropOn $00
    
    cut_terminator
.ends

;==============================================================================
; credits text
;==============================================================================

.define nextChar1bppBuffer $2D50

.define nextChar1bppBufferSize 32

.define colsWithSolidPixelLB $81
.define colsWithSolidPixelRB $82
.define currentCharSpaceB $83

.define charTopFillerRows 1

;===================================
; use new strings
;===================================

.include "asm/gen/credits_text.inc"

;===================================
; fetch literals as bytes instead of words
;===================================

.bank 0 slot 0
.orga $51A1
.section "font word to byte 1" overwrite
  ; advance srcptr 1 byte instead of 2
;  lda #$02
  lda #$01
.ends

;===================================
; use new font
;===================================

.bank 0 slot 0
.section "use new font 1" free
  fontStd:
  fontAlt:
    .incbin "out/font/font.bin"
  
  fontWidthStd:
  fontWidthAlt:
    .incbin "out/font/fontwidth.bin"
  
  fontEmphOn:
    .db $00
.ends

.bank 0 slot 0
.orga $45E1
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
  ; the input will not be greater than 0x80, so the high byte
  ; from multiplying by 2 will always be zero; we don't need to
  ; bother explicitly computing it here
;    lda $13.b
;    rol
;    sta @fontFinalAdd2+1.w
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
    bra ++
  +:
    lda fontWidthStd.w,Y
  ++:
  
  ; save width
;  sta currentCharWidth.w
;  sta currentCharRawGlyphWidth.w
  sta currentCharSpaceB.b
  
  ; HACK: game doesn't like if last character goes to exactly a pattern boundary,
  ; so in that case, add an extra pixel of width
  ; check if next char == terminator
  ; (HACK: assumes no control codes at end of string, but we can probably
  ; accommodate that for the limited use case here)
  lda $10.b
  bne +
    ; check if ((pixelSubX + newCharW) & 0x7) == 1
    lda $85.b
    clc
    adc currentCharSpaceB.b
    and #$07
    bne +
      inc currentCharSpaceB.b
  +:
  
  ;=====
  ; copy character data to dst buffer
  ;=====
  
/*  lda #(charTopFillerRows*2)
  sta @cpxInstr+1.w
  
  @addFillerRows:*/
  clx
/*  -:
    stz nextChar1bppBuffer.w,X
    inx
    @cpxInstr:
    cpx #$00
    bne -*/
  
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
  
  jmp $4767
.ends

;===================================
; use new font width
;===================================

.bank 0 slot 0
.orga $4BE7
.section "new font width 1" overwrite
  jmp $4C2C
.ends

;==============================================================================
; credits text adjustments
;==============================================================================

;===================================
; vram location
;===================================

/*; "produced by"
.bank 2 slot 0
.orga $CEC3
.section "text vram locs 1" overwrite
;  .dw $1000
  .dw $1000
.ends

; "hunex co"
.bank 2 slot 0
.orga $CEC9
.section "text vram locs 2" overwrite
;  .dw $1200
  .dw $1200
.ends*/

;=====
; "produced by and copyright"
;=====

.bank 2 slot 0
.orga $CECF
.section "text vram locs 3a" overwrite
;  .dw $1600
  .dw $1400
.ends

/*.bank 2 slot 0
.orga $CEEE
.section "text vram locs 3b" overwrite
;  .dw $1600
  .dw $1400
.ends*/

/*; "nec home electronics"
.bank 2 slot 0
.orga $CED5
.section "text vram locs 4" overwrite
;  .dw $1800
  .dw $1800
.ends*/

;===================================
; positioning adjustments
;===================================

.bank 2 slot 0
.orga $CEDF
.section "text alignment 1" overwrite
  ; "produced by"
  .db $0D
;    .db $0E,$05
    .db 12,$05
    .dw $1000
    .db $00
  ; "hunex co"
  .db $0D
;    .db $08,$08
    .db 11,$08
    .dw $1200
    .db $01
  ; "produced by and copyright"
  .db $0D
;    .db $0C,$0D
    .db 7,$0D
;    .dw $1600
    .dw $1400
    .db $02
  ; "nec home electronics"
  .db $0D
;    .db $04,$10
    .db 6,$10
    .dw $1800
    .db $03
  
  ; wait
  .db $01
    .dw $2A30
  
  ; cleanup
  .db $0E
;    .db $0E,$05
    .db 12,$05
    .db $00
  .db $0E
;    .db $08,$08
    .db 11,$08
    .db $01
  .db $0E
;    .db $0C,$0D
    .db 7,$0D
    .db $02
  .db $0E
;    .db $04,$10
    .db 6,$10
    .db $03
.ends

.bank 2 slot 0
.orga $CF19
.section "text alignment 2" overwrite
  ; "it's over now"
  .db $0D
;    .db $08,$0A
    .db 11,$0A
    .dw $1000
    .db $00
  ; "you still haven't"
  .db $0D
;    .db $08,$0E
    .db 3,$0E
    .dw $1400
    .db $01
  
  ; wait
  .db $01
    .dw $1C20
  
  ; cleanup
  .db $0E
;    .db $08,$0A
    .db 11,$0A
    .db $00
  .db $0E
;    .db $08,$0E
    .db 3,$0E
    .db $01
.ends

.bank 2 slot 0
.orga $CF45
.section "text alignment 3" overwrite
  ; "ah, geez, whatever"
  .db $0D
;    .db $08,$08
    .db 9,$08+2
    .dw $1000
    .db $00
  ; "we'll tell you a secret"
  .db $0D
;    .db $08,$0C
    .db 5,$0C+2
    .dw $1400
    .db $01
  .db $0D
    .db $08,$10+2
    .dw $1800
    .db $02
  
  ; wait
  .db $01
    .dw $384
  
  ; cleanup
  .db $0E
;    .db $08,$08
    .db 9,$08+2
    .db $00
  .db $0E
;    .db $08,$0C
    .db 5,$0C+2
    .db $01
  .db $0E
    .db $08,$10+2
    .db $02
.ends

.bank 2 slot 0
.orga $CF8F
.section "text alignment 4" overwrite
  ; "on the menu screen, while"
  .db $0D
    .db $06,$06
    .dw $1000
    .db $00
  .db $0D
    .db $06,$08
    .dw $1400
    .db $01
  .db $0D
    .db $06,$0A
    .dw $1800
    .db $02
  .db $0D
    .db $06,$0C
    .dw $1C00
    .db $03
  
  .db $17
    .db $00
  
  ; "you can go to"
  .db $0D
;    .db $06,$10
    .db 8,$10
    .dw $2000
    .db $04
  .db $0D
;    .db $06,$12
    .db 8,$12
    .dw $2400
    .db $05
  
  ; wait
  .db $01
    .dw $1C20
  
  ; cleanup
  .db $0E
    .db $06,$06
    .db $00
  .db $0E
    .db $06,$08
    .db $01
  .db $0E
    .db $06,$0A
    .db $02
  .db $0E
    .db $06,$0C
    .db $03
  .db $0E
;    .db $06,$10
    .db 8,$10
    .db $04
  .db $0E
;    .db $06,$12
    .db 8,$12
    .db $05
.ends

.bank 2 slot 0
.orga $D098
.section "text alignment 5" overwrite
  ; "this time for real, it's"
  .db $0D
;    .db $0A,$0A
    .db 8,$0A
    .dw $1000
    .db $00
  
  .db $17
    .db $09
  
  ; "the end"
  .db $0D
    .db $0D,$0E
    .dw $1400
    .db $01
.ends

/*.bank 2 slot 0
.orga $C03E
.section "text alignment 6" overwrite
  ; "designer/director"
  .db $0D
;    .db $04,$04
    .db 2,$04
    .dw $1000
    .db $00
  
  ; color
  .db $17
    .db $00
  
  ; "toyoharu moriyama"
  .db $0D
;    .db $08,$08
    .db 6,$08
    .dw $1400
    .db $01
  
  ; cleanup
  .db $0E
;    .db $04,$04
    .db 2,$04
    .db $00
  .db $0E
;    .db $08,$08
    .db 6,$08
    .db $01
.ends*/
  
  ; "designer/director"
;  fixWordLocs $C03F $C050 $0404
  fixWordLocs $C03F $C050 $0402
  ; "toyoharu moriyama"
;  fixWordLocs $C047 $C050 $0808
  fixWordLocs $C047 $C054 $0806

.bank 2 slot 0
.orga $C3CE
.section "text vram locs 7a" overwrite
  ; "A.I.C Co."
;  .dw $2000
  .dw $2200
.ends

.bank 2 slot 0
.orga $C411
.section "text vram locs 7b" overwrite
  ; "A.I.C Co."
;  .dw $2000
  .dw $2200
.ends

.bank 2 slot 0
.orga $C74A
.section "text vram locs 8a" overwrite
  ; "sampling"
;  .dw $1A00
  .dw $1C00
.ends

.bank 2 slot 0
.orga $C750
.section "text vram locs 8b" overwrite
  ; "akio sekine"
;  .dw $1C00
  .dw $1E00
.ends

.bank 2 slot 0
.orga $C787
.section "text vram locs 8c" overwrite
  ; "sampling"
;  .dw $1A00
  .dw $1C00
.ends

.bank 2 slot 0
.orga $C78F
.section "text vram locs 8d" overwrite
  ; "akio sekine"
;  .dw $1C00
  .dw $1E00
.ends

.bank 2 slot 0
.orga $C7C4
.section "text vram locs 9a" overwrite
  ; "nobuyoshi kawashima"
;  .dw $1400
  .dw $1600
.ends

.bank 2 slot 0
.orga $C7CA
.section "text vram locs 9b" overwrite
  ; "sound producer"
;  .dw $1600
  .dw $1A00
.ends

.bank 2 slot 0
.orga $C7D0
.section "text vram locs 9c" overwrite
  ; "recording director"
;  .dw $1800
  .dw $1E00
.ends

.bank 2 slot 0
.orga $C7D6
.section "text vram locs 9d" overwrite
  ; "recording director"
;  .dw $1A00
  .dw $2000
.ends

.bank 2 slot 0
.orga $C7F5
.section "text vram locs 9e" overwrite
  ; "nobuyoshi kawashima"
;  .dw $1400
  .dw $1600
.ends

.bank 2 slot 0
.orga $C7FD
.section "text vram locs 9f" overwrite
  ; "sound producer"
;  .dw $1600
  .dw $1A00
.ends

.bank 2 slot 0
.orga $C803
.section "text vram locs 9g" overwrite
  ; "recording director"
;  .dw $1800
  .dw $1E00
.ends

.bank 2 slot 0
.orga $C80B
.section "text vram locs 9h" overwrite
  ; "recording director"
;  .dw $1A00
  .dw $2000
.ends

/*.bank 2 slot 0
.orga $C7C4
.section "text vram locs 10a" overwrite
  ; "nobuyoshi kawashima"
;  .dw $1400
  .dw $1600
.ends

.bank 2 slot 0
.orga $C7CA
.section "text vram locs 10b" overwrite
  ; "sound producer"
;  .dw $1600
  .dw $1800
.ends

.bank 2 slot 0
.orga $C7D0
.section "text vram locs 10c" overwrite
  ; "recording director"
;  .dw $1800
  .dw $1C00
.ends

.bank 2 slot 0
.orga $C7D6
.section "text vram locs 10d" overwrite
  ; "recording director"
;  .dw $1A00
  .dw $1E00
.ends*/

  fixWordLocs $C8D2 $C905 $1600+$200
  fixWordLocs $C8D8 $C90D $1800+$400
  fixWordLocs $C8DE $C915 $1A00+$400
  fixWordLocs $C8E4 $C91B $1C00+$400

  ; "yuuichi makita" position
  ;fixWordLocs $CBFF $CC34 $0A0C
  fixWordLocs $CBFF $CC34 $0C08
  ; "animage" position
  ;fixWordLocs $CC1B $CC44 $0814
  fixWordLocs $CC1B $CC44 $1406

  fixWordLocs $CCC6 $CCFF $1400+$200
  fixWordLocs $CCCC $CD05 $1600+$400
  fixWordLocs $CCD2 $CD0B $1800+$600
  fixWordLocs $CCD8 $CD11 $1C00+$600
  fixWordLocs $CCDE $CD17 $2000+$600
  fixWordLocs $CCE4 $CD1D $2400+$600
  fixWordLocs $CCEA $CD23 $2800+$600

  ; "private eyedol" position
  ;fixWordLocs $C013 $C022 $0604
  fixWordLocs $C013 $C022 $0605

  ; "atsuko ishida" position
  ;fixWordLocs $C071 $C082 $0808
;  fixWordLocs $C071 $C082 $0806
