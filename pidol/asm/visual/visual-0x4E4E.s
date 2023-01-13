
.include "include/visual_base.inc"

;===================================
; case 2a intro p1
;===================================

;.redefine SYNC_offset 10

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
    cut_setCropOn $01
  
    ;=====
    ; wait until safe start point
    ;=====
    
    cut_waitForFrameMinSec 0 1.000
  
    ;=====
    ; data
    ;=====
    
    ; "i'm sorry, ayaka"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4E4E-0.bin"
    cut_waitForFrameMinSec 0 9.987
    cut_swapAndShowBuf
    
      ; "i did nothing but work"
      SCENE_startNewStringAuto
      ; NOTE: line split up into two parts with a delay in processing between
      ; to accommodate a load transition
      .incbin "out/script/strings/visual-0x4E4E-1.bin" READ 23
      cut_waitForFrameMinSec 0 11.769-0.200
      .incbin "out/script/strings/visual-0x4E4E-1.bin" SKIP 23
    
;    cut_waitForFrameMinSec 0 11.790
;    cut_subsOff
    
    cut_waitForFrameMinSec 0 12.249
    cut_swapAndShowBuf
    
      ; NOTE: working around cd interrupt issues?
;      cut_waitForFrameMinSec 0 12.249+0.500
      ; "ayaka tachibana"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x4E4E-3.bin"
    
    cut_waitForFrameMinSec 0 15.845
    cut_subsOff
    
;    cut_waitForFrameMinSec 0 16.154
    cut_waitForFrameMinSec 0 15.845+1.000
    ; HACK: temporarily force top-of-screen rcr interrupts to disable only bg,
    ; not sprites, so we can show the tombstone label at the top of the screen.
    ; we're overriding the parameter to the following setup for a write to the CR:
    ; 4287  A9 0C                lda #$0C
    cut_writeMem $68 $0288 $4C
    cut_swapAndShowBuf
        
        ; "ayaka..."
        SCENE_startNewStringAuto
        .incbin "out/script/strings/visual-0x4E4E-4.bin"
      
      cut_waitForFrameMinSec 0 17.958
      cut_swapAndShowBuf
      
      ; "forgive your father"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x4E4E-5.bin"
      cut_waitForFrameMinSec 0 20.006
      cut_swapAndShowBuf
    
    ; HACK: disable the previous change
    cut_writeMem $68 $0288 $0C
    
    cut_waitForFrameMinSec 0 23.229
    cut_subsOff
    
    ; cropping off
    cut_setCropOn $00
    
    ; wait until title card appears
    cut_waitForFrameMinSec 0 32.250
    
    ; HACK: kill the line interrupt handler.
    ; otherwise, it'll block part of our new, larger subtitle graphic.
    ; we overwrite the first instruction at $427E with
    ; the equivalent of "bra $4275", branching it to the interrupt
    ; handler exit sequence.
    ; a new scene starts immediately afterwards, so we don't
    ; have to worry about restoring it.
    cut_writeMemWord $68 $027E $F580
    
    cut_terminator
.ends








