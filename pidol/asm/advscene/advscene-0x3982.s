
.include "include/advscene_base.inc"

;===================================
; karaoke
;===================================

;.redefine SYNC_offset 15

.bank 0 slot 0
.section "script data" free
  scriptData:
    ;=====
    ; init
    ;=====
    
    SCENE_setUpAutoPlace $1A0 $18
    
    ; text box off
;    SCENE_textBoxOff
    
    ; cropping on
;    cut_setCropOn $01
    
    cut_setPalette $0D
    
    cut_setLineFloodMode $00
  
    ;=====
    ; wait until safe start point
    ;=====
    
;    cut_waitForFrameMinSec 0 3.000
  
    ;=====
    ; prep intro message
    ;=====
    
    SCENE_startNewStringAuto

    ; wait until cd track about to start
    @trackSelectWaitLoop:
      cut_jumpIfLastSyncIdEq $00 @trackSelectWaitLoop
    
    ; prep appropriate message for selected track
    cut_jumpIfLastSyncIdEq $08 @noVocals
      .incbin "out/script/strings/advscene-0x3982-23.bin"
      cut_jump @vocalMessageDone
    @noVocals:
      .incbin "out/script/strings/advscene-0x3982-24.bin"
    @vocalMessageDone:
    
    ; wait for cd track to start
    SYNC_varTime 1 $01
  
    ;=====
    ; data
    ;=====
    
    ; show previously prepped 
    cut_waitForFrameMinSec 0 1.000
    cut_swapAndShowBuf
    cut_waitForFrameMinSec 0 6.000
    cut_subsOff
    
    ; "yoru ga fukete"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/advscene-0x3982-0.bin"
    cut_waitForFrameMinSec 0 24.333
    cut_swapAndShowBuf
    
    ; "kousou biru no machi"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/advscene-0x3982-1.bin"
    cut_waitForFrameMinSec 0 29.704
    cut_swapAndShowBuf
    
    ; "yume no shizuku"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/advscene-0x3982-2.bin"
    cut_waitForFrameMinSec 0 35.089
    cut_swapAndShowBuf
    
    ; "kurukuru mawashite"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/advscene-0x3982-3.bin"
    cut_waitForFrameMinSec 0 39.371
    cut_swapAndShowBuf
    
    ; "machi no hi ni"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/advscene-0x3982-4.bin"
    cut_waitForFrameMinSec 0 45.861
    cut_swapAndShowBuf
    
    ; "suteki na purezento"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/advscene-0x3982-5.bin"
    cut_waitForFrameMinSec 0 51.247
    cut_swapAndShowBuf
    
    ; "mada minu anata made"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/advscene-0x3982-6.bin"
    cut_waitForFrameMinSec 0 56.632
    cut_swapAndShowBuf
    
    ; "todoke kono omoi"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/advscene-0x3982-7.bin"
    cut_waitForFrameMinSec 1 1.347
    cut_swapAndShowBuf
    
    ; "koi no hinto wa"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/advscene-0x3982-8.bin"
    cut_waitForFrameMinSec 1 7.434
    cut_swapAndShowBuf
    
    ; "hitomi ga tegakari"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/advscene-0x3982-9.bin"
    cut_waitForFrameMinSec 1 12.819
    cut_swapAndShowBuf
    
    ; "nayande atsumeru"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/advscene-0x3982-10.bin"
    cut_waitForFrameMinSec 1 18.205
    cut_swapAndShowBuf
    
    ; "infomeeshon"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/advscene-0x3982-11.bin"
    cut_waitForFrameMinSec 1 23.591
    cut_swapAndShowBuf
    
    ; "koi o shiyou yo tsukitometai ne"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/advscene-0x3982-12.bin"
    cut_waitForFrameMinSec 1 28.977
    cut_swapAndShowBuf
    
    ; "abunai jiken"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/advscene-0x3982-14.bin"
    cut_waitForFrameMinSec 1 34.377
    cut_swapAndShowBuf
    
    ; "kakusareta shinjitsu o"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/advscene-0x3982-15.bin"
    cut_waitForFrameMinSec 1 39.763
    cut_swapAndShowBuf
    
    ; "sagashite mitsukedasou"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/advscene-0x3982-16.bin"
    cut_waitForFrameMinSec 1 45.149
    cut_swapAndShowBuf
    
    ; "koi o shiyou yo makikomaretai"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/advscene-0x3982-18.bin"
    cut_waitForFrameMinSec 1 50.535
    cut_swapAndShowBuf
    
    ; "abunai jiken"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/advscene-0x3982-20.bin"
    cut_waitForFrameMinSec 1 55.920
    cut_swapAndShowBuf
    
    ; "kono mama ja"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/advscene-0x3982-21.bin"
    cut_waitForFrameMinSec 2 1.306
    cut_swapAndShowBuf
    
    ; "yarusenai rainy night"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/advscene-0x3982-22.bin"
    cut_waitForFrameMinSec 2 6.707
    cut_swapAndShowBuf
    
    cut_waitForFrameMinSec 2 12.092
    cut_subsOff
    
    
    
    ; ****************** repeat **********************
    
    
    
    ; "koi o shiyou yo tsukitometai ne"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/advscene-0x3982-12.bin"
    cut_waitForFrameMinSec 2 33.650
    cut_swapAndShowBuf
    
    ; "abunai jiken"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/advscene-0x3982-14.bin"
    cut_waitForFrameMinSec 2 39.036
    cut_swapAndShowBuf
    
    ; "kakusareta shinjitsu o"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/advscene-0x3982-15.bin"
    cut_waitForFrameMinSec 2 44.422
    cut_swapAndShowBuf
    
    ; "sagashite mitsukedasou"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/advscene-0x3982-16.bin"
    cut_waitForFrameMinSec 2 49.793
    cut_swapAndShowBuf
    
    ; "koi o shiyou yo makikomaretai"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/advscene-0x3982-18.bin"
    cut_waitForFrameMinSec 2 55.208
    cut_swapAndShowBuf
    
    ; "abunai jiken"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/advscene-0x3982-20.bin"
    cut_waitForFrameMinSec 3 0.609
    cut_swapAndShowBuf
    
    ; "kono mama ja"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/advscene-0x3982-21.bin"
    cut_waitForFrameMinSec 3 5.980
    cut_swapAndShowBuf
    
    ; "yarusenai rainy night"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/advscene-0x3982-22.bin"
    cut_waitForFrameMinSec 3 11.365
    cut_swapAndShowBuf
    
    cut_waitForFrameMinSec 3 16.751
    cut_subsOff
  
    ;=====
    ; done
    ;=====
    
    cut_setLineFloodMode $FF
    
    ; wait for end of scene
;    cut_waitForFrameMinSec 0 16.390
    
    ; text box on
;    SCENE_textBoxOn
    ; cropping off
;    cut_setCropOn $00
    
    cut_terminator
.ends

;===================================
; oh and the original game's timing is purely synchronous,
; so having more characters in the english text means the
; messages take longer and the delays are now wrong, so we
; have to adjust them to compensate. lovely!
; you know, i hated doing this so much on sailor moon and
; madou monogatari that i wrote an entire thread-based subtitle
; engine just to avoid it!
;===================================

; offset by this many frames per box
.define timingCorrectionFactorFull 24
.define timingCorrectionFactorHalf (timingCorrectionFactorFull/2)

.bank 0 slot 0
.org $7C
.section "timing adjust 1" overwrite
  ; "yoru ga fukete"
  .dw $140
.ends

.bank 0 slot 0
.org $85
.section "timing adjust 2" overwrite
  ; "yume no shizuku"
  .dw $26C-timingCorrectionFactorFull
.ends

.bank 0 slot 0
.org $8B
.section "timing adjust 3" overwrite
  ; "machi no hi ni"
  .dw $26C-timingCorrectionFactorFull
.ends

.bank 0 slot 0
.org $91
.section "timing adjust 4" overwrite
  ; "mada minu anata"
  .dw $26C-timingCorrectionFactorFull
.ends

.bank 0 slot 0
.org $97
.section "timing adjust 5" overwrite
  ; "koi no hinto"
  .dw $26C-timingCorrectionFactorFull
.ends

.bank 0 slot 0
.org $9D
.section "timing adjust 6" overwrite
  ; "nayande atsumeru"
  .dw $26C-timingCorrectionFactorFull
.ends

.bank 0 slot 0
.org $A3
.section "timing adjust 7" overwrite
  ; "koi o shiyou yo" (1)
  .dw $26C-timingCorrectionFactorFull
.ends

.bank 0 slot 0
.org $A9
.section "timing adjust 8" overwrite
  ; "kakusareta shinjitsu o"
  .dw $26C-timingCorrectionFactorFull
.ends

.bank 0 slot 0
.org $AF
.section "timing adjust 9" overwrite
  ; "koi o shiyou yo" (2)
  .dw $26C-timingCorrectionFactorFull
.ends

.bank 0 slot 0
.org $B5
.section "timing adjust 10" overwrite
  ; "kono mama ja"
  .dw $26C-timingCorrectionFactorFull
.ends

.bank 0 slot 0
.org $BB
.section "timing adjust 11" overwrite
  ; "yarusenai rainy night"
  .dw $136-timingCorrectionFactorHalf
.ends

.bank 0 slot 0
.org $C1
.section "timing adjust 12" overwrite
  ; clear command during instrumental break
  .dw $136-timingCorrectionFactorHalf
.ends

.bank 0 slot 0
.org $C7
.section "timing adjust 13" overwrite
  ; "koi o shiyou yo" (3)
  .dw $4D8-timingCorrectionFactorFull
.ends

.bank 0 slot 0
.org $CD
.section "timing adjust 14" overwrite
  ; "kakusareta shinjitsu o" (2)
  .dw $26C-timingCorrectionFactorFull
.ends

.bank 0 slot 0
.org $D3
.section "timing adjust 15" overwrite
  ; "koi o shiyou yo" (4)
  .dw $26C-timingCorrectionFactorFull
.ends

.bank 0 slot 0
.org $D9
.section "timing adjust 16" overwrite
  ; "kono mama ja" (2)
  .dw $26C-timingCorrectionFactorFull
.ends

.bank 0 slot 0
.org $DF
.section "timing adjust 17" overwrite
  ; "yarusenai rainy night" (2)
  .dw $136-timingCorrectionFactorHalf
.ends

.bank 0 slot 0
.org $E5
.section "timing adjust 18" overwrite
  ; final wait before clear
  .dw $136-timingCorrectionFactorHalf
.ends
