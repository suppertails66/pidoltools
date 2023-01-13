
;==============================================================================
; 
;==============================================================================

.include "include/global.inc"
.include "include/scene_adv_common.inc"

;===================================
; 
;===================================

.memorymap
   defaultslot     0
   
   slotsize        $2000
   slot            0       $A000
   slot            1       $8000
.endme

.rombankmap
  bankstotal $10
  
  banksize $2000
  banks $10
.endro

.emptyfill $FF

.background ROMNAME

.bank 0 slot 0
.orga advSceneBlockStartPtr
.section "advscene end of bank pointer + content marker" overwrite
  .dw scriptData
  .db advScenePresentMarkerA,advScenePresentMarkerB
.ends

.include ROMNAME_GEN_INC
