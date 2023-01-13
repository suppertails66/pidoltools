
.include "include/visual_base.inc"

;===================================
; intro p1 -- bus 1
;===================================

; NOTE: uses cd audio -- see track 09

.redefine SYNC_offset 10

.bank freeBank slot freeSlot
.section "script data" free
  defaultSubtitleScriptPtr:
    ;=====
    ; init
    ;=====
    
    SCENE_setUpAutoPlace $1B0 $20
    
    ; text box off
;    cut_writeMem builtInMemPage $11C0 $00
    
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
    
    ; "this is navi"
;    cut_startNewString $01C0
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4A4E-0.bin"
    cut_waitForFrameMinSec 0 3.109
    cut_swapAndShowBuf
    
    ; "cute!"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4A4E-1.bin"
    cut_waitForFrameMinSec 0 5.015
;    cut_subsOff
    cut_swapAndShowBuf
    
    ; "ah! nice to to meet"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4A4E-2.bin"
    cut_waitForFrameMinSec 0 6.707
    cut_swapAndShowBuf
    
    ; "she still can't talk very"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4A4E-3.bin"
    cut_waitForFrameMinSec 0 8.882
    cut_swapAndShowBuf
    
    ; "she's improved a lot"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4A4E-4.bin"
    cut_waitForFrameMinSec 0 11.432
    cut_swapAndShowBuf
    
      ; "is navi's speech"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x4A4E-5.bin"
    
    cut_waitForFrameMinSec 0 13.499+0.133
    cut_subsOff
    cut_waitForFrameMinSec 0 14.150
    cut_swapAndShowBuf
    
      ; "that's an artificial"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x4A4E-6.bin"
    
    cut_waitForFrameMinSec 0 16.947
    cut_subsOff
    
    cut_waitForFrameMinSec 0 19.168
    cut_swapAndShowBuf
    
      ; "i see it in"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x4A4E-7.bin"
    
    cut_waitForFrameMinSec 0 22.790
    cut_subsOff
      
    cut_waitForFrameMinSec 0 24.094
    cut_swapAndShowBuf
    
    ; "i didn't think it could"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4A4E-8.bin"
    cut_waitForFrameMinSec 0 28.074
    cut_swapAndShowBuf
    
    ; "'hologram'?"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4A4E-9.bin"
    cut_waitForFrameMinSec 0 31.505
    cut_swapAndShowBuf
    
    ; "a three-dimensional image"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4A4E-10.bin"
    cut_waitForFrameMinSec 0 33.335
    cut_swapAndShowBuf
    
      ; "miss yuuko"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x4A4E-11.bin"
    
    cut_waitForFrameMinSec 0 35.096
    cut_subsOff
      
    cut_waitForFrameMinSec 0 36.903-0.050
    cut_swapAndShowBuf
    
    ; "in other words"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4A4E-12.bin"
    cut_waitForFrameMinSec 0 38.153
    cut_swapAndShowBuf
    
    ; "ooh..."
;    SCENE_startNewStringAuto
;    .incbin "out/script/strings/visual-0x4A4E-13.bin"
;    cut_waitForFrameMinSec 0 43.513
;    cut_swapAndShowBuf
    
      ; !! wait for graphics load to finish
  ;    cut_waitForFrameMinSec 0 44.513
      ; "miss yuuko, you're so"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x4A4E-14.bin"
    
    cut_waitForFrameMinSec 0 43.513
    cut_subsOff
    
    cut_waitForFrameMinSec 0 45.122
    cut_swapAndShowBuf
    
      ; "it's that commercial"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x4A4E-15.bin"
    
    cut_waitForFrameMinSec 0 47.730
    cut_subsOff
    
;    cut_waitForFrameMinSec 0 48.050
    cut_waitForFrameMinSec 0 48.873
    cut_swapAndShowBuf
    
    cut_waitForFrameMinSec 0 51.336-0.200
    cut_subsOff
    
    ; cropping off
    cut_setCropOn $00
    ; text box on
;    cut_writeMem builtInMemPage $11C0 $05
    
    cut_terminator
.ends








