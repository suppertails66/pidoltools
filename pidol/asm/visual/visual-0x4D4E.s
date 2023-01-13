
.include "include/visual_base.inc"

;===================================
; case 1 ending p2
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
    
    ; "may..."
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4D4E-0.bin"
    cut_waitForFrameMinSec 0 3.069
    cut_swapAndShowBuf
    
    ; "may!"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4D4E-1.bin"
    cut_waitForFrameMinSec 0 4.887
    cut_swapAndShowBuf
    
    ; "please pull yourself together"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4D4E-2.bin"
    cut_waitForFrameMinSec 0 6.431
    cut_swapAndShowBuf
    
      ; "are you all right"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x4D4E-4.bin"
    
    cut_waitForFrameMinSec 0 7.740+0.200
    cut_subsOff
    
    cut_waitForFrameMinSec 0 10.997
    cut_swapAndShowBuf
    
      ; "so i didn't"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x4D4E-5.bin"
    
    cut_waitForFrameMinSec 0 12.730
    cut_subsOff
    
    cut_waitForFrameMinSec 0 16.016
    cut_swapAndShowBuf
    
    ; "sasaki caught you"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4D4E-6.bin"
    cut_waitForFrameMinSec 0 19.085
    cut_swapAndShowBuf
    
    ; "and look"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4D4E-7.bin"
    cut_waitForFrameMinSec 0 21.816
    cut_swapAndShowBuf
    
    ; "miss yuuko's safe too"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4D4E-8.bin"
    cut_waitForFrameMinSec 0 23.284
    cut_swapAndShowBuf
    
    ; "huh?"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4D4E-9.bin"
    cut_waitForFrameMinSec 0 24.960
    cut_swapAndShowBuf
    
      ; "she landed right on"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x4D4E-10.bin"
    
    cut_waitForFrameMinSec 0 25.960-0.170+0.033
    cut_subsOff
    
    cut_waitForFrameMinSec 0 26.580
    cut_swapAndShowBuf
    
      ; "miss yuuko..."
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x4D4E-11.bin"
    
    cut_waitForFrameMinSec 0 28.435
    cut_subsOff
    
    cut_waitForFrameMinSec 0 29.546
    cut_swapAndShowBuf
    
      ; "stupid girl"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x4D4E-12.bin"
    
    cut_waitForFrameMinSec 0 30.487
    cut_subsOff
    cut_waitForFrameMinSec 0 34.414
    cut_swapAndShowBuf
  
    ; "why did you try to"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4D4E-13.bin"
    cut_waitForFrameMinSec 0 37.031
    cut_swapAndShowBuf
  
      ; "well..."
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x4D4E-14.bin"
    
    cut_waitForFrameMinSec 0 40.703+0.200
    cut_subsOff
    cut_waitForFrameMinSec 0 41.682
    cut_swapAndShowBuf
    
    ; "i don't know"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4D4E-15.bin"
    cut_waitForFrameMinSec 0 43.405
    cut_swapAndShowBuf
  
    ; "i despised you"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4D4E-16.bin"
    cut_waitForFrameMinSec 0 45.872
    cut_swapAndShowBuf
  
      ; "but...somehow"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x4D4E-17.bin"
    
    cut_waitForFrameMinSec 0 50.505+0.200
    cut_subsOff
    
    cut_waitForFrameMinSec 0 51.832
    cut_swapAndShowBuf
  
    ; "as you fell"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4D4E-18.bin"
    cut_waitForFrameMinSec 0 54.101
    cut_swapAndShowBuf
  
      ; "and then my body"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x4D4E-19.bin"
    
    cut_waitForFrameMinSec 0 57.239+0.200
    cut_subsOff
    
    cut_waitForFrameMinSec 0 58.574
    cut_swapAndShowBuf
  
      ; "miss yuuko, you may"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x4D4E-20.bin"
    
    cut_waitForFrameMinSec 1 1.502+0.200
    cut_subsOff
    
    cut_waitForFrameMinSec 1 2.707
    cut_swapAndShowBuf
  
    ; NOTE: delay to avoid load transition
    cut_waitForFrameMinSec 1 3.846
    ; "please don't move"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4D4E-21.bin"
    cut_waitForFrameMinSec 1 5.494
    cut_swapAndShowBuf
  
    ; "it's fine"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4D4E-22.bin"
    cut_waitForFrameMinSec 1 7.387
    cut_swapAndShowBuf
  
    ; "i won't run away"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4D4E-23.bin"
    cut_waitForFrameMinSec 1 9.825
    cut_swapAndShowBuf
  
      ; "sorry, ayaka"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x4D4E-24.bin"
    
    cut_waitForFrameMinSec 1 11.510+0.200
    cut_subsOff
    
    cut_waitForFrameMinSec 1 12.348
    cut_swapAndShowBuf

    ; "i couldn't just"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4D4E-25.bin"
    cut_waitForFrameMinSec 1 14.834
    cut_swapAndShowBuf

    ; "may..."
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4D4E-26.bin"
    cut_waitForFrameMinSec 1 20.719
    cut_swapAndShowBuf

      ; "but..."
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x4D4E-27.bin"
    
    cut_waitForFrameMinSec 1 21.877+0.100
    cut_subsOff
    
    cut_waitForFrameMinSec 1 22.762
    cut_swapAndShowBuf

    ; "you'll forgive me, right"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4D4E-28.bin"
    cut_waitForFrameMinSec 1 24.268
    cut_swapAndShowBuf

      ; "ready to go, navi"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x4D4E-29.bin"
    
    cut_waitForFrameMinSec 1 26.538
    cut_subsOff
    
    cut_waitForFrameMinSec 1 28.939
    cut_swapAndShowBuf

    ; "yes!"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4D4E-30.bin"
    cut_waitForFrameMinSec 1 30.793
    cut_swapAndShowBuf
    
    cut_waitForFrameMinSec 1 31.793
    cut_subsOff
  
    ;=====
    ; done
    ;=====
    
    ; cropping off
    cut_setCropOn $00
    
    cut_terminator
.ends








