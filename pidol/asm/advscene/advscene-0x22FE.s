
.include "include/advscene_base.inc"

;===================================
; case 2b getaway game over
;===================================

;.redefine SYNC_offset 15

.bank 0 slot 0
.section "script data" free
  scriptData:
    ;=====
    ; init
    ;=====
    
    SCENE_setUpAutoPlace $1B0 $20
  
    ;=====
    ; wait until safe start point
    ;=====
    
    ; FIXME: on the off chance the game loads additional resources off the cd
    ; after this script has been started, this naive wait is technically not safe
    ; (if a cd read stalls).
    ; i think issues are unlikely in practice, though.
    cut_waitForFrameMinSec 0 2.000
    
    cut_setPalette $0D
    
    ; "t-to come so far"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/advscene-0x22FE-0.bin"
  
    ;=====
    ; data
    ;=====
    
    cut_waitForFrameMinSec 0 6.55
    
    ; text box off
    SCENE_textBoxOff
    
    ; cropping on
;    cut_setCropOn $01
    
    SYNC_varTime 1 $01
    
    cut_waitForFrameMinSec 0 0.053
    cut_swapAndShowBuf
    
;    cut_waitForFrameMinSec 0 3.517
    cut_waitForFrameMinSec 0 4.031
    cut_subsOff
  
    ;=====
    ; done
    ;=====
    
    ; wait for end of scene
    cut_waitForFrameMinSec 0 4.031+2.000
    
    ; text box on
    SCENE_textBoxOn
    ; cropping off
;    cut_setCropOn $00
    
    cut_terminator
.ends








