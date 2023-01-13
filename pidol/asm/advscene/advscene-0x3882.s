
.include "include/advscene_base.inc"

;===================================
; case 3 ohtaki parking lot
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
    
    ; "you're"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/advscene-0x3882-0.bin"
    cut_waitForFrameMinSec 0 7.471
    cut_swapAndShowBuf
    
      ; "tsuyoshi ohtaki"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/advscene-0x3882-1.bin"
    
    cut_waitForFrameMinSec 0 8.643
    cut_subsOff
    cut_waitForFrameMinSec 0 9.781
    cut_swapAndShowBuf
    
      ; "i will"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/advscene-0x3882-2.bin"
    
    cut_waitForFrameMinSec 0 11.174
    cut_subsOff
    cut_waitForFrameMinSec 0 12.224
    cut_swapAndShowBuf
    
      ; "...never forgive you"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/advscene-0x3882-3.bin"
    
;    cut_waitForFrameMinSec 0 11.174
;    cut_subsOff
    cut_waitForFrameMinSec 0 13.829
    cut_swapAndShowBuf
    
    cut_waitForFrameMinSec 0 15.362+0.300
    cut_subsOff
  
    ;=====
    ; done
    ;=====
    
    ; wait for end of scene
    cut_waitForFrameMinSec 0 16.390
    
    ; text box on
    SCENE_textBoxOnWithDelay 119
    ; cropping off
;    cut_setCropOn $00
    
    cut_terminator
.ends
