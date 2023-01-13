
;==============================================================================
; visual-0x4E4E case 2a title card hack
;==============================================================================

.include "include/global.inc"
;.include "include/scene_adv_common.inc"

;===================================
; 
;===================================

.memorymap
   defaultslot     0
   
   slotsize        $2000
   slot            0       $A000
.endme

.rombankmap
  bankstotal $20
  
  banksize $2000
  banks $20
.endro

.emptyfill $FF

.background ROMNAME


;======================================================================
; 
;======================================================================

; free space
.unbackground $6390 $67FF

.define baseOffset $4000
.define bankSize $2000

.macro makeFixedPointer ARGS ptr
  .dw (ptr&$1FFF)+((:ptr)*bankSize)+baseOffset
.endm

;=====
; sprite definition table
;=====

.bank 3 slot 0
.orga $A375
.section "new sprite def table 1" overwrite
  makeFixedPointer titleSpriteStruct
  makeFixedPointer subtitle0SpriteStruct
  makeFixedPointer subtitle1SpriteStruct
  makeFixedPointer subtitle2SpriteStruct
  makeFixedPointer subtitle3SpriteStruct
  makeFixedPointer subtitle4SpriteStruct
.ends

;=====
; sprite definitions
;=====

.bank 3 slot 0
.section "new sprite defs 1" free
  titleSpriteStruct:
    .incbin "out/grp/scene2a_title_spr.bin"
.ends

.bank 3 slot 0
.section "new sprite defs 2" free
  subtitle0SpriteStruct:
    .incbin "out/grp/scene2a_subtitle0_spr.bin"
.ends

.bank 3 slot 0
.section "new sprite defs 3" free
  subtitle1SpriteStruct:
    .incbin "out/grp/scene2a_subtitle1_spr.bin"
.ends

.bank 3 slot 0
.section "new sprite defs 4" free
  subtitle2SpriteStruct:
    .incbin "out/grp/scene2a_subtitle2_spr.bin"
.ends

.bank 3 slot 0
.section "new sprite defs 5" free
  subtitle3SpriteStruct:
    .incbin "out/grp/scene2a_subtitle3_spr.bin"
.ends

.bank 3 slot 0
.section "new sprite defs 6" free
  subtitle4SpriteStruct:
    .incbin "out/grp/scene2a_subtitle4_spr.bin"
.ends

;=====
; graphics
;=====

/*.bank 4 slot 1
.org $C400
.section "new grp 1" overwrite
  newGrp:
    .incbin "out/grp/scene1_title_grp.bin"
.ends*/
