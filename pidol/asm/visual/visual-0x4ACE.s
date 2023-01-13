
.include "include/visual_base.inc"

;===================================
; intro p2 -- oruka commercial
;===================================

; NOTE: uses cd audio -- see track 10

.redefine SYNC_offset 10

.bank freeBank slot freeSlot
.section "script data" free
  defaultSubtitleScriptPtr:
    ;=====
    ; init
    ;=====
    
    SCENE_setUpAutoPlace $1B0 $20
    
    cut_setPalette $0D
    
    SYNC_varTime 1 $0A
    
    ; cropping on
    cut_setCropOn $01
  
    ;=====
    ; wait until safe start point
    ;=====
    
    cut_waitForFrameMinSec 0 2.500
  
    ;=====
    ; data
    ;=====
    
    ; "computers are evolving"
;    cut_startNewString $01C0
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4ACE-0.bin"
    cut_waitForFrameMinSec 0 3.550
    cut_swapAndShowBuf
    
      ; "nice to meet you"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x4ACE-1.bin"
    
    cut_waitForFrameMinSec 0 5.702+0.034
    cut_subsOff
    cut_waitForFrameMinSec 0 10.778
;    cut_subsOff
    cut_swapAndShowBuf
    
    ; "i can't cook or clean"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4ACE-2.bin"
    cut_waitForFrameMinSec 0 13.280
    cut_swapAndShowBuf
    
      ; "computers have evolved"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x4ACE-3.bin"
    
    cut_waitForFrameMinSec 0 17.334+0.116
    cut_subsOff
    cut_waitForFrameMinSec 0 17.915
    cut_swapAndShowBuf
    
      ; "human and computer can"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x4ACE-4.bin"
    
    cut_waitForFrameMinSec 0 20.048
    cut_subsOff
    
    cut_waitForFrameMinSec 0 21.226
    cut_swapAndShowBuf
    
    ; "the multimedia interface"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4ACE-5.bin"
    cut_waitForFrameMinSec 0 24.168
    cut_swapAndShowBuf
    
      ; "oru ka"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x4ACE-6.bin"
    
    cut_waitForFrameMinSec 0 26.799
    cut_subsOff
    
    cut_waitForFrameMinSec 0 27.750
    cut_swapAndShowBuf
    
    cut_waitForFrameMinSec 0 31.434
    cut_subsOff
    
    ; cropping off
    cut_setCropOn $00
    
    cut_terminator
.ends








