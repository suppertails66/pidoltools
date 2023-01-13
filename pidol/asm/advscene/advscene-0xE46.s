
.include "include/advscene_base.inc"

;===================================
; yuuko shower
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
    
    SYNC_varTime 1 $37
  
    ;=====
    ; wait until safe start point
    ;=====
    
;    cut_waitForFrame $0140
    cut_waitForFrameMinSec 0 2.000
  
    ;=====
    ; data
    ;=====
    
    ; "ooh"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/advscene-0xE46-0.bin"
    cut_waitForFrameMinSec 0 3.916
    cut_swapAndShowBuf
    
      ; "what's the 'ooh' for"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/advscene-0xE46-1.bin"
    
    cut_waitForFrameMinSec 0 5.477
    cut_subsOff
    
    cut_waitForFrameMinSec 0 6.244
    cut_swapAndShowBuf
    
    cut_waitForFrameMinSec 0 9.188-0.100
    cut_subsOff
    
    ; i was originally going to subtitle this, but due to an overcomplicated
    ; issue involving cd interrupts and probably poor emulation in mainline mednafen,
    ; there's a 1-frame glitch here that isn't my fault, sort of.
    ; so i've just taken it out.
    ; the problem will probably occur elsewhere, though.
    ; "(sigh)"
;    SCENE_startNewStringAuto
;    .incbin "out/script/strings/advscene-0xE46-2.bin"
;    cut_waitForFrameMinSec 0 9.188
;    cut_swapAndShowBuf
    
    ; "having someone like THIS"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/advscene-0xE46-3.bin"
    cut_waitForFrameMinSec 0 10.393
    cut_swapAndShowBuf
    
    cut_waitForFrameMinSec 0 14.584
    cut_subsOff
  
    ;=====
    ; done
    ;=====
    
    ; wait for end of scene
    cut_waitForFrameMinSec 0 16.843-1.000
    
    ; text box on
    SCENE_textBoxOnWithDelay 90
    ; cropping off
;    cut_setCropOn $00
    
    cut_terminator
.ends








