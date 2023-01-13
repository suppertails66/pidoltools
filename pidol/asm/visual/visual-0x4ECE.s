
.define useVsyncBgSprOffHack 1

.include "include/visual_base.inc"

;===================================
; case 2a intro p2
;===================================

;.redefine SYNC_offset 10

.bank freeBank slot freeSlot
.section "script data" free
  defaultSubtitleScriptPtr:
    ;=====
    ; init
    ;=====
    
    SCENE_setUpAutoPlace $1C8 $14
    
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
    
    ; "the ocean's pretty"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4ECE-0.bin"
    cut_waitForFrameMinSec 0 14.443
    cut_swapAndShowBuf
    
    cut_waitForFrameMinSec 0 15.999
    cut_subsOff
    
    ; NOTE: working around timing issues?
    ; "a trip!?"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4ECE-1.bin"
    cut_waitForFrameMinSec 0 19.760
    cut_swapAndShowBuf
    
    ; "yep! a thirty-hour"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4ECE-2.bin"
    ; NOTE: the palette fade here apparently eats up enough vblank time
    ; that trying to render during it causes some minor flicker at the
    ; top of the screen; splitting this line up to avoid it
;    .incbin "out/script/strings/visual-0x4ECE-2.bin" READ 10
;    cut_waitForFrameMinSec 0 20.200+0.500
;    .incbin "out/script/strings/visual-0x4ECE-2.bin" SKIP 10
    cut_waitForFrameMinSec 0 21.200
    cut_swapAndShowBuf
    
    ; "in the shining seas"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4ECE-4.bin"
    cut_waitForFrameMinSec 0 24.091
    cut_swapAndShowBuf
    
    ; "we'll swim and eat and play"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4ECE-5.bin"
    cut_waitForFrameMinSec 0 26.285
    cut_swapAndShowBuf
    
      ; "motoko..."
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x4ECE-6.bin"
    
    cut_waitForFrameMinSec 0 29.141-0.240+0.067
    cut_subsOff
    cut_waitForFrameMinSec 0 29.141
    cut_swapAndShowBuf
    
    ; "hasn't your personality"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4ECE-7.bin"
    cut_waitForFrameMinSec 0 30.964
    cut_swapAndShowBuf
    
      ; "oh, you wound me"
      cut_startNewString $1A0
      .incbin "out/script/strings/visual-0x4ECE-8.bin"
    
    cut_waitForFrameMinSec 0 34.440-0.300+0.050
    cut_subsOff
    cut_waitForFrameMinSec 0 34.440
    cut_swapAndShowBuf
    
    SCENE_setUpAutoPlace $1B0 $20
    
      ; "i've aimed to be"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x4ECE-9.bin"
    
    cut_waitForFrameMinSec 0 36.316
    cut_subsOff
    
    cut_waitForFrameMinSec 0 37.105
    cut_swapAndShowBuf
    
      ; "but anyway, may"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x4ECE-10.bin"
    
    cut_waitForFrameMinSec 0 42.191+0.400
    cut_subsOff
    
    cut_waitForFrameMinSec 0 44.118
    cut_swapAndShowBuf
    
    ; "how long are you going to"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4ECE-11.bin"
    cut_waitForFrameMinSec 0 46.045
    cut_swapAndShowBuf
    
    ; "i-i'm not..."
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4ECE-12.bin"
    cut_waitForFrameMinSec 0 48.843
    cut_swapAndShowBuf
    
      ; "look, i get that what happened"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x4ECE-14.bin"
    
    cut_waitForFrameMinSec 0 52.152-0.300
    cut_subsOff
    
    cut_waitForFrameMinSec 0 53.522
    cut_swapAndShowBuf
    
    ; "but you know"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4ECE-15.bin"
    cut_waitForFrameMinSec 0 57.771
    cut_swapAndShowBuf
    
      ; "...that's right"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x4ECE-16.bin"
    
    cut_waitForFrameMinSec 1 2.264-0.060
    cut_subsOff
    
    cut_waitForFrameMinSec 1 3.866
    cut_swapAndShowBuf
    
    ; "c'mon"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4ECE-17.bin"
    cut_waitForFrameMinSec 1 5.225
    cut_swapAndShowBuf
    
    ; "don't feel bad!"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4ECE-18.bin"
    cut_waitForFrameMinSec 1 7.884
    cut_swapAndShowBuf
    
    cut_waitForFrameMinSec 1 11.599
    cut_subsOff
  
    ;=====
    ; done
    ;=====
    
    ; cropping off
    cut_setCropOn $00
    
    cut_terminator
.ends








