
.include "include/advscene_base.inc"

;===================================
; case 2b watabe letter
;===================================

;.redefine SYNC_offset 15

.define offOffsetSec 0.250

.bank 0 slot 0
.section "script data" free
  scriptData:
    ;=====
    ; init
    ;=====
    
    SCENE_setUpAutoPlace $198 $1C
    
    ; text box off
    SCENE_textBoxOff
    
    ; cropping on
;    cut_setCropOn $01
    
    cut_setPalette $0D
    
    SYNC_varTime 1 $01
  
    ;=====
    ; wait until safe start point
    ;=====
    
    cut_waitForFrameMinSec 0 2.000
  
    ;=====
    ; data
    ;=====
    
    ; "to whom it may"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/advscene-0x227E-0.bin"
    cut_waitForFrameMinSec 0 3.930
    cut_swapAndShowBuf
    
    ; "if you are reading this"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/advscene-0x227E-1.bin"
    cut_waitForFrameMinSec 0 5.535
    cut_swapAndShowBuf
    
      ; "perhaps you have already"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/advscene-0x227E-3.bin"
    
    cut_waitForFrameMinSec 0 10.915+offOffsetSec
    cut_subsOff
    cut_waitForFrameMinSec 0 12.614
    cut_swapAndShowBuf
  
    ; "...are members of"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/advscene-0x227E-4.bin"
;    cut_waitForFrameMinSec 0 15.504
    cut_waitForFrameMinSec 0 17.556
    cut_swapAndShowBuf
    
      ; "the cave in threewood"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/advscene-0x227E-5.bin"
    
    cut_waitForFrameMinSec 0 19.294+0.300
    cut_subsOff
    cut_waitForFrameMinSec 0 20.605
    cut_swapAndShowBuf
  
    ; "...which the syndicate uses"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/advscene-0x227E-6.bin"
    cut_waitForFrameMinSec 0 24.327
    cut_swapAndShowBuf
    
      ; "the stored items"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/advscene-0x227E-8.bin"
    
    cut_waitForFrameMinSec 0 29.378+offOffsetSec
    cut_subsOff
    cut_waitForFrameMinSec 0 30.746
    cut_swapAndShowBuf
  
    ; "...that have been diverted"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/advscene-0x227E-9.bin"
    cut_waitForFrameMinSec 0 34.280
    cut_swapAndShowBuf
    
      ; "when i was in"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/advscene-0x227E-10.bin"
    
    cut_waitForFrameMinSec 0 36.776+offOffsetSec
    cut_subsOff
    cut_waitForFrameMinSec 0 38.623
    cut_swapAndShowBuf
  
    ; "...i illegally diverted"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/advscene-0x227E-11.bin"
    cut_waitForFrameMinSec 0 41.496
    cut_swapAndShowBuf
  
      ; "and seven years ago"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/advscene-0x227E-13.bin"
    
    cut_waitForFrameMinSec 0 47.960+offOffsetSec
    cut_subsOff
    cut_waitForFrameMinSec 0 49.430
    cut_swapAndShowBuf
  
    ; "the cause of my subordinate"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/advscene-0x227E-14.bin"
    cut_waitForFrameMinSec 0 52.166
    cut_swapAndShowBuf
  
    ; "...information that i leaked"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/advscene-0x227E-15.bin"
    cut_waitForFrameMinSec 0 56.715
    cut_swapAndShowBuf
  
      ; "since that incident"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/advscene-0x227E-16.bin"
    
    cut_waitForFrameMinSec 1 0.488+offOffsetSec
    cut_subsOff
    cut_waitForFrameMinSec 1 1.913
    cut_swapAndShowBuf
  
    ; "i, together with sakaki"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/advscene-0x227E-17.bin"
    cut_waitForFrameMinSec 1 3.703
    cut_swapAndShowBuf
  
    ; "living as the island's"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/advscene-0x227E-18.bin"
    cut_waitForFrameMinSec 1 8.992
    cut_swapAndShowBuf
  
      ; "however...i end"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/advscene-0x227E-19.bin"
    
    cut_waitForFrameMinSec 1 11.945+offOffsetSec
    cut_subsOff
    cut_waitForFrameMinSec 1 13.370
    cut_swapAndShowBuf
  
      ; "when i learned that"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/advscene-0x227E-20.bin"
    
    cut_waitForFrameMinSec 1 17.930+offOffsetSec
    cut_subsOff
    cut_waitForFrameMinSec 1 19.526
    cut_swapAndShowBuf
  
    ; "...the son of"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/advscene-0x227E-21.bin"
    cut_waitForFrameMinSec 1 22.228
    cut_swapAndShowBuf
  
    ; "and when i realized"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/advscene-0x227E-23.bin"
    cut_waitForFrameMinSec 1 28.726
    cut_swapAndShowBuf
  
      ; "i sensed that the time"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/advscene-0x227E-24.bin"
    
    cut_waitForFrameMinSec 1 35.304+offOffsetSec
    cut_subsOff
    cut_waitForFrameMinSec 1 36.558
    cut_swapAndShowBuf
  
      ; "lastly...though it may be"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/advscene-0x227E-25.bin"
    
    cut_waitForFrameMinSec 1 41.847+offOffsetSec
    cut_subsOff
    cut_waitForFrameMinSec 1 43.500
    cut_swapAndShowBuf
  
    ; "i hope you will"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/advscene-0x227E-26.bin"
    cut_waitForFrameMinSec 1 47.570
;    cut_waitForFrameMinSec 1 44.811-0.200
    cut_swapAndShowBuf
  
      ; "i have learned that"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/advscene-0x227E-28.bin"
    
    cut_waitForFrameMinSec 1 50.568+offOffsetSec
    cut_subsOff
    cut_waitForFrameMinSec 1 51.560
    cut_swapAndShowBuf
  
    ; "which was formerly"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/advscene-0x227E-29.bin"
    cut_waitForFrameMinSec 1 55.322
    cut_swapAndShowBuf
  
      ; "the syndicate will probably"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/advscene-0x227E-31.bin"
    
    cut_waitForFrameMinSec 1 59.369+offOffsetSec
    cut_subsOff
    cut_waitForFrameMinSec 2 1.284
    cut_swapAndShowBuf
  
    ; "at least...at least"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/advscene-0x227E-32.bin"
    cut_waitForFrameMinSec 2 5.491
    cut_swapAndShowBuf
  
    ; "...try to prevent there"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/advscene-0x227E-33.bin"
    cut_waitForFrameMinSec 2 8.398
    cut_swapAndShowBuf
  
      ; "i humbly ask"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/advscene-0x227E-34.bin"
    
    cut_waitForFrameMinSec 2 11.282+offOffsetSec
    cut_subsOff
    cut_waitForFrameMinSec 2 12.559
    cut_swapAndShowBuf
  
      ; "sincerely"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/advscene-0x227E-35.bin"
    
    cut_waitForFrameMinSec 2 14.189+offOffsetSec
    cut_subsOff
    cut_waitForFrameMinSec 2 15.568
    cut_swapAndShowBuf
    
    cut_waitForFrameMinSec 2 18.327+offOffsetSec
    cut_subsOff
  
    ;=====
    ; done
    ;=====
    
    ; wait for end of scene
;    cut_waitForFrameMinSec 2 19.800
    ; this works fine under mednafen-pcedev, but cccmar tells me that retroarch
    ; fails to restore the dialogue box under this timing.
    ; i would be very, very surprised if retroarch has better
    ; accuracy than mednafen-pcedev, but in the interest of people not
    ; complaining about things, i'll move it forward.
;    cut_waitForFrameMinSec 2 25.000
    cut_waitForFrameMinSec 2 19.800
    
    ; text box on
;    SCENE_textBoxOnWithDelay 60
    SCENE_textBoxOnWithDelay 119
    ; cropping off
;    cut_setCropOn $00
    
    cut_terminator
.ends








