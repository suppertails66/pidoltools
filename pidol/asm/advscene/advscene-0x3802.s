
.include "include/advscene_base.inc"

;===================================
; case 3 sawada call
;===================================

;.redefine SYNC_offset 15

.bank 0 slot 0
.section "script data" free
  scriptData:
    ;=====
    ; init
    ;=====
    
    SCENE_setUpAutoPlace $1A0 $18
    
    ; text box off
    SCENE_textBoxOff
    
    ; cropping on
;    cut_setCropOn $01
    
    cut_setPalette $0D
    
    SYNC_varTime 1 $01
  
    ;=====
    ; wait until safe start point
    ;=====
    
    cut_waitForFrameMinSec 0 1.000
  
    ;=====
    ; data
    ;=====
    
    ; "hi, this is"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/advscene-0x3802-0.bin"
    cut_waitForFrameMinSec 0 4.009
    cut_swapAndShowBuf
    
    ; "hi, this is"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/advscene-0x3802-1.bin"
    cut_waitForFrameMinSec 0 5.734
    cut_swapAndShowBuf
    
      ; "hi, this is"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/advscene-0x3802-2.bin"
    
    cut_waitForFrameMinSec 0 6.979
    cut_subsOff
    cut_waitForFrameMinSec 0 7.610
    cut_swapAndShowBuf
    
      ; "what!? are you"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/advscene-0x3802-4.bin"
    
    cut_waitForFrameMinSec 0 9.459
    cut_subsOff
    cut_waitForFrameMinSec 0 15.214
    cut_swapAndShowBuf
    
    cut_waitForFrameMinSec 0 17.254
    cut_subsOff
  
    ;=====
    ; done
    ;=====
    
    ; wait for end of scene
    cut_waitForFrameMinSec 0 17.254
    
    ; text box on
    SCENE_textBoxOnWithDelay 60
    ; cropping off
;    cut_setCropOn $00
    
    cut_terminator
.ends








