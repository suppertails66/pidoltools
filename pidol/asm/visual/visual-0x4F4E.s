
.include "include/visual_base.inc"

;===================================
; case 2a intro p3
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
    
    ; "a thirty-hour boat trip"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4F4E-0.bin"
    cut_waitForFrameMinSec 0 1.678
    cut_swapAndShowBuf
    
      ; "may..."
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x4F4E-1.bin"
    
    cut_waitForFrameMinSec 0 4.284
    cut_subsOff
    
    cut_waitForFrameMinSec 0 5.399
    cut_swapAndShowBuf
    
      ; "may"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x4F4E-2.bin"
    
    cut_waitForFrameMinSec 0 6.507
    cut_subsOff
    
    cut_waitForFrameMinSec 0 7.750
    cut_swapAndShowBuf
    
      ; "may!"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x4F4E-3.bin"
    
    cut_waitForFrameMinSec 0 8.771
    cut_subsOff
    
    cut_waitForFrameMinSec 0 9.950
    cut_swapAndShowBuf
    
      ; "what're you spacing out for"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x4F4E-5.bin"
    
    cut_waitForFrameMinSec 0 11.157
    cut_subsOff
    
    cut_waitForFrameMinSec 0 13.050
    cut_swapAndShowBuf
    
    ; "aren't we going to"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4F4E-6.bin"
    cut_waitForFrameMinSec 0 15.076
    cut_swapAndShowBuf
    
    ; "you were looking forward to"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4F4E-7.bin"
    cut_waitForFrameMinSec 0 16.873
    cut_swapAndShowBuf
    
    ; "sorry, sorry"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4F4E-8.bin"
    cut_waitForFrameMinSec 0 19.522
    cut_swapAndShowBuf
    
    ; "well then, ready to go"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4F4E-9.bin"
    cut_waitForFrameMinSec 0 21.066
    cut_swapAndShowBuf
    
    cut_waitForFrameMinSec 0 22.703
    cut_subsOff
  
    ;=====
    ; done
    ;=====
    
    ; cropping off
    cut_setCropOn $00
    
    cut_terminator
.ends








