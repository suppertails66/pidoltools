
.include "include/advscene_base.inc"

;===================================
; case 2b "the end"
;===================================

;.redefine SYNC_offset 15

.bank 0 slot 0
.section "script data" free
  scriptData:
    ;=====
    ; init
    ;=====
    
    SCENE_setUpAutoPlace $1B0 $18
    
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
    
    ; "the end"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/advscene-0x233E-0.bin"
    cut_waitForFrameMinSec 0 3.514
    cut_swapAndShowBuf
    
    cut_waitForFrameMinSec 0 4.867
    cut_subsOff
  
    ;=====
    ; done
    ;=====
    
    ; it would be nice to black out the text box here
    ; so that it doesn't fade in and then immediately back out
    ; during the normal sequence (which leads directly into
    ; a full visual scene with no text box).
    ; however, this scene can also be viewed from the art gallery,
    ; and we don't want the box to remain blacked out there
    ; or it'll be stuck that way.
    ; so, we check if the current area base sector ($2973-$2975)
    ; is the art gallery (sector 0x356) and handle accordingly.
    
/*    ; high byte
    cut_jumpIfMaskedEq $2973, $FF, $00, +
      cut_jump @notGallery
    +:
    ; low byte
    cut_jumpIfMaskedEq $2974, $FF, $56, +
      cut_jump @notGallery
    +:
    ; mid byte
    cut_jumpIfMaskedEq $2975, $FF, $03, +
      cut_jump @notGallery
    +:
    cut_jump @galleryCheckDone
    
    @notGallery:
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
    @galleryCheckDone:*/
    
    ; ...or, well, it makes no real difference, but let's make it
    ; a little cleaner and specifically check if we're coming from
    ; area 0x1F5E, where the event occurs in regular gameplay
    
    ; high byte
    cut_jumpIfMaskedEq $2973, $FF, $00, +
      cut_jump @noBlackout
    +:
    ; mid byte
    cut_jumpIfMaskedEq $2975, $FF, $1F, +
      cut_jump @noBlackout
    +:
    ; low byte
    cut_jumpIfMaskedEq $2974, $FF, $5E, +
      cut_jump @noBlackout
    +:
      ; set text box palette to black
      ; (this probably isn't necessary but why not)
      
      ; write to memory
      .rept 16 INDEX count
        cut_writeMemWord builtInMemPage ($1154+(count*2)) $0000
      .endr
      ; write to vce
      cut_writePalette ($3E0/2) 32
        .rept 16
          .dw $0000
        .endr
      
      ; skip normal text box fade-in
      cut_jump @done
    @noBlackout:
    
    ; wait for end of scene
    cut_waitForFrameMinSec 0 7.277-1.000
    
    ; text box on
    SCENE_textBoxOnWithDelay 60
    ; cropping off
;    cut_setCropOn $00
    
    @done:
    cut_terminator
.ends








