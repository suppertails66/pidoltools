
.include "include/advscene_base.inc"

;===================================
; case 2b title card hack
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
; load new graphics
;=====

.bank 0 slot 0
.org $76
.section "new grp 1" overwrite
  ; load grp op
  .db $05
    ; srcbank - 0x68
    .db ($78+($6800/$2000))-scdBaseMemPage
    ; vram dst
    .dw $1800
    ; srcptr ($A000-based)
    .dw $A800
    ; size in tiles
    .dw $100
.ends
