
.include "include/visual_base.inc"

;======================================================================
; intro
;======================================================================

.unbackground $1C80 $1FFF

.define gamescr_op_writeObjVal $01
.define gamescr_op_branchIf    $02
.define gamescr_op_loadToVram  $05

.define splash3_newGrpOffset $34600
.define splash3_newGrpSize $1400
.define splash3_newGrpBank (splash3_newGrpOffset/$2000)
.define splash3_newGrpPtrOffset (splash3_newGrpOffset&$1FFF)

.define splash4_newGrpOffset (splash3_newGrpOffset+splash3_newGrpSize)
.define splash4_newGrpSize $D00
.define splash4_newGrpBank (splash4_newGrpOffset/$2000)
.define splash4_newGrpPtrOffset (splash4_newGrpOffset&$1FFF)

.define splash5_newGrpOffset (splash4_newGrpOffset+splash4_newGrpSize)
.define splash5_newGrpSize $D00
.define splash5_newGrpBank (splash5_newGrpOffset/$2000)
.define splash5_newGrpPtrOffset (splash5_newGrpOffset&$1FFF)

.define disclaimer_newGrpOffset (splash5_newGrpOffset+splash5_newGrpSize)
;.define disclaimer_newGrpOffset $3E000
.define disclaimer_newGrpSize $1B60
.define disclaimer_newGrpBank (disclaimer_newGrpOffset/$2000)
.define disclaimer_newGrpPtrOffset (disclaimer_newGrpOffset&$1FFF)

;===================================
; load splash3
;===================================

.bank fixedBank2 slot fixedSlot2
.orga $7892
.section "splash3 load 1" overwrite
  ; write value
  .db gamescr_op_branchIf
    ; target pointer (doesn't matter as long as reading has no side effects)
    .dw $4000
    ; mask (doesn't matter)
    .db $00
    ; branch dst (same value, so this is effectively an unconditional branch)
    .dw gamescr_doSplash3Load
    .dw gamescr_doSplash3Load
.ends

.bank fixedBank slot fixedSlot
.section "splash3 load 2" free
  gamescr_doSplash3Load:
    ;=====
    ; make up work
    ;=====
    
    ; write value
    .db gamescr_op_loadToVram
      ; src bank
      .db $1C
      ; vram dst
      .dw $0800
      ; src ptr
      .dw $0000
      ; tile count
      .dw $104
    
    ;=====
    ; load new grp
    ;=====
    
    ; write value
    .db gamescr_op_loadToVram
      ; src bank
      .db splash3_newGrpBank
      ; vram dst
      .dw $1840
      ; src ptr
      .dw splash3_newGrpPtrOffset
      ; tile count
      .dw (splash3_newGrpSize/$20)
    
    ;=====
    ; jump back to original logic
    ;=====
    
    ; write value
    .db gamescr_op_branchIf
      ; target pointer (doesn't matter as long as reading has no side effects)
      .dw $4000
      ; mask (doesn't matter)
      .db $00
      ; branch dst (same value, so this is effectively an unconditional branch)
      .dw $789A
      .dw $789A
.ends

;===================================
; load splash4
;===================================

.bank fixedBank2 slot fixedSlot2
.orga $798A
.section "splash4 load 1" overwrite
  ; write value
  .db gamescr_op_branchIf
    ; target pointer (doesn't matter as long as reading has no side effects)
    .dw $4000
    ; mask (doesn't matter)
    .db $00
    ; branch dst (same value, so this is effectively an unconditional branch)
    .dw gamescr_doSplash4Load
    .dw gamescr_doSplash4Load
.ends

.bank fixedBank slot fixedSlot
.section "splash4 load 2" free
  gamescr_doSplash4Load:
    ;=====
    ; make up work
    ;=====
    
    ; write value
    .db gamescr_op_loadToVram
      ; src bank
      .db $1C
      ; vram dst
      .dw $0800
      ; src ptr
      .dw $0000
      ; tile count
      .dw $00E7
    
    ;=====
    ; load new grp
    ;=====
    
    ; write value
    .db gamescr_op_loadToVram
      ; src bank
      .db splash4_newGrpBank
      ; vram dst
      .dw $1670
      ; src ptr
      .dw splash4_newGrpPtrOffset
      ; tile count
      .dw (splash4_newGrpSize/$20)
    
    ;=====
    ; jump back to original logic
    ;=====
    
    ; write value
    .db gamescr_op_branchIf
      ; target pointer (doesn't matter as long as reading has no side effects)
      .dw $4000
      ; mask (doesn't matter)
      .db $00
      ; branch dst (same value, so this is effectively an unconditional branch)
      .dw $7992
      .dw $7992
.ends

;===================================
; load splash5
;===================================

.bank fixedBank2 slot fixedSlot2
.orga $7A62
.section "splash5 load 1" overwrite
  ; write value
  .db gamescr_op_branchIf
    ; target pointer (doesn't matter as long as reading has no side effects)
    .dw $4000
    ; mask (doesn't matter)
    .db $00
    ; branch dst (same value, so this is effectively an unconditional branch)
    .dw gamescr_doSplash5Load
    .dw gamescr_doSplash5Load
.ends

.bank fixedBank slot fixedSlot
.section "splash5 load 2" free
  gamescr_doSplash5Load:
    ;=====
    ; make up work
    ;=====
    
    ; write value
    .db gamescr_op_loadToVram
      ; src bank
      .db $1C
      ; vram dst
      .dw $0800
      ; src ptr
      .dw $0000
      ; tile count
      .dw $0089
    
    ;=====
    ; load new grp
    ;=====
    
    ; write value
    .db gamescr_op_loadToVram
      ; src bank
      .db splash5_newGrpBank
      ; vram dst
      .dw $1090
      ; src ptr
      .dw splash5_newGrpPtrOffset
      ; tile count
      .dw (splash5_newGrpSize/$20)
    
    ;=====
    ; jump back to original logic
    ;=====
    
    ; write value
    .db gamescr_op_branchIf
      ; target pointer (doesn't matter as long as reading has no side effects)
      .dw $4000
      ; mask (doesn't matter)
      .db $00
      ; branch dst (same value, so this is effectively an unconditional branch)
      .dw $7A6A
      .dw $7A6A
.ends

;===================================
; load disclaimer
;===================================

/*.bank fixedBank2 slot fixedSlot2
.orga $7615
.section "disclaimer load 1" overwrite
  ; write value
  .db gamescr_op_loadToVram
    ; src bank
    .db disclaimer_newGrpBank
    ; vram dst
    .dw $0800
    ; src ptr
    .dw disclaimer_newGrpPtrOffset
    ; tile count
    .dw (disclaimer_newGrpSize/$20)
.ends*/

.bank fixedBank2 slot fixedSlot2
.orga $7615
.section "disclaimer load 1" overwrite
  ; write value
  .db gamescr_op_branchIf
    ; target pointer (doesn't matter as long as reading has no side effects)
    .dw $4000
    ; mask (doesn't matter)
    .db $00
    ; branch dst (same value, so this is effectively an unconditional branch)
    .dw gamescr_doDisclaimerLoad
    .dw gamescr_doDisclaimerLoad
.ends

.define disclaimerFirstSectionOffset $70A0
.define disclaimerFirstSectionBank (disclaimerFirstSectionOffset/$2000)
.define disclaimerFirstSectionNewGrpPtrOffset (disclaimerFirstSectionOffset&$1FFF)
.define disclaimerFirstSectionSize $F60

.bank fixedBank slot fixedSlot
.section "disclaimer load 2" free
  gamescr_doDisclaimerLoad:
    
    ;=====
    ; load new grp 1
    ;=====
    
    ; write value
    .db gamescr_op_loadToVram
      ; src bank
      .db disclaimerFirstSectionBank
      ; vram dst
      .dw $0800
      ; src ptr
      .dw disclaimerFirstSectionNewGrpPtrOffset
      ; tile count
      .dw (disclaimerFirstSectionSize/$20)
    
    ;=====
    ; load new grp 2
    ;=====
    
    ; write value
    .db gamescr_op_loadToVram
      ; src bank
      .db disclaimer_newGrpBank
      ; vram dst
      .dw $0800+((disclaimerFirstSectionSize/$20)*$10)
      ; src ptr
      .dw disclaimer_newGrpPtrOffset
      ; tile count
      .dw ((disclaimer_newGrpSize-disclaimerFirstSectionSize)/$20)
    
    ;=====
    ; jump back to original logic
    ;=====
    
    ; write value
    .db gamescr_op_branchIf
      ; target pointer (doesn't matter as long as reading has no side effects)
      .dw $4000
      ; mask (doesn't matter)
      .db $00
      ; branch dst (same value, so this is effectively an unconditional branch)
      .dw $761D
      .dw $761D
.ends

;===================================
; script data
;===================================

;.redefine SYNC_offset 10

.bank freeBank slot freeSlot
.section "script data" free
  defaultSubtitleScriptPtr:
    ;=====
    ; init
    ;=====
    
    SCENE_setUpAutoPlace $1B0 $20
    
    ; wait for cd track (main audio) to begin
    SYNC_varTime 1 $01
    
    cut_setPalette $0D
    
;    SYNC_varTime 1 $01
    
    ; cropping on
    cut_setCropOn $01
  
    ;=====
    ; wait until safe start point
    ;=====
    
    cut_waitForFrameMinSec 0 5.000
  
    ;=====
    ; data
    ;=====
    
    ; "i-i thought i was gonna"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x544E-0.bin"
    cut_waitForFrameMinSec 0 17.024
    cut_swapAndShowBuf
    
      ; "it appears there is also"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x544E-1.bin"
    
    cut_waitForFrameMinSec 0 19.207+0.400
    cut_subsOff
    cut_waitForFrameMinSec 0 20.069
    cut_swapAndShowBuf
    
      ; "this is navi?"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x544E-2.bin"
    
;    cut_waitForFrameMinSec 0 22.397+0.717
    cut_waitForFrameMinSec 0 22.397+0.300
    cut_subsOff
    cut_waitForFrameMinSec 0 29.529-0.020
    cut_swapAndShowBuf
    
    ; "cuuute"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x544E-3.bin"
    cut_waitForFrameMinSec 0 31.362
    cut_swapAndShowBuf
    
      ; "hasn't your personality"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x544E-4.bin"
    
    cut_waitForFrameMinSec 0 32.851+0.200
    cut_subsOff
    cut_waitForFrameMinSec 0 34.060
    cut_swapAndShowBuf
    
      ; "wh-what's the formality"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x544E-5.bin"
    
    cut_waitForFrameMinSec 0 36.992+0.200
    cut_subsOff
    cut_waitForFrameMinSec 0 38.637
    cut_swapAndShowBuf
    
    ; "dummy"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x544E-6.bin"
    cut_waitForFrameMinSec 0 42.069
    cut_swapAndShowBuf
    
      ; "shut up!"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x544E-7.bin"
    
    cut_waitForFrameMinSec 0 42.779+0.250
    cut_subsOff
    cut_waitForFrameMinSec 0 49.047
    cut_swapAndShowBuf
    
      ; "you're an eyesore"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x544E-8.bin"
    
    cut_waitForFrameMinSec 0 50.121+0.066
    cut_subsOff
    cut_waitForFrameMinSec 0 51.554
    cut_swapAndShowBuf
    
    ; "go away, now!"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x544E-9.bin"
;    cut_waitForFrameMinSec 0 53.333
    cut_waitForFrameMinSec 0 53.353
    cut_swapAndShowBuf
    
      ; "that 'doll' is"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x544E-10.bin"
    
    cut_waitForFrameMinSec 0 54.716-0.020
    cut_subsOff
    cut_waitForFrameMinSec 0 59.831
    cut_swapAndShowBuf
    
      ; "ayaka!"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x544E-11.bin"
    
    cut_waitForFrameMinSec 1 4.129+0.099
    cut_subsOff
    cut_waitForFrameMinSec 1 12.764
    cut_swapAndShowBuf
    
    cut_waitForFrameMinSec 1 15.797-1.500+0.433
    cut_subsOff
  
    ;=====
    ; done
    ;=====
    
    ; cropping off
    cut_setCropOn $00
    
;    cut_terminator
    
    ; unlike every other scene in the game, this one loops back to the
    ; beginning after a while, so we need to make sure the subtitles
    ; will properly loop with them
    
    ; wait for second cd track (title splash music) to begin
    ; oh, actually the game plays both tracks in sequence as a single continuous
    ; unit, so there's no need to do this
;    SYNC_varTime 2 $01
    
    ; reset sync counter variables
    cut_writeMem scdBaseMemPage+freeBank, (syncVar&$1FFF), $00
    cut_writeMemWord scdBaseMemPage+freeBank, (syncFrameCounter&$1FFF), $00
    
    ; loop to start
    cut_jump defaultSubtitleScriptPtr
.ends
