
.include "include/advscene_base.inc"

;===================================
; motoko shower
;===================================

.redefine SYNC_offset 15

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
    
    SYNC_varTime 1 $39
  
    ;=====
    ; wait until safe start point
    ;=====
    
;    cut_waitForFrame $0140
    cut_waitForFrameMinSec 0 1.000
  
    ;=====
    ; data
    ;=====
    
    ; "h-hey!"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/advscene-0xD06-0.bin"
    cut_waitForFrameMinSec 0 5.742
    cut_swapAndShowBuf
    
    ; "oh, sorry"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/advscene-0xD06-1.bin"
    cut_waitForFrameMinSec 0 7.164
    cut_swapAndShowBuf
    
    ; "d-d-d-d-d-don't give me"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/advscene-0xD06-2.bin"
    cut_waitForFrameMinSec 0 8.807
    cut_swapAndShowBuf
    
    ; "g-get..."
    SCENE_startNewStringAuto
    .incbin "out/script/strings/advscene-0xD06-3.bin"
    cut_waitForFrameMinSec 0 12.925
    cut_swapAndShowBuf
    
    ; NOTE: delay -- previous subtitle tiles are getting overwritten
    ; too soon for some reason, making them briefly visible
    ; at the end of the previous line?
    ; is sprite table refresh simply being delayed in this scene
    ; or is there some more general issue?
    cut_waitForFrameMinSec 0 13.500
    ; "get out of here"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/advscene-0xD06-4.bin"
    cut_waitForFrameMinSec 0 14.790
    cut_swapAndShowBuf
    
    cut_waitForFrameMinSec 0 16.581+0.200
    cut_subsOff
  
    ;=====
    ; done
    ;=====
    
    ; wait for end of scene
    cut_waitForFrameMinSec 0 18.200
    
    ; text box on
    SCENE_textBoxOnWithDelay 60
    ; cropping off
;    cut_setCropOn $00
    
    cut_terminator
.ends








