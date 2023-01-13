
.include "include/visual_base.inc"

;===================================
; ayaka death 1
;===================================

;.redefine SYNC_offset 10

.bank freeBank slot freeSlot
.section "script data" free
  defaultSubtitleScriptPtr:
    ;=====
    ; init
    ;=====
    
    SCENE_setUpAutoPlace $1C0 $14
    
    cut_setPalette $0D
    
    SYNC_varTime 1 $01
    
    ; cropping on
    cut_setCropOn $01
  
    ;=====
    ; wait until safe start point
    ;=====
    
    cut_waitForFrameMinSec 0 0.100
  
    ;=====
    ; data
    ;=====
    
    ; "-- ayaka! -- no!"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4BCE-1.bin"
    cut_waitForFrameMinSec 0 1.129
    cut_swapAndShowBuf
    
    ; "ayaka!"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4BCE-3.bin"
    
    cut_waitForFrameMinSec 0 2.835
    cut_swapAndShowBuf
    
      ; "ayaka!"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x4BCE-5.bin"
    
    cut_waitForFrameMinSec 0 4.113-0.300+0.067
    cut_subsOff
    
    cut_waitForFrameMinSec 0 9.412
    cut_swapAndShowBuf
    
    cut_waitForFrameMinSec 0 12.207-1.416
    cut_subsOff
    
    ; cropping off
    cut_setCropOn $00
    
    cut_terminator
.ends








