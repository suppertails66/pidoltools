
;==============================================================================
; boot program
;==============================================================================

.include "include/global.inc"
;.include "include/scene_adv_common.inc"

;===================================
; 
;===================================

.memorymap
   defaultslot     0
   
   slotsize        $2000
   slot            0       $4000
   slot            1       $8000
   slot            2       $A000
   slot            3       $C000
.endme

.rombankmap
  bankstotal $5
  
  banksize $2000
  banks $5
.endro

.emptyfill $FF

.background ROMNAME

;===================================
; new stuff
;===================================

.define fixedAreaMemPage $80
.define freeAreaMemPage $84

;.define satVramAddr $7F00

;======================================================================
; 
;======================================================================

.unbackground $1100 $1FFF
.unbackground $8800 $9FFF

;.define baseOffset $4000
;.define bankSize $2000

;.macro makeFixedPointer ARGS ptr
;  .dw (ptr&$1FFF)+((:ptr)*bankSize)+baseOffset
;.endm

;=====
; load new syscard error graphics
;=====

.define newSyscardErrorGrpSrcOffset $7800
.define newSyscardErrorGrpSrcBank (newSyscardErrorGrpSrcOffset/$2000)
.define newSyscardErrorGrpSrcPtrOffset (newSyscardErrorGrpSrcOffset&$1FFF)
.define newSyscardErrorGrpSrcPtr $A000+newSyscardErrorGrpSrcPtrOffset
;.define newSyscardErrorGrpDstAddr $4800
; must be divisible by $100
.define newSyscardErrorGrpSize $1000

.bank 0 slot 0
.orga $42FF
.section "new syscard error grp 1" overwrite
  jmp loadNewSyscardErrorGrp
.ends

.bank 0 slot 0
.section "new grp 2" free
  loadNewSyscardErrorGrp:
    ; src bank
/*    lda #(newSyscardErrorGrpSrcBank+$80)
;    clc 
;    adc $6D.b
    tam #$20
    ina 
    tam #$40*/
    ; src
    lda #<newSyscardErrorGrpSrcPtr
    sta $20.b
    lda #>newSyscardErrorGrpSrcPtr
    sta $21.b
;    lda #$00
;    sta $F7.b
;    sta $0000.w
    ; size
    ldx #((newSyscardErrorGrpSize+$FF)/$100)
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
    lda #$00
    sta $4A.b
    jmp $4303
.ends



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
.define freeBank 4

.define fixedSlot 0
.define freeSlot 3

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

;.redefine defaultSubtitleBaseY 142+24-2
;.redefine defaultSubtitleGroupTopToBottomGap 110+24-2

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
.orga $427E
.section "scene adv vsync injection 1" overwrite
  jmp doAdvSceneCall
.ends

.bank 0 slot 0
.section "scene adv vsync injection 2" free
  doAdvSceneCall:
    ; make up work
    inc $73.b
    inc $29BE.w
    bne +
      inc $29BF.w
    +:
    
    ; do nothing if subtitle engine not on
    lda subtitleEngineOn.w
    beq @done
      jsr ovlScene_setUpStdBanks
      ; restores old banks when done
      jsr newSyncLogic
  ;    jsr ovlScene_restoreOldBanks
  
      ; send sprites
      jsr sendSubtitleSprites
    @done:
    
    ; make up work
    jmp $4288
.ends

;===================================
; increment sync var for adpcm play
;===================================

.bank 0 slot 0
.orga $439C
.section "scene adv sync var 1" overwrite
  jmp doAcpdmSyncVarInc
.ends

.bank 0 slot 0
.section "scene adv sync var 2" free
  doAcpdmSyncVarInc:
    ; make up work
    jsr AD_CPLAY
    jsr incrementSyncVarCounterExt
    jmp $439F
.ends

;===================================
; transfer generated sprites
;===================================

/*.bank 0 slot 0
.orga $49CB
.section "scene adv sprite generation 1" overwrite
  jmp sendSubtitleSprites
.ends*/

.bank 0 slot 0
.section "scene adv sprite generation 2" free
  sendSubtitleSprites:
    clx
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
;      txa
;      lsr
;      lsr
;      lsr
    @noSceneSprites:
    ; clear remaining data in sprite table
    
    ; up to 0x100
    cla
    -:
      sta satMemBuf.w,X
      inx
      bne -
    
    ; up to 0x200
    -:
      sta satMemBuf+$100.w,X
      inx
      bne -
    
    ; transfer memory sat to vram
    st0 #$00
    st1 #<satVramAddr
    st2 #>satVramAddr
    st0 #$02
    tia satMemBuf,$0002,$0200
    
    ; initiate sat->satb dma
    st0 #$13
    st1 #<satVramAddr
    st2 #>satVramAddr
    
    ; force sprite display on
;    smb6 $F3
    
    rts
.ends

;===================================
; actual engine
;===================================

.include "include/scene_adv.inc"

;==============================================================================
; subtitle data
;==============================================================================

;===================================
; actual engine
;===================================

.bank freeBank slot freeSlot
.section "script data" free
  defaultSubtitleScriptPtr:
    ;=====
    ; init
    ;=====
    
    ; note that we can't overwrite bg tile $700/sprite tile $1C0,
    ; as it's used to blank out the bottom part of the tilemap
    ; (which is partially visible at the bottom of the screen)
    SCENE_setUpAutoPlace $180 $20
    
    cut_setPalette $0D
    
    SYNC_varTime 1 $2B
    
    ; cropping on
;    cut_setCropOn $01
  
    ;=====
    ; wait until safe start point
    ;=====
    
    cut_waitForFrameMinSec 0 1.000
  
    ;=====
    ; data
    ;=====
    
    ; "gah"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/syscard-error-0.bin"
    cut_waitForFrameMinSec 0 2.630
    cut_swapAndShowBuf
    
    ; "they made me into a scoop"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/syscard-error-1.bin"
    cut_waitForFrameMinSec 0 4.202
    cut_swapAndShowBuf
    
    ; "what are you doing!?"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/syscard-error-2.bin"
    cut_waitForFrameMinSec 0 6.062
    cut_swapAndShowBuf
    
    ; "this game is exclusively"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/syscard-error-3.bin"
    cut_waitForFrameMinSec 0 7.739
    cut_swapAndShowBuf
    
    ; "right!?"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/syscard-error-4.bin"
    cut_waitForFrameMinSec 0 10.862
    cut_swapAndShowBuf
    
/*    ; "to play this game"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/syscard-error-5.bin"
    cut_waitForFrameMinSec 0 12.092
    cut_swapAndShowBuf*/
    
/*    ; "or a"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/syscard-error-6.bin"
;    cut_waitForFrameMinSec 0 15.156
    cut_waitForFrameMinSec 0 14.820
    cut_swapAndShowBuf*/
    
    ; "you need a"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/syscard-error-6.bin"
;    cut_waitForFrameMinSec 0 15.156
    cut_waitForFrameMinSec 0 13.676
    cut_swapAndShowBuf
    
    ; "but you just had to"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/syscard-error-7.bin"
    cut_waitForFrameMinSec 0 18.811
    cut_swapAndShowBuf
    
    ; "for real"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/syscard-error-8.bin"
    cut_waitForFrameMinSec 0 20.850
    cut_swapAndShowBuf
    
    ; "may, girl"
/*    SCENE_startNewStringAuto
    .incbin "out/script/strings/syscard-error-9.bin"
;    cut_waitForFrameMinSec 0 21.987
    cut_waitForFrameMinSec 0 22.000
    cut_swapAndShowBuf*/
    
    ; "m-motoko! what're you"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/syscard-error-10.bin"
    cut_waitForFrameMinSec 0 23.947
    cut_swapAndShowBuf
    
    ; "well, see you"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/syscard-error-12.bin"
    cut_waitForFrameMinSec 0 28.194
    cut_swapAndShowBuf
    
    ; "th-that's my line"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/syscard-error-14.bin"
    cut_waitForFrameMinSec 0 31.199
    cut_swapAndShowBuf
    
    cut_waitForFrameMinSec 0 33.868
    cut_subsOff
  
    ;=====
    ; done
    ;=====
    
    ; cropping off
;    cut_setCropOn $00
    
    cut_terminator
.ends










