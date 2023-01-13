
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
.endme

.rombankmap
  bankstotal $8
  
  banksize $2000
  banks $8
.endro

.emptyfill $FF

.background ROMNAME


;======================================================================
; 
;======================================================================

; free space
; HACK: generated script text has to go in these banks.
; the script generator has a hack that prevents these specific
; areas from being marked as usable for text.
.unbackground $3A00 $3FFC

;=====
; script data
;=====

.bank 1 slot 0
.orga $BFFC
.section "new script data 1" overwrite
  .dw scriptData
  .db advScenePresentMarkerA
  .db advScenePresentMarkerB
.ends

.bank 1 slot 0
.section "new script data 2" free
  scriptData:
    ;=====
    ; init
    ;=====
    
;    SCENE_setUpAutoPlace $1A0 $18
;    SCENE_setUpAutoPlace $2E $1C
    SCENE_setUpAutoPlace $3C $174
    
    ; text box off
    SCENE_textBoxOff
    
    ; cropping on
;    cut_setCropOn $01
    
    cut_setPalette $0C
    
    ; "this is an he system"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/tonguetwister-0.bin"
    
    SYNC_varTime 1 $01
  
    ;=====
    ; wait until safe start point
    ;=====
    
;    cut_waitForFrameMinSec 0 1.000
  
    ;=====
    ; data
    ;=====
    
    cut_waitForFrameMinSec 0 0.702
    cut_swapAndShowBuf
    
    ; "track 2 contains data"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/tonguetwister-1.bin"
    cut_waitForFrameMinSec 0 4.567
    cut_swapAndShowBuf
    
      ; "this is an he system"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/tonguetwister-3.bin"
    
    cut_waitForFrameMinSec 0 9.182
    cut_subsOff
    cut_waitForFrameMinSec 0 13.759
    cut_swapAndShowBuf
    
    ; "track 2 contains data"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/tonguetwister-4.bin"
    cut_waitForFrameMinSec 0 17.360
    cut_swapAndShowBuf
    
      ; "ladies and gentlemen"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/tonguetwister-6.bin"
    
    cut_waitForFrameMinSec 0 22.342
    cut_subsOff
    cut_waitForFrameMinSec 0 36.970
    cut_swapAndShowBuf
    
    ; "this is..."
    SCENE_startNewStringAuto
    .incbin "out/script/strings/tonguetwister-7.bin"
    cut_waitForFrameMinSec 0 40.407
    cut_swapAndShowBuf
    
      ; "all right, first"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/tonguetwister-9.bin"
    
    cut_waitForFrameMinSec 0 43.342
    cut_subsOff
    cut_waitForFrameMinSec 0 47.127
    cut_swapAndShowBuf
    
      ; "yaah!"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/tonguetwister-10.bin"
    
    cut_waitForFrameMinSec 0 51.009
    cut_subsOff
    cut_waitForFrameMinSec 0 54.321
    cut_swapAndShowBuf
    
    ; "basu gasu bakuhatsu"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/tonguetwister-11.bin"
    cut_waitForFrameMinSec 0 57.178
    cut_swapAndShowBuf
    
    ; "kaeru pyokopyoko"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/tonguetwister-13.bin"
    cut_waitForFrameMinSec 1 0.403
    cut_swapAndShowBuf
    
      ; "well then, next is"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/tonguetwister-14.bin"
    
    cut_waitForFrameMinSec 1 3.725
    cut_subsOff
    cut_waitForFrameMinSec 1 7.732
    cut_swapAndShowBuf
    
    ; "motoko! go for it"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/tonguetwister-15.bin"
    cut_waitForFrameMinSec 1 9.856
    cut_swapAndShowBuf
    
    ; "w-w-w-w-w-w-wait"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/tonguetwister-16.bin"
    cut_waitForFrameMinSec 1 11.748
    cut_swapAndShowBuf
    
    ; "t-t-t-t-toky"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/tonguetwister-17.bin"
    cut_waitForFrameMinSec 1 14.809
    cut_swapAndShowBuf
    
    ; "t-toukyou tokkyo"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/tonguetwister-19.bin"
    cut_waitForFrameMinSec 1 17.242
    cut_swapAndShowBuf
    
      ; "all right, ayaka"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/tonguetwister-20.bin"
    
    cut_waitForFrameMinSec 1 19.646
    cut_subsOff
    cut_waitForFrameMinSec 1 25.845
    cut_swapAndShowBuf
    
    ; "huh? can ayaka really"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/tonguetwister-22.bin"
    cut_waitForFrameMinSec 1 28.616
    cut_swapAndShowBuf
    
    ; "umm, right"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/tonguetwister-24.bin"
    cut_waitForFrameMinSec 1 32.517
    cut_swapAndShowBuf
    
    ; "a room was built in"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/tonguetwister-25.bin"
    cut_waitForFrameMinSec 1 34.921
    cut_swapAndShowBuf
    
      ; "hey, that's wrong"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/tonguetwister-26.bin"
    
    cut_waitForFrameMinSec 1 39.140
    cut_subsOff
    cut_waitForFrameMinSec 1 39.942
    cut_swapAndShowBuf
    
      ; "sorry! next up is"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/tonguetwister-28.bin"
    
    cut_waitForFrameMinSec 1 42.635
    cut_subsOff
    cut_waitForFrameMinSec 1 43.968
    cut_swapAndShowBuf
    
    ; "m-me?"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/tonguetwister-29.bin"
    cut_waitForFrameMinSec 1 47.038
    cut_swapAndShowBuf
    
      ; "namamugi managome"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/tonguetwister-30.bin"
    
    cut_waitForFrameMinSec 1 48.641+0.300
    cut_subsOff
    cut_waitForFrameMinSec 1 51.103
    cut_swapAndShowBuf
    
      ; "that's not right, is it"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/tonguetwister-31.bin"
    
    cut_waitForFrameMinSec 1 53.218
    cut_subsOff
    cut_waitForFrameMinSec 1 54.019
    cut_swapAndShowBuf
    
      ; "of course, last is you"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/tonguetwister-32.bin"
    
    cut_waitForFrameMinSec 1 56.529
    cut_subsOff
    cut_waitForFrameMinSec 1 59.822
    cut_swapAndShowBuf
    
    ; "of course"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/tonguetwister-33.bin"
    cut_waitForFrameMinSec 2 2.603
    cut_swapAndShowBuf
    
    ; "you were all fired up"
;    SCENE_startNewStringAuto
;    .incbin "out/script/strings/tonguetwister-34.bin"
;    cut_waitForFrameMinSec 2 3.771
;    cut_swapAndShowBuf
    
    ; "knock it out in"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/tonguetwister-35.bin"
    cut_waitForFrameMinSec 2 6.078
    cut_swapAndShowBuf
    
    ; "ah, okay"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/tonguetwister-37.bin"
    cut_waitForFrameMinSec 2 10.027
    cut_swapAndShowBuf
    
      ; "nourin suisanshou"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/tonguetwister-38.bin"
    
    cut_waitForFrameMinSec 2 11.582
    cut_subsOff
    cut_waitForFrameMinSec 2 12.596
    cut_swapAndShowBuf
    
    cut_waitForFrameMinSec 2 15.956
    cut_subsOff
  
    ;=====
    ; done
    ;=====
    
    ; wait for end of scene
    cut_waitForFrameMinSec 2 23.709
    
    ; text box on
    SCENE_textBoxOn
    ; cropping off
;    cut_setCropOn $00
    
    cut_terminator
.ends
