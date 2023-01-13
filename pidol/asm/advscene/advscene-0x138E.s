
.include "include/advscene_base.inc"

;===================================
; case 2a ceiling
;===================================

;.redefine SYNC_offset 15

.bank 0 slot 0
.section "script data" free
  scriptData:
    ;=====
    ; init
    ;=====
    
    SCENE_setUpAutoPlace $1B0 $14
    
    ; text box off
    SCENE_textBoxOff
    
    ; cropping on
;    cut_setCropOn $01
    
    cut_setPalette $0D
    
    SYNC_varTime 1 $01
  
    ;=====
    ; wait until safe start point
    ;=====
    
    cut_waitForFrameMinSec 0 0.100
  
    ;=====
    ; data
    ;=====
    
    ; "the ceiling here in"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/advscene-0x138E-0.bin"
    cut_waitForFrameMinSec 0 1.203
    cut_swapAndShowBuf
    
    ; "is connected to"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/advscene-0x138E-1.bin"
    cut_waitForFrameMinSec 0 3.506
    cut_swapAndShowBuf
    
    ; "why don't i try"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/advscene-0x138E-2.bin"
    cut_waitForFrameMinSec 0 6.073
    cut_swapAndShowBuf
    
      ; "i-it's not opening"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/advscene-0x138E-3.bin"
    
    cut_waitForFrameMinSec 0 8.054-0.200
    cut_subsOff
    
    cut_waitForFrameMinSec 0 12.763
    cut_swapAndShowBuf
    
    ; "it won't open?"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/advscene-0x138E-4.bin"
    cut_waitForFrameMinSec 0 15.623
    cut_swapAndShowBuf
    
      ; "it'll open just a little"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/advscene-0x138E-5.bin"
    
    cut_waitForFrameMinSec 0 17.164
    cut_subsOff
    
    cut_waitForFrameMinSec 0 18.147
    cut_swapAndShowBuf
    
    ; "it's like there's something on"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/advscene-0x138E-6.bin"
    cut_waitForFrameMinSec 0 21.168
    cut_swapAndShowBuf
    
    ; "it won't open"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/advscene-0x138E-7.bin"
    cut_waitForFrameMinSec 0 24.836
    cut_swapAndShowBuf
    
    cut_waitForFrameMinSec 0 28.401
    cut_subsOff
  
    ;=====
    ; done
    ;=====
    
    ; wait for end of scene
    cut_waitForFrameMinSec 0 31.011-1.000
    
    ; text box on
    SCENE_textBoxOnWithDelay 119
    ; cropping off
;    cut_setCropOn $00
    
    cut_terminator
.ends








