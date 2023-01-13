
.include "include/advscene_base.inc"

.include "include/cafe_password.inc"

;===================================
; case 3 cafe menu
;
; not actually a scene to be subtitled,
; but it's quicker to reuse the
; framework i've already set up instead
; of doing something special just for
; the edits needed here
;===================================

;=====
; script data
;=====

.bank 0 slot 0
.section "script data" free
  scriptData:
    ; do nothing
    cut_terminator
.ends

;=====
; initialize extra space for extended passwords
;=====

; TODO: reset back to zero after password entry complete,
; on the off chance the extra memory we use is needed
; for something else (though it doesn't appear to be)

.bank 0 slot 0
.org $2E
.section "init password array 1" overwrite
  ; jump
  .db $26
    ; dst
    .dw (extraPasswordInitScript&$1FFF)
.ends

.bank 0 slot 0
.section "init password array 2" free
  extraPasswordInitScript:
    ; make up work
    .db $42
      .db $00
      .dw $3ACB
      .db $FF
  
    ; init array positions 6-11
    .rept newPasswordLen-oldPasswordLen INDEX count
      ; write byte
      .db $42
        ; ?
        .db $00
        ; dst
        .dw nameEntryInputArray+oldPasswordLen+count
        ; value
        .db passwordNullValue
    .endr
    
    ; jump
    .db $26
      ; dst
      .dw $33
.ends

;=====
; correct erase logic
;=====

; for whatever ridiculous reason, erasing the current character by
; pressing button 2 is NOT handled the same as erasing by pressing
; button 1 with the "back" arrow selected.
; manually hitting the back arrow does what you'd expect: it runs
; some code to write 0xFF to the current array position, then decrements
; the position index.
;
; but if you hit button 2, the game instead goes through the scripting
; system, doing a switch on the index value to determine which of six
; subscripts to jump to; each of those writes FF to one predetermined
; array position (0-5), then decrements the index.
; since we have twice as many characters, we have to go in and add
; additional subscripts to handle erasure at positions 6-11.
; seriously, why in the hell would you do it this way?

.macro makeArrayErasePosHandler ARGS target
  ; write byte
  .db $42
    .db $00
    .dw target
    .db $FF
  ; jump
  .db $26
    .dw $12A
.endm

.bank 0 slot 0
.org $E8
.section "erase script switch 1" overwrite
  ; jump
  .db $26
    ; dst
    .dw (extraEraseScriptSwitch&$1FFF)
.ends

.bank 0 slot 0
.section "erase script switch 2" free
  extraEraseScriptSwitch:
    ; extended op marker
    .db $FF
    ; switch on nameEntryCurrentPutIndex
    .db $15
      .dw nameEntryCurrentPutIndex
      ; branches
      .dw $FA
      .dw $102
      .dw $10A
      .dw $112
      .dw $11A
      .dw $122
      .dw (arrayErasePos6Handler&$1FFF)
      .dw (arrayErasePos7Handler&$1FFF)
      .dw (arrayErasePos8Handler&$1FFF)
      .dw (arrayErasePos9Handler&$1FFF)
      .dw (arrayErasePos10Handler&$1FFF)
      .dw (arrayErasePos11Handler&$1FFF)
      ; the original script has a redundant entry at the end,
      ; which may or may not be necessary;
      ; keeping in just in case
      .dw (arrayErasePos11Handler&$1FFF)
  
    arrayErasePos6Handler: makeArrayErasePosHandler nameEntryInputArray+6
    arrayErasePos7Handler: makeArrayErasePosHandler nameEntryInputArray+7
    arrayErasePos8Handler: makeArrayErasePosHandler nameEntryInputArray+8
    arrayErasePos9Handler: makeArrayErasePosHandler nameEntryInputArray+9
    arrayErasePos10Handler: makeArrayErasePosHandler nameEntryInputArray+10
    arrayErasePos11Handler: makeArrayErasePosHandler nameEntryInputArray+11
      
.ends

;=====
; set initial position of selection cursor correctly
;=====

.bank 0 slot 1
.org $1B7
.section "top window cursor init 1" overwrite
  ; initial y
;  .dw $0010
  .dw passwordCursorBaseTileY*patternH
  ; initial x
;  .dw $0090
  .dw passwordCursorBaseTileX*patternW
  ; initial state
  .dw $0000
.ends

;=====
; use half-size cursor for bottom window
;=====

.bank 0 slot 1
.org $1C7
.section "bottom window half cursor 1" overwrite
  ; initial y
  .dw $008F-3
  ; initial x
  .dw $0090+passwordDisplayExtraXOffset
  ; initial state
  ; 1 = full-width, 0 = half-width
;  .dw $0001
  .dw $0000
.ends

;=====
; position of password display sprites
;=====

.bank 0 slot 1
.org $1D7
.section "password display sprites init 1" overwrite
  ; initial y
  .dw $0088+5
  ; initial x
  .dw $0090+passwordDisplayExtraXOffset
  ; initial state
  .dw $0003
.ends

;=====
; write correct value to set cursor to "end"
; when select pressed
;=====

.bank 0 slot 1
.org $D3
.section "select end 1" overwrite
  .db passwordIndexEnd
.ends














