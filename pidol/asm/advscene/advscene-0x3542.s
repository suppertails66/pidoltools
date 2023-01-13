
.include "include/advscene_base.inc"

;===================================
; case 3 newspaper clippings
;===================================

;.redefine SYNC_offset 15

.define extraStartDelay 0

;=====
; delay longer before starting first newspaper clip
;=====

; HACK: adjust length of time some clips are shown to allow time
; for subtitles.
; the first clip pops up so fast we don't have time to generate subtitles
; before it appears, while the last one is only displayed for half a second
; before the game starts in with dialogue.
.bank 0 slot 0
.org $E0
.section "first clip delay 1" overwrite
  ; jump to new content
  .db $01
    .db $04
    .dw (firstClipExtraContent&$1FFF)-$4
.ends

.bank 0 slot 0
.section "first clip delay 2" free
  firstClipExtraContent:
    ; make up work
    .db $41
      .db $00,$00,$00,$00

    ; delay
    .db $06
      .dw 90+extraStartDelay
    
    ; jump back to regular content
    .db $01
      .db $04
      .dw $00E5-$4
.ends

;=====
; show last clip longer before continuing with dialogue
;=====

.bank 0 slot 0
.org $170
.section "last clip delay 1" overwrite
  ; delay as long as other clips
;  .dw $1E
  .dw $96
.ends

;=====
; script data
;=====

.bank 0 slot 0
.section "script data" free
  scriptData:
    ;=====
    ; init
    ;=====
    
    SCENE_setUpAutoPlace $1A0 $18
    
    ; terminate script before doing anything if $270F & 0x02 nonzero.
    ; this condition indicates that the "article-by-article" intro
    ; is being skipped.
;    cut_terminateIfMasked $270F $02
    cut_jumpIfMaskedEq $270F $02 $02 @done
    
    ; text box off
    SCENE_textBoxOff
    
    ; cropping on
;    cut_setCropOn $01
    
    cut_setPalette $0C
    
;    SYNC_varTime 1 $01
  
    ;=====
    ; wait until safe start point
    ;=====
    
    cut_waitForFrameMinSec 0 0.300
;    cut_waitForFrameMinSec $1C
    
    ; ""
    SCENE_startNewStringAuto
    .incbin "out/script/strings/advscene-0x3542-0.bin"
  
    ;=====
    ; data
    ;=====
    
    cut_waitForFrame $6C+extraStartDelay-3
    cut_swapAndShowBuf
    
    ; ""
    SCENE_startNewStringAuto
    .incbin "out/script/strings/advscene-0x3542-1.bin"
    cut_waitForFrame $107+extraStartDelay-3
    cut_swapAndShowBuf
    
    ; ""
    SCENE_startNewStringAuto
    .incbin "out/script/strings/advscene-0x3542-2.bin"
    cut_waitForFrame $1A2+extraStartDelay-3
    cut_swapAndShowBuf
    
    ; ""
    SCENE_startNewStringAuto
    .incbin "out/script/strings/advscene-0x3542-3.bin"
    cut_waitForFrame $23D+extraStartDelay-3
    cut_swapAndShowBuf
    
    cut_waitForFrame $2EF+extraStartDelay-3
    cut_subsOff
  
    ;=====
    ; done
    ;=====
    
    ; wait for end of scene
;    cut_waitForFrameMinSec 0 30.000
    
    ; text box on
    SCENE_textBoxOn
    ; cropping off
;    cut_setCropOn $00
    
    @done:
    cut_terminator
.ends








