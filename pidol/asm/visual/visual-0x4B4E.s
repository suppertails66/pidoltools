
.include "include/visual_base.inc"

;===================================
; intro p3 -- bus 2
;===================================

; NOTE: uses cd audio -- see track 11

.redefine SYNC_offset 10

.bank freeBank slot freeSlot
.section "script data" free
  defaultSubtitleScriptPtr:
    ;=====
    ; init
    ;=====
    
    SCENE_setUpAutoPlace $1B0 $20
    
    cut_setPalette $0D
    
    SYNC_varTime 1 $09
    
    ; cropping on
    cut_setCropOn $01
  
    ;=====
    ; wait until safe start point
    ;=====
    
    cut_waitForFrameMinSec 0 1.000
  
    ;=====
    ; data
    ;=====
    
    ; "neat"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4B4E-0.bin"
    cut_waitForFrameMinSec 0 1.318
    cut_swapAndShowBuf
    
    ; "ayaka wishes she could"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4B4E-1.bin"
    
    cut_waitForFrameMinSec 0 3.100
    cut_swapAndShowBuf
    
    ; "if she did"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4B4E-2.bin"
    cut_waitForFrameMinSec 0 5.920
    cut_swapAndShowBuf
    
    ; "and she'd get popular"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4B4E-3.bin"
    cut_waitForFrameMinSec 0 10.924
    cut_swapAndShowBuf
    
      ; "you're just insufferable"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x4B4E-4.bin"
    
    cut_waitForFrameMinSec 0 12.803
    cut_subsOff
    
    cut_waitForFrameMinSec 0 13.853
    cut_swapAndShowBuf
    
      ; "i get it"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x4B4E-5.bin"
    
    cut_waitForFrameMinSec 0 16.111
    cut_subsOff
    
    cut_waitForFrameMinSec 0 20.493
    cut_swapAndShowBuf
  
    ; "oh, motoko, you're"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4B4E-6.bin"
    cut_waitForFrameMinSec 0 22.580
    cut_swapAndShowBuf
  
    ; "wha--!?"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4B4E-7.bin"
    cut_waitForFrameMinSec 0 26.986
    cut_swapAndShowBuf
    
    cut_waitForFrameMinSec 0 27.974
    cut_subsOff
  
      ; NOTE: avoiding load transition
      ; "i can't stand"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x4B4E-8.bin"
    
    cut_waitForFrameMinSec 0 29.744
    cut_swapAndShowBuf
  
    ; "oh! she's hysterical"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4B4E-9.bin"
    cut_waitForFrameMinSec 0 33.906
    cut_swapAndShowBuf
  
    ; "what was that!?"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4B4E-10.bin"
    cut_waitForFrameMinSec 0 35.407
    cut_swapAndShowBuf
  
    ; "you'd better stop"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4B4E-11.bin"
    cut_waitForFrameMinSec 0 37.263
    cut_swapAndShowBuf
  
      ; "get too excited and"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x4B4E-12.bin"
    
;    cut_waitForFrameMinSec 0 38.849
;    cut_subsOff
    cut_waitForFrameMinSec 0 38.813
    cut_subsOff
    cut_waitForFrameMinSec 0 39.960
    cut_swapAndShowBuf
  
      ; "look..."
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x4B4E-13.bin"
    
    cut_waitForFrameMinSec 0 42.731
    cut_subsOff
    
    cut_waitForFrameMinSec 0 43.817
    cut_swapAndShowBuf
    
    cut_waitForFrameMinSec 0 45.013
    cut_subsOff
  
      ; "behind you, motoko..."
      cut_waitForFrameMinSec 0 45.800
;      cut_startNewString $01D8
      cut_startNewString $0084
      .incbin "out/script/strings/visual-0x4B4E-14.bin"
    
    cut_waitForFrameMinSec 0 46.160
    cut_swapAndShowBuf
  
    ; "...is an evil spirit"
;    cut_startNewString $01E0
    cut_startNewString $0094
    .incbin "out/script/strings/visual-0x4B4E-15.bin"
    cut_waitForFrameMinSec 0 48.064
    cut_swapAndShowBuf
    
    cut_waitForFrameMinSec 0 49.590
    cut_subsOff
  
      ; "e...evil spirit?"
      cut_waitForFrameMinSec 0 50.500
      cut_startNewString $01E0
      .incbin "out/script/strings/visual-0x4B4E-16.bin"
    
    cut_waitForFrameMinSec 0 51.006
    cut_swapAndShowBuf
    
    cut_waitForFrameMinSec 0 53.825
    cut_subsOff
  
      ; "k-kanna!"
      cut_startNewString $0060
      .incbin "out/script/strings/visual-0x4B4E-18.bin"
    
    cut_waitForFrameMinSec 0 54.972
    cut_swapAndShowBuf
    
    cut_waitForFrameMinSec 0 56.352
    cut_subsOff
  
      ; "don't say ridiculous stuff"
      cut_startNewString $01EA
      .incbin "out/script/strings/visual-0x4B4E-19.bin"
    
    cut_waitForFrameMinSec 0 58.683
    cut_swapAndShowBuf
    
    SCENE_setUpAutoPlace $1B0 $20
  
    ; "you phony psychic"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4B4E-20.bin"
    cut_waitForFrameMinSec 1 2.027
    cut_swapAndShowBuf
  
    ; "hey! kanna!"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4B4E-21.bin"
    cut_waitForFrameMinSec 1 4.322
    cut_swapAndShowBuf
  
    ; "if something like that"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4B4E-22.bin"
    cut_waitForFrameMinSec 1 7.458
    cut_swapAndShowBuf
  
    ; "there's no way you'll"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4B4E-23.bin"
    cut_waitForFrameMinSec 1 10.363
    cut_swapAndShowBuf
    
    cut_waitForFrameMinSec 1 13.476
    cut_subsOff
    
    ; cropping off
    cut_setCropOn $00
    
    cut_terminator
.ends








