
.include "include/advscene_base.inc"

;===================================
; case 3 ohtaki car
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
    
    ; "you're five minutes behind"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/advscene-0x3842-0.bin"
    cut_waitForFrameMinSec 0 1.893
    cut_swapAndShowBuf
    
      ; "the parade will be"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/advscene-0x3842-1.bin"
    
    cut_waitForFrameMinSec 0 4.433
    cut_subsOff
    cut_waitForFrameMinSec 0 5.327
    cut_swapAndShowBuf
    
      ; "sorry about that"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/advscene-0x3842-2.bin"
    
    cut_waitForFrameMinSec 0 8.595-0.154
    cut_subsOff
    cut_waitForFrameMinSec 0 8.854
    cut_swapAndShowBuf
    
    ; "there was a little"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/advscene-0x3842-3.bin"
    cut_waitForFrameMinSec 0 10.147
    cut_swapAndShowBuf
    
      ; "well, hurry along"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/advscene-0x3842-4.bin"
    
    cut_waitForFrameMinSec 0 11.841+0.067
    cut_subsOff
    cut_waitForFrameMinSec 0 12.640
    cut_swapAndShowBuf
    
      ; "(though i suppose)"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/advscene-0x3842-5.bin"
    
    cut_waitForFrameMinSec 0 16.920
    cut_subsOff
    cut_waitForFrameMinSec 0 18.331
    cut_swapAndShowBuf
    
      ; "(after all, the lady)"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/advscene-0x3842-6.bin"
    
    cut_waitForFrameMinSec 0 21.871
    cut_subsOff
    cut_waitForFrameMinSec 0 22.694
    cut_swapAndShowBuf
    
      ; "t-tachibana"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/advscene-0x3842-7.bin"
    
    cut_waitForFrameMinSec 0 26.809
    cut_subsOff
    cut_waitForFrameMinSec 0 32.700
    cut_swapAndShowBuf
    
    cut_waitForFrameMinSec 0 34.617
    cut_subsOff
  
    ;=====
    ; done
    ;=====
    
    ; wait for end of scene
    cut_waitForFrameMinSec 0 34.617+1.000
    
    ; text box on
    SCENE_textBoxOnWithDelay 119
    ; cropping off
;    cut_setCropOn $00
    
    cut_terminator
.ends








