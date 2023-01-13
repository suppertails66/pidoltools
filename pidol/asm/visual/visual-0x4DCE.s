
.include "include/visual_base.inc"

;===================================
; dart discovery
;===================================

;.redefine SYNC_offset 10

.bank freeBank slot freeSlot
.section "script data" free
  defaultSubtitleScriptPtr:
    ;=====
    ; init
    ;=====
    
    SCENE_setUpAutoPlace $1B0 $20
    
    cut_setPalette $0D
    
    SYNC_varTime 1 $01
    
    ; cropping on
    cut_setCropOn $01
  
    ;=====
    ; wait until safe start point
    ;=====
    
    cut_waitForFrameMinSec 0 0.100
  
    ;=====
    ; data
    ;=====
    
    ; "a dart..."
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4DCE-0.bin"
    cut_waitForFrameMinSec 0 1.055
    cut_swapAndShowBuf
    
    ; "there's blood"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4DCE-1.bin"
    cut_waitForFrameMinSec 0 2.707
    cut_swapAndShowBuf
    
      ; "it appears there"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x4DCE-2.bin"
    
    cut_waitForFrameMinSec 0 3.661
    cut_subsOff
    
    cut_waitForFrameMinSec 0 4.759
    cut_swapAndShowBuf
    
      ; "based on the situation"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x4DCE-3.bin"
    
    cut_waitForFrameMinSec 0 7.152
    cut_subsOff
    
    cut_waitForFrameMinSec 0 8.991
    cut_swapAndShowBuf
  
    ; "shut up! i know"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4DCE-4.bin"
    cut_waitForFrameMinSec 0 11.693
    cut_swapAndShowBuf
    
      ; "a machine like you"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x4DCE-6.bin"
    
    cut_waitForFrameMinSec 0 14.024+0.383-0.017
    cut_subsOff
    
    cut_waitForFrameMinSec 0 15.024
    cut_swapAndShowBuf
  
      ; "you're an eyesore"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x4DCE-7.bin"
    
    cut_waitForFrameMinSec 0 18.632
    cut_subsOff
    
    cut_waitForFrameMinSec 0 20.961
    cut_swapAndShowBuf
  
    ; "go away"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4DCE-8.bin"
    cut_waitForFrameMinSec 0 22.778
    cut_swapAndShowBuf
  
    ; "calm down!"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4DCE-9.bin"
    cut_waitForFrameMinSec 0 24.089
    cut_swapAndShowBuf
  
    ; "is taking it out on"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4DCE-10.bin"
    cut_waitForFrameMinSec 0 25.656
    cut_swapAndShowBuf
  
      ; "people that die don't"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x4DCE-11.bin"
    
;    cut_waitForFrameMinSec 0 27.569
;    cut_subsOff
    
    cut_waitForFrameMinSec 0 28.251
    cut_swapAndShowBuf
  
    ; "no! ayaka didn't"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4DCE-12.bin"
    cut_waitForFrameMinSec 0 30.676
    cut_swapAndShowBuf
  
    ; "she was killed"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4DCE-14.bin"
    cut_waitForFrameMinSec 0 34.386
    cut_swapAndShowBuf
  
      ; "look at this"
      SCENE_startNewStringAuto
      .incbin "out/script/strings/visual-0x4DCE-15.bin"
    
    cut_waitForFrameMinSec 0 35.622+0.350-0.017
    cut_subsOff
    
    cut_waitForFrameMinSec 0 36.944
    cut_swapAndShowBuf
  
    ; "it was stuck in ayaka's"
    SCENE_startNewStringAuto
    .incbin "out/script/strings/visual-0x4DCE-16.bin"
    cut_waitForFrameMinSec 0 38.868
    cut_swapAndShowBuf
  
    ; "it has ayaka's blood on it"
    cut_startNewString $190
    .incbin "out/script/strings/visual-0x4DCE-17.bin"
    cut_waitForFrameMinSec 0 41.175
    cut_swapAndShowBuf
  
      ; "even with this"
      cut_startNewString $1E0
      .incbin "out/script/strings/visual-0x4DCE-18.bin"
    
    cut_waitForFrameMinSec 0 42.678+0.300
    cut_subsOff
    
    cut_waitForFrameMinSec 0 44.352
    cut_swapAndShowBuf
    
    cut_waitForFrameMinSec 0 47.096
    cut_subsOff
  
    ; "do you think"
    cut_startNewString $1E0
    .incbin "out/script/strings/visual-0x4DCE-20.bin"
    cut_waitForFrameMinSec 0 48.301
    cut_swapAndShowBuf
    
    cut_waitForFrameMinSec 0 50.736
    cut_subsOff

    ; "no!"
    cut_startNewString $1F8
    .incbin "out/script/strings/visual-0x4DCE-21.bin"
    cut_waitForFrameMinSec 0 51.360
    cut_swapAndShowBuf

    ; "ayaka...was killed"
    cut_startNewString $1E0
    .incbin "out/script/strings/visual-0x4DCE-22.bin"
    cut_waitForFrameMinSec 0 52.804
    cut_swapAndShowBuf
    
    cut_waitForFrameMinSec 0 56.487
    cut_subsOff
  
    ;=====
    ; done
    ;=====
    
    ; cropping off
    cut_setCropOn $00
    
    ; target = vram $7000
    ; src = base+0x37F00 = 83:1F00
    ; size = 0x1000 bytes
    
    cut_terminator
.ends








