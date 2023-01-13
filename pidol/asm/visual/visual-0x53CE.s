
.include "include/visual_base.inc"

;===================================
; case 3 ending 3
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
    
    ; "motoko's gotten crazy about"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x53CE-0.bin"
    
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
    
    cut_waitForFrameMinSec 0 3.284
    cut_swapAndShowBuf
    
      ; "she's been practicing as"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x53CE-1.bin"
    
    cut_waitForFrameMinSec 0 5.384
    cut_subsOff
    cut_waitForFrameMinSec 0 6.138
    cut_swapAndShowBuf
    
    ; "so recently"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x53CE-2.bin"
    cut_waitForFrameMinSec 0 9.395
    cut_swapAndShowBuf
    
      ; "and as for me"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x53CE-3.bin"
    
    cut_waitForFrameMinSec 0 11.360
    cut_subsOff
    cut_waitForFrameMinSec 0 19.948+0.067
    cut_swapAndShowBuf
    
      ; "haven't you memorized it"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x53CE-4.bin"
    
    cut_waitForFrameMinSec 0 22.371-0.250
    cut_subsOff
    cut_waitForFrameMinSec 0 23.744
    cut_swapAndShowBuf
    
    ; "oh, shut up"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x53CE-5.bin"
    cut_waitForFrameMinSec 0 25.574
    cut_swapAndShowBuf
    
    ; "i told you"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x53CE-6.bin"
    cut_waitForFrameMinSec 0 27.297
    cut_swapAndShowBuf
    
      ; "may! it's"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x53CE-7.bin"
    
    cut_waitForFrameMinSec 0 29.747+0.100
    cut_subsOff
    cut_waitForFrameMinSec 0 30.205
    cut_swapAndShowBuf
    
    ; "coming"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x53CE-8.bin"
    cut_waitForFrameMinSec 0 32.197
    cut_swapAndShowBuf
    
      ; "a lot of things"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x53CE-9.bin"
    
    cut_waitForFrameMinSec 0 33.381
    cut_subsOff
    cut_waitForFrameMinSec 0 35.669
    cut_swapAndShowBuf
    
      ; "may's keeping a"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x53CE-10.bin"
    
    cut_waitForFrameMinSec 0 38.496
    cut_subsOff
    cut_waitForFrameMinSec 0 39.304
    cut_swapAndShowBuf
    
    cut_waitForFrameMinSec 0 41.377
    cut_subsOff
  
    ;=====
    ; done
    ;=====
    
    ; cropping off
    cut_setCropOn $00
    
    cut_terminator
.ends
