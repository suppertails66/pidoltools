
.include "include/advscene_base.inc"

;===================================
; kanna missing
;===================================

.redefine SYNC_offset 10

.bank 0 slot 0
.section "script data" free
  scriptData:
    ;=====
    ; init
    ;=====
    
    ; text box off
    SCENE_textBoxOff
    
    ; cropping on
;    cut_setCropOn $01
    
    cut_setPalette $0D
    
    SYNC_varTime 1 $34
  
    ;=====
    ; wait until safe start point
    ;=====
    
;    cut_waitForFrame $0140
    cut_waitForFrameMinSec 0 0.900
  
    ;=====
    ; data
    ;=====
    
    ; "wh-what? what happened"
    cut_startNewString $01C0
    .incbin "out/script/strings/advscene-0xCC6-0.bin"
    cut_waitForFrameMinSec 0 1.093
    cut_swapAndShowBuf
    
    ; "motoko, what's wrong"
    cut_startNewString $01E8
    .incbin "out/script/strings/advscene-0xCC6-1.bin"
    cut_waitForFrameMinSec 0 3.126
;    cut_subsOff
    cut_swapAndShowBuf
    
      ; "a-a ghost"
      cut_startNewString $01C0
      .incbin "out/script/strings/advscene-0xCC6-2.bin"
    
    cut_waitForFrameMinSec 0 4.956
    cut_subsOff
    
    cut_waitForFrameMinSec 0 6.666
;    cut_subsOff
    cut_swapAndShowBuf
    
    ; "huh?"
    cut_startNewString $01E8
    .incbin "out/script/strings/advscene-0xCC6-3.bin"
    cut_waitForFrameMinSec 0 8.660
;    cut_subsOff
    cut_swapAndShowBuf
    
    ; "a...a ghost came"
    cut_startNewString $01C0
    .incbin "out/script/strings/advscene-0xCC6-4.bin"
    cut_waitForFrameMinSec 0 10.163
;    cut_subsOff
    cut_swapAndShowBuf
    
    ; "k-kanna"
    cut_startNewString $01E8
    .incbin "out/script/strings/advscene-0xCC6-5.bin"
    cut_waitForFrameMinSec 0 13.506
;    cut_subsOff
    cut_swapAndShowBuf
    
    ; "kanna's been"
    cut_startNewString $01C0
    .incbin "out/script/strings/advscene-0xCC6-6.bin"
    cut_waitForFrameMinSec 0 16.039
;    cut_subsOff
    cut_swapAndShowBuf
    
    cut_waitForFrameMinSec 0 18.202
    cut_subsOff
    
    ;=====
    ; fix things up so flash effect covers full screen
    ; (and not just on mainline mednafen)
    ;=====
    
    ; wait until motoko sprites are off-screen
    cut_waitForFrame $4A8
    
    ; set text box palette to black
    ; write to memory
    .rept 16 INDEX count
      cut_writeMemWord builtInMemPage ($1154+(count*2)) $0000
    .endr
    ; write to vce
    cut_writePalette ($3E0/2) 32
      .rept 16
        .dw $0000
      .endr
    
    ; cropping off so box area is shown
    cut_setCropOn $00
    
    ; wait for end of scene
;    .redefine SYNC_offset 0
;    cut_waitForFrame $620-60
    cut_waitForFrame $620-30
    
    ; cropping on
    cut_setCropOn $01
    ; text box on
    SCENE_textBoxOnWithDelay 74
    
;    cut_waitForFrame $620
    
    ; restore text box palette
    cut_writeMemWord builtInMemPage ($1154+(0*2))  $0000
    cut_writeMemWord builtInMemPage ($1154+(1*2))  $01B8
    cut_writeMemWord builtInMemPage ($1154+(2*2))  $0138
    cut_writeMemWord builtInMemPage ($1154+(3*2))  $00E8
    cut_writeMemWord builtInMemPage ($1154+(4*2))  $00A0
    cut_writeMemWord builtInMemPage ($1154+(5*2))  $0058
    cut_writeMemWord builtInMemPage ($1154+(6*2))  $0010
    cut_writeMemWord builtInMemPage ($1154+(7*2))  $0008
    cut_writeMemWord builtInMemPage ($1154+(8*2))  $0049
    cut_writeMemWord builtInMemPage ($1154+(9*2))  $008A
    cut_writeMemWord builtInMemPage ($1154+(10*2)) $0052
    cut_writeMemWord builtInMemPage ($1154+(11*2)) $0092
    cut_writeMemWord builtInMemPage ($1154+(12*2)) $004A
    cut_writeMemWord builtInMemPage ($1154+(13*2)) $0091
    cut_writeMemWord builtInMemPage ($1154+(14*2)) $0000
    cut_writeMemWord builtInMemPage ($1154+(15*2)) $01FF
    
    cut_terminator
.ends

;===================================
; patch flash effect to target
; text box palette
;===================================

.bank 0 slot 0
.org $18B
.section "text box flash 1" overwrite
  ; end index of range of palette overwrite
;  .db $1F
  .db $20
.ends

.bank 0 slot 0
.org $197
.section "text box flash 2" overwrite
  ; end index of range of palette overwrite
;  .db $1F
  .db $20
.ends

.bank 0 slot 0
.org $1A3
.section "text box flash 3" overwrite
  ; end index of range of palette overwrite
;  .db $1F
  .db $20
.ends

.bank 0 slot 0
.org $1AF
.section "text box flash 4" overwrite
  ; high byte of fade effect target palettes bitfield
;  .db $7F
  .db $FF
.ends



