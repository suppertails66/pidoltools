
.include "include/visual_base.inc"

;===================================
; case 1 ending p1
;===================================

;.redefine SYNC_offset 10

.bank freeBank slot freeSlot
.section "script data" free
  defaultSubtitleScriptPtr:
    ;=====
    ; init
    ;=====
    
    SCENE_setUpAutoPlace $1C0 $18
    
    cut_setPalette $0D
    
    SYNC_varTime 1 $01
    
    ; cropping on
    cut_setCropOn $01
  
    ;=====
    ; wait until safe start point
    ;=====
    
    cut_waitForFrameMinSec 0 1.000

    .redefine SYNC_offset -3
  
    ;=====
    ; data
    ;=====
    
    ; "yuuko!"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4CCE-1.bin"
    cut_waitForFrameMinSec 0 4.717
    cut_swapAndShowBuf
    
      ; "no...!"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x4CCE-2.bin"
    
    cut_waitForFrameMinSec 0 5.725
    cut_subsOff
    
    cut_waitForFrameMinSec 0 11.120
    cut_swapAndShowBuf
    
      ; "may! yuuko!"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x4CCE-4.bin"
    
    cut_waitForFrameMinSec 0 13.012-0.400
    cut_subsOff
    
    cut_waitForFrameMinSec 0 17.984
    cut_swapAndShowBuf
    
    cut_waitForFrameMinSec 0 20.300-0.100
    cut_subsOff
  
    ;=====
    ; done
    ;=====
    
    ; cropping off
    cut_setCropOn $00
    
    cut_terminator
.ends








