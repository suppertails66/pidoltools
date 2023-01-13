
.include "include/visual_base.inc"

;===================================
; case 2a ending
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
    
    ; "even though the case"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4FCE-0.bin"
    cut_waitForFrameMinSec 0 8.382
    cut_swapAndShowBuf
    
    ; "yeah"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4FCE-1.bin"
    cut_waitForFrameMinSec 0 12.957
    cut_swapAndShowBuf
    
    ; "try talking"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4FCE-2.bin"
    cut_waitForFrameMinSec 0 14.247
    cut_swapAndShowBuf
    
      ; "i'm wondering...am i"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x4FCE-3.bin"
    
    cut_waitForFrameMinSec 0 15.844
    cut_subsOff
    cut_waitForFrameMinSec 0 17.348
    cut_swapAndShowBuf
    
      ; "looking at kihara's"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x4FCE-4.bin"
    
    cut_waitForFrameMinSec 0 21.294
    cut_subsOff
    cut_waitForFrameMinSec 0 22.123
    cut_swapAndShowBuf
    
    ; "it made it seem"
    SCENE_startNewStringAuto
    ; NOTE: delaying to avoid load transition
    cut_waitForFrameMinSec 0 22.767+0.500
    .incbin "out/script/strings/visual-0x4FCE-5.bin"
    ; NOTE: splitting to avoid load transition
;    .incbin "out/script/strings/visual-0x4FCE-5.bin" READ 5
;    cut_waitForFrameMinSec 0 22.767
;    .incbin "out/script/strings/visual-0x4FCE-5.bin" SKIP 5
;    cut_waitForFrameMinSec 0 23.965
    cut_waitForFrameMinSec 0 26.636
    cut_swapAndShowBuf
    
    ; "...seem like i'd just"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4FCE-6.bin"
;    cut_waitForFrameMinSec 0 29.354
    cut_waitForFrameMinSec 0 28.724
    cut_swapAndShowBuf
    
      ; "i feel like maybe"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x4FCE-7.bin"
    
    cut_waitForFrameMinSec 0 31.349
    cut_subsOff
    cut_waitForFrameMinSec 0 32.194
    cut_swapAndShowBuf
    
      ; ? avoid adpcm lag issues?
      cut_waitForFrameMinSec 0 35.194
      ; "is it really okay"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x4FCE-8.bin"
    
    cut_waitForFrameMinSec 0 37.183
    cut_subsOff
    cut_waitForFrameMinSec 0 38.565
    cut_swapAndShowBuf
    
      ; "what're you"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x4FCE-9.bin"
    
    cut_waitForFrameMinSec 0 41.175
    cut_subsOff
    cut_waitForFrameMinSec 0 41.866
    cut_swapAndShowBuf
    
    ; "the ring's been returned"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4FCE-10.bin"
    cut_waitForFrameMinSec 0 44.230
    cut_swapAndShowBuf
    
    ; "...just had a sudden"
    SCENE_startNewStringAuto
    ; NOTE: delaying to avoid fade flicker
    cut_waitForFrameMinSec 0 45.230
    .incbin "out/script/strings/visual-0x4FCE-11.bin"
    cut_waitForFrameMinSec 0 49.235
    cut_swapAndShowBuf
    
      ; "so c'mon"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x4FCE-12.bin"
    
    cut_waitForFrameMinSec 0 53.963
    cut_subsOff
    cut_waitForFrameMinSec 0 55.268
    cut_swapAndShowBuf
    
      ; "...you're right"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x4FCE-13.bin"
    
    cut_waitForFrameMinSec 0 57.847
    cut_subsOff
    cut_waitForFrameMinSec 0 58.968
    cut_swapAndShowBuf
    
    ; "thank you, motoko"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4FCE-14.bin"
    cut_waitForFrameMinSec 1 0.672
    cut_swapAndShowBuf
    
    ; "wh-what's the"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4FCE-16.bin"
    cut_waitForFrameMinSec 1 2.254
    cut_swapAndShowBuf
    
      ; "you were too worked up"
      SCENE_startNewStringAuto
      ; NOTE: delaying to avoid load transition
      cut_waitForFrameMinSec 1 2.254+1.500
      .incbin "out/script/strings/visual-0x4FCE-17.bin"
    
    cut_waitForFrameMinSec 1 5.739
    cut_subsOff
    cut_waitForFrameMinSec 1 6.783
    cut_swapAndShowBuf
    
      ; "you're right"
      SCENE_startNewStringAuto
      ; NOTE: delaying to avoid load transition
      cut_waitForFrameMinSec 1 6.783+1.500
      .incbin "out/script/strings/visual-0x4FCE-19.bin"
    
    cut_waitForFrameMinSec 1 10.099
    cut_subsOff
    cut_waitForFrameMinSec 1 11.189
    cut_swapAndShowBuf
    
    ; "guess i'll have to"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4FCE-20.bin"
    cut_waitForFrameMinSec 1 12.709
    cut_swapAndShowBuf
    
    ; "you said it"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4FCE-21.bin"
    cut_waitForFrameMinSec 1 17.023
    cut_swapAndShowBuf
    
      ; "all right"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x4FCE-22.bin"
    
    cut_waitForFrameMinSec 1 18.696
    cut_subsOff
    cut_waitForFrameMinSec 1 19.218
    cut_swapAndShowBuf
    
    ; "when we get to"
/*    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4FCE-23.bin"
    cut_waitForFrameMinSec 1 20.170
    cut_swapAndShowBuf*/
    
    ; "i'm gonna seriously"
    SCENE_startNewStringAuto
    ; NOTE: delaying to avoid load transition
    cut_waitForFrameMinSec 1 19.218+1.250
    .incbin "out/script/strings/visual-0x4FCE-24.bin"
    cut_waitForFrameMinSec 1 21.367
    cut_swapAndShowBuf
    
    ; "better get ready"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4FCE-25.bin"
    cut_waitForFrameMinSec 1 25.409
    cut_swapAndShowBuf
    
    ; "yes, yes"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4FCE-26.bin"
    cut_waitForFrameMinSec 1 27.140
    cut_swapAndShowBuf
    
    ; "i look forward to it"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4FCE-27.bin"
    cut_waitForFrameMinSec 1 28.437
    cut_swapAndShowBuf
    
    cut_waitForFrameMinSec 1 29.965
    cut_subsOff
  
    ;=====
    ; done
    ;=====
    
    ; cropping off
    cut_setCropOn $00
    
    cut_terminator
.ends








