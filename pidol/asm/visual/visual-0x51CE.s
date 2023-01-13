
.include "include/visual_base.inc"

;===================================
; case 3 intro 2
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
    
;    SYNC_varTime 1 $01
    
    ; cropping on
    cut_setCropOn $01
  
    ;=====
    ; wait until safe start point
    ;=====
    
;    cut_waitForFrameMinSec 0 1.000
    
    ; "having contributed to"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x51CE-0.bin"
    
    SYNC_varTime 1 $01
  
    ;=====
    ; data
    ;=====
    
    cut_waitForFrameMinSec 0 1.062
    cut_swapAndShowBuf
    
    ; "and her successes"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x51CE-1.bin"
    cut_waitForFrameMinSec 0 3.393
    cut_swapAndShowBuf
    
    ; "will today be"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x51CE-2.bin"
    cut_waitForFrameMinSec 0 7.901
    cut_swapAndShowBuf
    
      ; "due to this honor"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x51CE-4.bin"
    
    cut_waitForFrameMinSec 0 11.302
    cut_subsOff
    cut_waitForFrameMinSec 0 12.208
    cut_swapAndShowBuf
    
/*    ; "miss may will participate"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x51CE-5.bin"
    cut_waitForFrameMinSec 0 13.787
    cut_swapAndShowBuf*/
    
    ; NOTE: delaying to avoid top-screen flicker
    ; "...in the fall traffic safety parade"
    cut_waitForFrameMinSec 0 14.277
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x51CE-6.bin"
    cut_waitForFrameMinSec 0 16.277
    cut_swapAndShowBuf
    
    cut_waitForFrameMinSec 0 20.486
    cut_subsOff
  
    ;=====
    ; done
    ;=====
    
    ; cropping off
    cut_setCropOn $00
    
    cut_terminator
.ends








