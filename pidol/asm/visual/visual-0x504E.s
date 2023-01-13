
.include "include/visual_base.inc"

;===================================
; case 2b putting on navi
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
    
    ; "good morning, may"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x504E-0.bin"
    cut_waitForFrameMinSec 0 14.981
    cut_swapAndShowBuf
    
    ; "morning"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x504E-1.bin"
    cut_waitForFrameMinSec 0 16.972
    cut_swapAndShowBuf
    
      ; "what great weather"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x504E-3.bin"
    
    cut_waitForFrameMinSec 0 18.067
    cut_subsOff
    cut_waitForFrameMinSec 0 23.285
    cut_swapAndShowBuf
    
    ; "the sea's so"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x504E-4.bin"
    cut_waitForFrameMinSec 0 25.264
    cut_swapAndShowBuf
    
    ; "yes!"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x504E-5.bin"
    cut_waitForFrameMinSec 0 27.087
    cut_swapAndShowBuf
    
      ; "even though the scenery's"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x504E-6.bin"
    
    cut_waitForFrameMinSec 0 28.135-0.150
    cut_subsOff
    cut_waitForFrameMinSec 0 28.843
    cut_swapAndShowBuf
    
    ; "you don't want"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x504E-7.bin"
;    cut_waitForFrameMinSec 0 33.134
    cut_waitForFrameMinSec 0 31.441
    cut_swapAndShowBuf
    
    ; "yeah"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x504E-8.bin"
    cut_waitForFrameMinSec 0 35.591
    cut_swapAndShowBuf
    
    cut_waitForFrameMinSec 0 36.897
    cut_subsOff
  
    ;=====
    ; done
    ;=====
    
    ; cropping off
    cut_setCropOn $00
    
    cut_terminator
.ends








