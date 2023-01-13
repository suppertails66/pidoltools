
.include "include/visual_base.inc"

;===================================
; ayaka death 2
;===================================

.redefine SYNC_offset 20

.bank freeBank slot freeSlot
.section "script data" free
  defaultSubtitleScriptPtr:
    ;=====
    ; init
    ;=====
    
;    SCENE_setUpAutoPlace $1C0 $14
    
    cut_setPalette $0D
    
    SYNC_varTime 1 $2F
    
    ; cropping on
    cut_setCropOn $01
  
    ;=====
    ; wait until safe start point
    ;=====
    
    cut_waitForFrameMinSec 0 1.000
  
    ;=====
    ; data
    ;=====
    
    ; "ayaka..."
    cut_startNewString $1C0
    .incbin "out/script/strings/visual-0x4C4E-0.bin"
    cut_waitForFrameMinSec 0 4.758
    cut_swapAndShowBuf
    
      ; "no..."
      cut_startNewString $1E8
      .incbin "out/script/strings/visual-0x4C4E-2.bin"
    
    cut_waitForFrameMinSec 0 5.828-0.100
    cut_subsOff
    
    cut_waitForFrameMinSec 0 21.314
    cut_swapAndShowBuf
    
    cut_waitForFrameMinSec 0 22.378
    cut_subsOff
    
    ; cropping off
    cut_setCropOn $00
    
    cut_terminator
.ends








