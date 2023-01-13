
;==============================================================================
; adv-0x3742 case 3 title card hack
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

;=====
; load new graphics
;=====

.bank 0 slot 0
.org $77
.section "new grp 1" overwrite
  ; load grp op
  .db $05
    ; srcbank - 0x68
    .db ($78+($F000/$2000))-scdBaseMemPage
    ; vram dst
    .dw $1800
    ; srcptr ($A000-based)
    .dw $B000
    ; size in tiles
    .dw $100
.ends
