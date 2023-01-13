
.include "include/visual_base.inc"

;===================================
; case 3 sakaki arrest
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
    
    ; "while i'm deeply"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x524E-0.bin"
    
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
    
    cut_waitForFrameMinSec 0 1.208
    cut_swapAndShowBuf
    
    ; "i'm afraid i simply"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x524E-1.bin"
    cut_waitForFrameMinSec 0 6.160
    cut_swapAndShowBuf
    
      ; "sakaki"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x524E-2.bin"
    
    cut_waitForFrameMinSec 0 9.616
    cut_subsOff
    cut_waitForFrameMinSec 0 10.733
    cut_swapAndShowBuf
    
      ; "i must say"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x524E-3.bin"
    
    cut_waitForFrameMinSec 0 11.899
    cut_subsOff
    cut_waitForFrameMinSec 0 13.191
    cut_swapAndShowBuf
    
    ; "keeping tabs on you"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x524E-4.bin"
    cut_waitForFrameMinSec 0 15.169
    cut_swapAndShowBuf
    
    ; "thanks to you"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x524E-6.bin"
    cut_waitForFrameMinSec 0 21.743
    cut_swapAndShowBuf
    
;    cut_waitForFrameMinSec 0 26.311
;    cut_subsOff
    ; "isn't it a little early"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x524E-7.bin"
    cut_waitForFrameMinSec 0 26.701
    cut_swapAndShowBuf
    
    ; "i'm the one who"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x524E-8.bin"
    cut_waitForFrameMinSec 0 30.115
    cut_swapAndShowBuf
    
      ; "it's all the same"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x524E-9.bin"
    
    cut_waitForFrameMinSec 0 32.561-0.051
    cut_subsOff
    cut_waitForFrameMinSec 0 33.053
    cut_swapAndShowBuf
    
      ; "you're going to die"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x524E-10.bin"
    
    cut_waitForFrameMinSec 0 34.628
    cut_subsOff
    cut_waitForFrameMinSec 0 35.596
    cut_swapAndShowBuf
    
      ; "just like your"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x524E-11.bin"
    
    cut_waitForFrameMinSec 0 38.895
    cut_subsOff
    cut_waitForFrameMinSec 0 39.748
    cut_swapAndShowBuf
    
      ; "pesky fly"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x524E-12.bin"
    
    cut_waitForFrameMinSec 0 42.405-0.150
    cut_subsOff
    cut_waitForFrameMinSec 0 44.983-0.040
    cut_swapAndShowBuf
    
      ; "i won't let you"
;      SCENE_startNewStringAuto
      cut_startNewString $1E8
      .incbin "out/script/strings/visual-0x524E-13.bin"
    
    ; NOTE: there's a rather obvious coloring error in this scene where
    ; sakaki's gun and arm are drawn with an all-black palette instead
    ; of the intended one. this also occurs in the original game.
    ; if i was subtitling an actual anime, no one would expect me to be
    ; "correcting" errors like this, however blatant, so i'm not
    ; doing it here either. (let the record show i also didn't fix mai's
    ; mangled hand in the yuna 2 ending)
    
    cut_waitForFrameMinSec 0 46.034
    cut_subsOff
    cut_waitForFrameMinSec 0 50.217
    cut_swapAndShowBuf
    
      ; "o-outta the way"
  ;    SCENE_startNewStringAuto
      cut_startNewString $1A
      .incbin "out/script/strings/visual-0x524E-14.bin"
    
;    cut_waitForFrameMinSec 0 51.107
;    cut_subsOff
    cut_waitForFrameMinSec 0 51.527
    cut_swapAndShowBuf
    
    cut_waitForFrameMinSec 0 52.591-0.027
    cut_subsOff
    
    ; NOTE: game needs to use most of vram for the tackle scene here,
    ; so we wait until it's done to start the next line
    cut_waitForFrameMinSec 1 1.000
    
    ; "you..."
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x524E-15.bin"
    cut_waitForFrameMinSec 1 2.381
    cut_swapAndShowBuf
    
    ; "you killed my"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x524E-16.bin"
    cut_waitForFrameMinSec 1 4.538
    cut_swapAndShowBuf
    
    cut_waitForFrameMinSec 1 6.750
    cut_subsOff
  
    ;=====
    ; done
    ;=====
    
    ; cropping off
    cut_setCropOn $00
    
    cut_terminator
.ends








