
.include "include/visual_base.inc"

;===================================
; case 2b ending
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
    
    ; "hmm"
;    SCENE_startNewStringAuto
;    .incbin "out/script/strings/visual-0x50CE-0.bin"
;    cut_waitForFrameMinSec 0 1.473
;    cut_swapAndShowBuf
    
    ; "so, you got saved by"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x50CE-1.bin"
    cut_waitForFrameMinSec 0 3.097
    cut_swapAndShowBuf
    
    ; "guess that geezer's"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x50CE-2.bin"
    cut_waitForFrameMinSec 0 6.621
    cut_swapAndShowBuf
    
    ; "he was grumbling about"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x50CE-3.bin"
    cut_waitForFrameMinSec 0 9.444
    cut_swapAndShowBuf
    
    ; "anyway, it's great"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x50CE-4.bin"
    cut_waitForFrameMinSec 0 12.938
    cut_swapAndShowBuf
    
      ; "mr. mutou's son"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x50CE-5.bin"
    
    cut_waitForFrameMinSec 0 15.619+0.200
    cut_subsOff
    cut_waitForFrameMinSec 0 17.000
    cut_swapAndShowBuf
    
    ; "but mr. watabe did"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x50CE-6.bin"
    cut_waitForFrameMinSec 0 20.016
    cut_swapAndShowBuf
    
    ; "i heard that he and"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x50CE-7.bin"
    cut_waitForFrameMinSec 0 22.809
    cut_swapAndShowBuf
    
    ; "i hope those two"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x50CE-8.bin"
    cut_waitForFrameMinSec 0 25.906
    cut_swapAndShowBuf
    
    ; "and you know who else"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x50CE-9.bin"
    cut_waitForFrameMinSec 0 29.400
    cut_swapAndShowBuf
    
    ; "as long as i'm around"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x50CE-10.bin"
    cut_waitForFrameMinSec 0 33.117
    cut_swapAndShowBuf
    
    ; "oh, you say all that"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x50CE-11.bin"
    cut_waitForFrameMinSec 0 37.666
    cut_swapAndShowBuf
    
    ; "isn't that where"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x50CE-12.bin"
    cut_waitForFrameMinSec 0 40.489
    cut_swapAndShowBuf
    
    ; "geez, i've been found out"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x50CE-13.bin"
;    cut_waitForFrameMinSec 0 42.002
    cut_waitForFrameMinSec 0 42.165
    cut_swapAndShowBuf
    
      ; "look, it's not like"
;      SCENE_startNewStringAuto
;      .incbin "out/script/strings/visual-0x50CE-15.bin"
    
    cut_waitForFrameMinSec 0 43.800-0.183
    cut_subsOff
    ; NOTE: delaying to avoid load transition
    cut_waitForFrameMinSec 0 44.800
    ; "look, it's not like"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x50CE-15.bin"
    cut_waitForFrameMinSec 0 49.091
    cut_swapAndShowBuf
    
    cut_waitForFrameMinSec 0 52.402
    cut_subsOff
  
    ;=====
    ; done
    ;=====
    
    ; cropping off
    cut_setCropOn $00
    
    cut_terminator
.ends








