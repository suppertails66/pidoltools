
.include "include/advscene_base.inc"

;===================================
; statue swings sword
;===================================

;.redefine SYNC_offset 60

.bank 0 slot 0
.section "script data" free
  scriptData:
    ;=====
    ; init
    ;=====
    
;    SCENE_setUpAutoPlace $1B0 $20
    
    cut_setPalette $0D
    
    cut_waitForFrameMinSec 0 0.100
    
    ; text box off
/*;    cut_writeMem builtInMemPage $136C $A8
    cut_writeMem builtInMemPage $136C $B0
;    cut_writeMem builtInMemPage $136C $B8
    cut_writeMem builtInMemPage $136C $C0
;    cut_writeMem builtInMemPage $136C $C8
    cut_writeMem builtInMemPage $136C $D0
;    cut_writeMem builtInMemPage $136C $D8
    cut_writeMem builtInMemPage $136C $E0
;    cut_writeMem builtInMemPage $136C $E8
    cut_writeMem builtInMemPage $136C $F0*/
    SCENE_textBoxOff
    
    SYNC_varTime 1 $38
    
    ; cropping on
;    cut_setCropOn $01
  
    ;=====
    ; wait until safe start point
    ;=====
    
;    cut_waitForFrame $0140
    cut_waitForFrameMinSec 0 1.000
  
    ;=====
    ; data
    ;=====
    
    ; "look out!"
;    SCENE_startNewStringAuto
    cut_startNewString $1B0
    .incbin "out/script/strings/advscene-0xB86-0.bin"
    cut_waitForFrameMinSec 0 1.718
    cut_swapAndShowBuf
    
      ; "i-i thought i was"
;      SCENE_startNewStringAuto
      cut_startNewString $1EC
      .incbin "out/script/strings/advscene-0xB86-2.bin"
    
    cut_waitForFrameMinSec 0 2.979
    cut_subsOff
    
    cut_waitForFrameMinSec 0 9.517
    cut_swapAndShowBuf
    
    cut_waitForFrameMinSec 0 11.941
    cut_subsOff
  
    ;=====
    ; done
    ;=====
    
    ; wait for end of scene
;    cut_waitForFrame $100
    cut_waitForFrameMinSec 0 12.900-0.750
    
    ; cropping off
;    cut_setCropOn $00
    
    ; text box on
    SCENE_textBoxOnWithDelay 90
/*;    cut_writeMem builtInMemPage $136C $E8
    cut_writeMem builtInMemPage $136C $E0
;    cut_writeMem builtInMemPage $136C $D8
    cut_writeMem builtInMemPage $136C $D0
;    cut_writeMem builtInMemPage $136C $C8
    cut_writeMem builtInMemPage $136C $C0
;    cut_writeMem builtInMemPage $136C $B8
    cut_writeMem builtInMemPage $136C $B0
;    cut_writeMem builtInMemPage $136C $A8
    cut_writeMem builtInMemPage $136C $A0*/
    
    cut_terminator
.ends
