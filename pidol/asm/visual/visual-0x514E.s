
.define useVsyncBgSprOffHack 1

.include "include/visual_base.inc"

;===================================
; case 3 intro 1
;===================================

;.redefine SYNC_offset 10

.bank freeBank slot freeSlot
.section "script data" free
  defaultSubtitleScriptPtr:
    ;=====
    ; init
    ;=====
    
;    SCENE_setUpAutoPlace $1B0 $20
    SCENE_setUpAutoPlace $190 $30
    
    cut_setPalette $0D
    
;    SYNC_varTime 1 $01
    
    ; cropping on
    cut_setCropOn $01
  
    ;=====
    ; wait until safe start point
    ;=====
    
;    cut_waitForFrameMinSec 0 1.000
    
    ; "the arrested sakaki"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x514E-0.bin"
    
    SYNC_varTime 1 $01
  
    ;=====
    ; data
    ;=====
    
    cut_waitForFrameMinSec 0 1.088
    cut_swapAndShowBuf
    
    ; "and it is believed"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x514E-1.bin"
    cut_waitForFrameMinSec 0 4.701
    cut_swapAndShowBuf
    
      ; "some have also suggested"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x514E-3.bin"
    
    cut_waitForFrameMinSec 0 8.377
    cut_subsOff
    cut_waitForFrameMinSec 0 8.983
    cut_swapAndShowBuf
    
    ; NOTE: delaying to avoid load transition
    cut_waitForFrameMinSec 0 10.000
    ; "the police may not be"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x514E-4.bin"
    cut_waitForFrameMinSec 0 11.816
    cut_swapAndShowBuf
    
    ; "and speculation has also"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x514E-5.bin"
    cut_waitForFrameMinSec 0 15.629
    cut_swapAndShowBuf
    
      ; NOTE: delaying to try to avoid "camera flash" palette effects,
      ; which eat up enough vsync time to cause flickering at the top
      ; of the screen if they occur during character rendering
      cut_waitForFrameMinSec 0 17.000
      ; "next, news of"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x514E-7.bin"
    
    cut_waitForFrameMinSec 0 19.476-0.187
    cut_subsOff
    cut_waitForFrameMinSec 0 20.666
    cut_swapAndShowBuf
    
      ; "MAY"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x514E-8.bin"
    
    ; HACK: temporarily force top-of-screen rcr interrupts to disable only bg
    ; so we can show top-of-screen label
    ; (see note in visual-0x4E4E)
    cut_waitForFrameMinSec 0 24.000-0.366
    cut_writeMem $68 $0288 $4C
    cut_swapAndShowBuf
    
      ; "MAY (2)"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x514E-9.bin"
      cut_waitForFrameMinSec 0 25.648
      cut_swapAndShowBuf
      
      cut_waitForFrameMinSec 0 27.648-0.434
      cut_subsOff
    
    ; HACK: disable the previous change
    cut_writeMem $68 $0288 $0C
  
    ;=====
    ; done
    ;=====
    
    ; cropping off
    cut_setCropOn $00
    
    cut_terminator
.ends








