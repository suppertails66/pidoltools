
;==============================================================================
; adv-0xBC6 case 1 title card hack
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
  bankstotal $10
  
  banksize $2000
  banks $10
.endro

.emptyfill $FF

.background ROMNAME


;======================================================================
; 
;======================================================================

; old sprite definitions
.unbackground $116F $11B3
; free space
; HACK: generated script text has to go in these banks.
; the script generator has a hack that prevents these specific
; areas from being marked as usable for text.
.unbackground $1F98 $1FFF

;=====
; sprite definition table
;=====

.bank 0 slot 0
.orga $B1B3
.section "new sprite def table 1" overwrite
  .dw (titleSpriteStruct&$1FFF)
  .dw (subtitleSpriteStruct&$1FFF)
.ends

;=====
; sprite definitions
;=====

.bank 0 slot 0
.section "new sprite defs 1" free
  titleSpriteStruct:
    .incbin "out/grp/scene1_title_spr.bin"
.ends

.bank 0 slot 0
.section "new sprite defs 2" free
  subtitleSpriteStruct:
    .incbin "out/grp/scene1_subtitle_spr.bin"
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
