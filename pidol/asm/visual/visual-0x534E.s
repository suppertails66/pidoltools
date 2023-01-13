
.include "include/visual_base.inc"

;===================================
; case 3 ending 2
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
    
    ; "ONE YEAR LATER"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x534E-0.bin"
    
    SYNC_varTime 1 $01
    
    ; cropping on
    cut_setCropOn $01
  
    ;=====
    ; wait until safe start point
    ;=====
    
;    cut_waitForFrameMinSec 0 1.000
  
    ;=====
    ; data
    ;=====
    
    ; HACK: temporarily force top-of-screen rcr interrupts to disable only bg
    ; so we can show top-of-screen label
    ; (see note in visual-0x4E4E)
    cut_waitForFrameMinSec 0 2.000-0.200
    cut_writeMem $68 $0288 $4C
    cut_swapAndShowBuf
    
      ; "one year has passed"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x534E-1.bin"
      cut_waitForFrameMinSec 0 3.626
      cut_swapAndShowBuf
    
/*      ; "one year has passed"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x534E-2.bin"
      cut_waitForFrameMinSec 0 4.626+1.000
      cut_swapAndShowBuf*/
      
      ; "everyone's grown a year"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x534E-3.bin"
      
      cut_waitForFrameMinSec 0 6.228
      cut_subsOff
    
    ; HACK: disable the previous change
    cut_writeMem $68 $0288 $0C
    
    cut_waitForFrameMinSec 0 7.502
    cut_swapAndShowBuf
    
      ; "mr. tachibana's"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x534E-4.bin"
    
    cut_waitForFrameMinSec 0 11.543
    cut_subsOff
    cut_waitForFrameMinSec 0 14.643
    cut_swapAndShowBuf
    
      ; "apparently, even now"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x534E-5.bin"
    
    cut_waitForFrameMinSec 0 20.014
    cut_subsOff
    cut_waitForFrameMinSec 0 24.581
    cut_swapAndShowBuf
    
    cut_waitForFrameMinSec 0 29.204
    cut_subsOff
    
    ; NOTE: most of vram is used for the animation of kanna getting hit by
    ; the fan, so this has to be set up carefully
    ; "kanna's now a"
;    SCENE_startNewStringAuto
    cut_startNewString $1D0
    .incbin "out/script/strings/visual-0x534E-6.bin"
    cut_waitForFrameMinSec 0 34.906
    cut_swapAndShowBuf
      
      cut_startNewString $1E2
      .incbin "out/script/strings/visual-0x534E-7.bin"
    
    cut_waitForFrameMinSec 0 37.674
    cut_subsOff
    cut_waitForFrameMinSec 0 38.477
    cut_swapAndShowBuf
    
    cut_startNewString $1B0
    .incbin "out/script/strings/visual-0x534E-8.bin"
    cut_waitForFrameMinSec 0 40.996
    cut_swapAndShowBuf
    
    cut_waitForFrameMinSec 0 42.823
    cut_subsOff
  
    ;=====
    ; done
    ;=====
    
    ; cropping off
    cut_setCropOn $00
    
    cut_terminator
.ends
