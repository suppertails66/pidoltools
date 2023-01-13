
.include "include/visual_base.inc"

;===================================
; case 3 ending 1
;===================================

;.redefine SYNC_offset 10

.bank freeBank slot freeSlot
.section "script data" free
  defaultSubtitleScriptPtr:
    ;=====
    ; init
    ;=====
    
    SCENE_setUpAutoPlace $1B0 $18
    
    cut_setPalette $0D
    
    ; "p-preposterous"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x52CE-0.bin"
    
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
    
    cut_waitForFrameMinSec 0 1.611
    cut_swapAndShowBuf
    
      ; "but we did"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x52CE-2.bin"
    
    cut_waitForFrameMinSec 0 5.463-0.233
    cut_subsOff
    cut_waitForFrameMinSec 0 8.579
    cut_swapAndShowBuf
    
      ; "the monitors at the"
      SCENE_startNewStringAuto
      ; NOTE: a rare instance where we need to shut off the current
      ; subtitle before the new one has finished rendering,
      ; and have to split up the line to allow for it
      .incbin "out/script/strings/visual-0x52CE-3.bin" READ 32
;      cut_waitForFrameMinSec 0 9.898-0.287
      cut_waitForFrameMinSec 0 9.898+0.012
      cut_subsOff
      .incbin "out/script/strings/visual-0x52CE-3.bin" SKIP 32
      
    cut_waitForFrameMinSec 0 10.809
    cut_swapAndShowBuf
    
    ; "no..."
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x52CE-4.bin"
    cut_waitForFrameMinSec 0 15.128
    cut_swapAndShowBuf
    
    ; "not just those"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x52CE-5.bin"
    cut_waitForFrameMinSec 0 16.995
    cut_swapAndShowBuf
    
    ; "this video is being"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x52CE-6.bin"
    cut_waitForFrameMinSec 0 18.805
    cut_swapAndShowBuf
    
      ; "all the people watching"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x52CE-7.bin"
    
    cut_waitForFrameMinSec 0 23.205
    cut_subsOff
    cut_waitForFrameMinSec 0 25.096
    cut_swapAndShowBuf
    
    ; "you"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x52CE-8.bin"
    cut_waitForFrameMinSec 0 28.983
    cut_swapAndShowBuf
    
    ; "you, yourself, admitting"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x52CE-9.bin"
    cut_waitForFrameMinSec 0 30.769
    cut_swapAndShowBuf
    
      ; "thousands--tens of thousands"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x52CE-10.bin"
    
    cut_waitForFrameMinSec 0 34.003
    cut_subsOff
    cut_waitForFrameMinSec 0 35.905
    cut_swapAndShowBuf
    
      ; "chief ohtaki"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x52CE-11.bin"
    
    cut_waitForFrameMinSec 0 39.045
    cut_subsOff
    cut_waitForFrameMinSec 0 40.516
    cut_swapAndShowBuf
    
      ; "i place you under"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x52CE-12.bin"
    
    cut_waitForFrameMinSec 0 41.660
    cut_subsOff
    cut_waitForFrameMinSec 0 42.442
    cut_swapAndShowBuf
    
    cut_waitForFrameMinSec 0 44.111-0.100
    cut_subsOff
  
    ;=====
    ; done
    ;=====
    
    ; cropping off
    cut_setCropOn $00
    
    cut_terminator
.ends








