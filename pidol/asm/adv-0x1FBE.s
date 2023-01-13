
;==============================================================================
; adv-0x1FBE case2b map hacks
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

; HACK: this space is excluded from the free space made available
; for inserting the script specifically so we can add our own hacks
.unbackground $1F00 $1FFF

.define gamescr_op_writeObjVal $01
.define gamescr_op_loadToVram  $05
.define gamescr_op_branch      $26

.define mapExt_newGrpOffset $1FE00
.define mapExt_newGrpSize $200
.define mapExt_newGrpBank (mapExt_newGrpOffset/$2000)
.define mapExt_newGrpPtrOffset (mapExt_newGrpOffset&$1FFF)

.define newOldMapGrpTileCount $2C0

;===================================
; load mapExt
;===================================

.bank 0 slot 0
.orga $A43C
.section "mapExt load 1" overwrite
  ; write value
  .db gamescr_op_branch
    ; branch dst
    .dw (gamescr_doMapExtLoad&$1FFF)
.ends

.bank 0 slot 0
.section "mapExt load 2" free
  gamescr_doMapExtLoad:
    ;=====
    ; make up work
    ;=====
    
    ; write value
    .db gamescr_op_loadToVram
      ; src bank
      .db $11
      ; vram dst
      .dw $1800
      ; src ptr
      .dw ($A000+$0000)
      ; tile count
;      .dw $2BA
      .dw newOldMapGrpTileCount
    
    ;=====
    ; load new grp
    ;=====
    
    ; write value
    .db gamescr_op_loadToVram
      ; src bank
      .db ($10+mapExt_newGrpBank)
      ; vram dst
      .dw $1800+((newOldMapGrpTileCount*$20)/2)
      ; src ptr
      .dw ($A000+mapExt_newGrpPtrOffset)
      ; tile count
      .dw (mapExt_newGrpSize/$20)
    
    ;=====
    ; jump back to original logic
    ;=====
    
    ; write value
    .db gamescr_op_branch
      ; branch dst
      .dw ($A444&$1FFF)
.ends
