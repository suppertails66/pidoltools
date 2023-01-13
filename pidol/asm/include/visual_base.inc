
;==============================================================================
; 
;==============================================================================

.include "include/global.inc"
.include "include/scene_adv_common.inc"

;===================================
; 
;===================================

.define fixedSlot 0
.define fixedSlot2 1
.define freeSlot 2

.memorymap
   defaultslot     0
   
   slotsize        $2000
   slot            fixedSlot       $4000
   slot            fixedSlot2       $6000
   slot            freeSlot       $8000
.endme

.rombankmap
  bankstotal $20
  
  banksize $2000
  banks $20
.endro

.emptyfill $FF

.background ROMNAME

;===================================
; required defines
;===================================

.define newZpFreeReg $10
.define newZpScriptReg $12

.define fixedBank 0
.define fixedBank2 1
.define freeBank 2

.define defaultSubtitleEngineOn $FF

; TODO: not specific to this engine?
.define satMemBuf $2ACF
;.define currentSpriteCount $9FFB

.unbackground $1C20 $1FFF

.define fixedBankMemPage $68
.define freeBankMemPage $6A

;===================================
; auto-generated include
; (including unbackground statements)
;===================================

.include ROMNAME_GEN_INC

;==============================================================================
; HACK: fix timer checks so scenes don't freeze on current mainline mednafen
;==============================================================================

.bank fixedBank2 slot fixedSlot2
.orga doObjTimerSet1+($6FC1-$6F97)
.section "mednafen scene timing fix 1" overwrite
  jmp checkObjSceneTimerOverflow_ops
.ends

.bank fixedBank2 slot fixedSlot2
.orga doObjTimerSet2+($7188-$7150)
.section "mednafen scene timing fix 2" overwrite
  jmp checkObjSceneTimerOverflow_ops
.ends

.bank fixedBank slot fixedSlot
.section "mednafen scene timing fix 3" free
;    bsr checkObjSceneTimerOverflow
;    ; make up work
;    lda #$83
;    rts
  
;  checkObjSceneTimerOverflow:
  checkObjSceneTimerOverflow_ops:
    ; make up work
    sta $13.b
    
    ; HACK: assume that if high byte of delay timer is >= 0xFC,
    ; overflow has occurred
    ldy #7
    lda ($10.b),Y
    cmp #$FC
    bcc +
      ; scene timer -= amount by which timer overflowed
      ; without this, e.g. case 2a ending will start screwing up
      ; halfway through and eventually end up stuck on a black screen
      sei
        dey
        lda sceneTimerLo.w
        clc
        adc ($10.b),Y
        sta sceneTimerLo.w
        iny
        lda sceneTimerHi.w
        adc ($10.b),Y
        sta sceneTimerHi.w
      cli
      
      ; force delay timer to zero
      cla
      sta ($10.b),Y
      dey
      sta ($10.b),Y
    +:
    rts
.ends

;==============================================================================
; rcr interrupt processing
;==============================================================================

;===================================
; if original rcr system not on,
; schedule our new interrupts
; if they're enabled
;===================================

.bank fixedBank slot fixedSlot
.orga $4223
.section "rcr enable 1" overwrite
  jmp checkRcrEnableOrigOff
.ends

.bank fixedBank slot fixedSlot
.section "rcr enable 2" free
  checkRcrEnableOrigOff:
    ; make up work
;    lda #$06
;    sta $0000.w
    st0 #vdp_regRcr
    
    lda newRcrOn.w
    bne +
      ; use original logic
      jmp $4228
    +:
    
    ; set target rcr line (-1 so we can set up for next line)
    st1 #<(newRcrPicEndLine+rcrBaseLine-1)
    st2 #>(newRcrPicEndLine+rcrBaseLine-1)
    ; set state to waiting for new start
    ; (skipping waiting for orig end, since orig is not in use)
    lda #newRcr_state_waitingForPicEnd
    sta newRcrState.w
    
    jmp $4232
  
  newRcrOn:
    .db $00
  newRcrState:
    .db $00
.ends

;===================================
; if original rcr system is on,
; schedule our new interrupts
; if they're applicable
;===================================

;.define rcrStructsControlBaseB $75
.define rcrStructsMainBaseB $7D

.bank fixedBank slot fixedSlot
.orga $4328
.section "rcr orig end check 1" overwrite
  jmp checkRcrEnableOrigOn
.ends

.bank fixedBank slot fixedSlot
.section "rcr orig end check 2" free
  checkRcrEnableOrigOn:
    ; make up work
    ; check high byte of next rcr target
    lda rcrStructsMainBaseB+9.b,X
    bpl +
    ; if high bit of high byte of next rcr target set
      ; use original logic
      jmp $432C
    +:
    
    ; end of original rcr interrupts reached
    
    ; if subtitles aren't on, do nothing
    lda subtitleDisplayOn.w
    beq @done
    
    ; check if new rcr on
    lda newRcrOn.w
    beq @done
      ; if last rcr < pic end line, wait for pic end line
      ; and do rest of normal new interrupt handling.
      ; otherwise, assume no action needed (i.e. the image is deliberately
      ; being cropped to a height that will include the subtitle area).
      ; TODO: is this assumption correct?
      ; 
      ; if +7 nonzero, the target line is still in raw RCR format
      ; and needs to be converted by subtracting 0x40.
      ; the high byte of the result will always be 0, so we don't need
      ; to bother with it.
      lda rcrStructsMainBaseB+7.b,X
      beq +
        lda rcrStructsMainBaseB+0.b,X
        sec
        sbc rcrBaseLine
        sta rcrStructsMainBaseB+0.b,X
;        bcs +
;          dec rcrStructsMainBaseB+1.b,X
      +:
      
      lda rcrStructsMainBaseB+0.b,X
      cmp #<(newRcrPicEndLine-1)
      bcs @not_startWaitForPicEnd
        ; inc should be fine, but let's play it safe
  ;      inc newRcrState.w
        lda #newRcr_state_waitingForPicEnd
        sta newRcrState.w
        ; set up next line target
        st0 #vdp_regRcr
        st1 #<(newRcrPicEndLine+rcrBaseLine-1)
        st2 #>(newRcrPicEndLine+rcrBaseLine-1)
        rts
      @not_startWaitForPicEnd:
      cmp #<(newRcrStartLine-1)
      bcs @not_startWaitForNewStart
        lda #newRcr_state_waitingForNewStart
        sta newRcrState.w
        ; set up next line target
;        st0 #vdp_regRcr
;        st1 #<(newRcrStartLine+rcrBaseLine-1)
;        st2 #>(newRcrStartLine+rcrBaseLine-1)
;        rts
        jsr turnOffBgAndSprites
        jmp setUpWaitingForNewStart
      @not_startWaitForNewStart:
      cmp #<(newRcrEndLine-1)
      bcs @done
        lda #newRcr_state_waitingForNewEnd
        sta newRcrState.w
        ; set up next line target
;        st0 #vdp_regRcr
;        st1 #<(newRcrEndLine+rcrBaseLine-1)
;        st2 #>(newRcrEndLine+rcrBaseLine-1)
        jsr turnOffBgAndTurnOnSprites
        jmp setUpWaitingForNewEnd
    @done:
    rts
.ends

;===================================
; new rcr handling logic
;===================================

.define origRcrEnableFlagB $77
.define vdpCrMemBackupB $F3

.bank fixedBank slot fixedSlot
.orga $427E
.section "new rcr handler 1" overwrite
  jmp doNewRcrHandlerCheck
.ends

.bank fixedBank slot fixedSlot
.section "new rcr handler 2" free
  doNewRcrHandlerCheck:
    ; only use new logic if new rcr is on and state is nonzero
    ; (i.e. not waiting for end of original rcr handlers)
    lda newRcrOn.w
    beq @orig
    lda newRcrState.w
    bne @new
    @orig:
      ; use original logic
      lda origRcrEnableFlagB.b
      bpl +
        jmp $4282
      +:
;      bra @done
      jmp $42B9
    @new:
    
    ; jump to state handler
    jsr jumpToNewRcrStateHandler
    
    @done:
    ; return from interrupt
    jmp $4275
  
  jumpToNewRcrStateHandler:
    dea
    asl
    tax
    jmp (newRcrStateHandlerTable.w,X)
  
  newRcrStateHandlerTable:
    .dw rcrStateHandler_waitingForPicEnd
    .dw rcrStateHandler_waitingForNewStart
    .dw rcrStateHandler_waitingForNewEnd
  
  rcrStateHandler_waitingForPicEnd:
    ; bg and sprites off
    bsr turnOffBgAndSprites
    
    ; if subtitles are not currently being displayed, stop here
    lda subtitleDisplayOn.w
    bne @nextState
    @stop:
      stz newRcrState.w
      rts
    @nextState:
    ; go to next state
    inc newRcrState.w
    ; set up next line target
    jmp setUpWaitingForNewStart
    
  rcrStateHandler_waitingForNewStart:
    ; bg off, sprites on
;    st0 #vdp_regCr
;    lda vdpCrMemBackupB.b
;    and #$7F
;    ora #$40
;    sta vdpCrMemBackupB.b
;    sta vdp_dataLo.w
    
    ; do not open non-cropped area if subtitles were not active on last frame.
    ; this prevents 1-frame glitches when activating subtitles.
    lda prevSubtitleDisplayOn.w
    beq rcrStateHandler_waitingForPicEnd@stop

    bsr turnOffBgAndTurnOnSprites
    
    ; go to next state
    inc newRcrState.w
    
    ; set up next line target
    jmp setUpWaitingForNewEnd
  
  rcrStateHandler_waitingForNewEnd:
    ; bg and sprites off
    bsr turnOffBgAndSprites
    
    ; reset state
    stz newRcrState.w
    rts
  
  turnOffBgAndTurnOnSprites:
    lda vdpCrMemBackupB.b
    and #$7F
    ora #$40
    bra turnOffBgAndSprites@finish
  
  turnOffBgAndSprites:
;    st0 #vdp_regCr
    lda vdpCrMemBackupB.b
    and #$3F
    @finish:
    st0 #vdp_regCr
    sta vdpCrMemBackupB.b
    sta vdp_dataLo.w
    rts
  
  setUpWaitingForNewStart:
    st0 #vdp_regRcr
    lda rcrCropTargetsMultipleLines.w
    bne @multiLine
      st1 #<(newRcrStartLine+rcrBaseLine-1+8)
      st2 #>(newRcrStartLine+rcrBaseLine-1+8)
      bra @lineSet
    @multiLine:
      st1 #<(newRcrStartLine+rcrBaseLine-1)
      st2 #>(newRcrStartLine+rcrBaseLine-1)
    @lineSet:
    rts
  
  setUpWaitingForNewEnd:
    st0 #vdp_regRcr
    lda rcrCropTargetsMultipleLines.w
    bne @multiLine
      st1 #<(newRcrEndLine+rcrBaseLine-1-8)
      st2 #>(newRcrEndLine+rcrBaseLine-1-8)
      bra @lineSet
    @multiLine:
      st1 #<(newRcrEndLine+rcrBaseLine-1)
      st2 #>(newRcrEndLine+rcrBaseLine-1)
    @lineSet:
    rts
    
    
.ends

;==============================================================================
; subtitle engine
;==============================================================================

;===================================
; extra defines
;===================================

;.define useFadeAutoProtection 1

;.define useBigPaletteWriteProtection 1
;.define bigPaletteWriteOccurredB $50

;.define useLagAutoProtection 1
;.define lagAutoProtectCounterAddrB $64

;===================================
; required extra routines
;===================================

; WARNING: for use in interrupts!
;          do not use outside of them, and do not use them in cases
;          where one interrupt can interrupt another.
;          otherwise, saved values may be trashed at any time during execution.
.bank fixedBank slot fixedSlot
.section "scene adv routines 1" free
  ovlScene_setUpStdBanks:
    tma #$10
    sta ovlScene_restoreOldBanks@slot3+1.w
    tma #$20
    sta ovlScene_restoreOldBanks@slot4+1.w
    tma #$40
    sta ovlScene_restoreOldBanks@slot5+1.w
    
    lda #freeBankMemPage
    tam #$10
    ina
;    lda #freeBankMemPage
    tam #$20
    ina
    tam #$40
    
    rts
  
  ovlScene_restoreOldBanks:
    @slot3:
    lda #$00
    tam #$10
    @slot4:
    lda #$00
    tam #$20
    @slot5:
    lda #$00
    tam #$40
    
    rts
.ends

;===================================
; patches to use engine
;===================================

; vsync injection
.bank fixedBank slot fixedSlot
.orga $4259
.section "scene adv vsync injection 1" overwrite
  jmp doAdvSceneCall
.ends

.bank fixedBank slot fixedSlot
.section "scene adv vsync injection 2" free
  doAdvSceneCall:
    ; make up work
    stz $50.b
    ; make up work of entire palette transfer because that's
    ; the simplest option
    bbr5 $6C,+
      ; palette stuff
      lda #$00
      sta $0402.w
      lda #$00
      sta $0403.w
      tia $2D74,$0404,$0300
      lda #$01
      sta $50.w
      rmb5 $6C
    +:
    
    .ifdef useVsyncBgSprOffHack
      ; HACK: force bg + sprites off at vsync unless disabled
      ; for scene via a define.
      ; normally, line interrupts are used to turn them back on
      ; on the first line of the display, so this shouldn't have any effect
      ; under standard conditions.
      ; if the game lags (or additional lag is induced by our extra code
      ; running at vsync), this will prevent flicker at the top of the screen
      ; from the top-line interrupt being handled too late and leaving
      ; the first few lines unhidden.
/*      st0 #$05
      lda $F3.b
      and #$3F
      sta $F3.b
      sta $0002.w*/
      ; oh right, stupid fucking burst mode.
      ; can't have both bg and sprites off at start of frame or it's
      ; impossible to turn on either one for the duration.
      ; or maybe this is mednafen not latching it at the right time again
      ; like with yuna 2, i don't even know.
      ; well, fuck it, we can just leave sprites on.
      ; after hours spent trying and failing to track down the source of
      ; the mysterious lag that's ultimately causing issues, i'm willing to accept
      ; whatever problems might remain.
      st0 #$05
      lda $F3.b
      and #$7F
      sta $F3.b
      sta $0002.w
    .endif
    
    ; do nothing if subtitle engine not on
    lda subtitleEngineOn.w
    beq @done
      jsr ovlScene_setUpStdBanks
      ; restores old banks when done
      jsr newSyncLogic
  ;    jsr ovlScene_restoreOldBanks
    @done:
    ; make up work
    jmp $4275
.ends

;===================================
; font
;===================================

.bank freeBank slot freeSlot
.section "visual scene font" free
  ovlScene_font:
;    .incbin "out/font/font.bin"
    .incbin "out/font/font_scene.bin"
  
  ovlScene_fontWidthTable:
;    .incbin "out/font/fontwidth.bin"
    .incbin "out/font/fontwidth_scene.bin"
.ends

;===================================
; transfer generated sprites
;===================================

.bank fixedBank2 slot fixedSlot2
.orga genSpriteTable+($7398-$7384)
.section "scene adv sprite generation 1" SIZE 4 overwrite
  jsr sendSubtitleSprites
  nop
.ends

.bank fixedBank slot fixedSlot
.section "scene adv sprite generation 2" free
  sendSubtitleSprites:
    ; make up work
    sta $15.b
    
    tma #$10
    pha
    lda #freeBankMemPage
    tam #$10
      lda subtitleDisplayOn.w
      beq @noSceneSprites
      lda currentSubtitleSpriteAttributeQueueSize.w
      beq @noSceneSprites
        ; save size to transfer instruction
  ;      sta @transferCmd+5.w
        sta @loopSizeInstr+1.w
        
        ; set target crop for frame
  ;      lda rcrCropTargetsMultipleLines.w
  ;      sta currentFrame_rcrCropTargetsMultipleLines.w
        
        ; add size to base dst
        lda $14.b
        clc
        adc currentSubtitleSpriteAttributeQueueSize.w
        sta $14.b
        bcc +
          inc $15.b
        +:
        
        ; set src address
        lda currentSubtitleSpriteAttributeQueuePtr+0.w
        sta @transferCmd+1.w
        lda currentSubtitleSpriteAttributeQueuePtr+1.w
        sta @transferCmd+2.w
        
        clx
        -:
          @transferCmd:
          lda $0000.w,X
          sta satMemBuf.w,X
          
          inx
          @loopSizeInstr:
          cpx #$00
          bne -
        
        ; return initial currentSpriteCount
        txa
        lsr
        lsr
        lsr
        sta currentSpriteCount.w
      @noSceneSprites:
      ; make up work
      ldx #$05
    pla
    tam #$10
    rts
.ends

;===================================
; increment sync var for cd track start
;===================================

.bank fixedBank2 slot fixedSlot2
.orga playCdTrack+($6EC3-$6EA7)
.section "scene adv sync var cd 1" overwrite
  jsr doCdSyncVarInc
.ends

.bank fixedBank slot fixedSlot
.section "scene adv sync var cd 2" free
  doCdSyncVarInc:
    jsr incrementSyncVarCounter
    ; make up work
    jmp CD_FADE
.ends

.bank fixedBank slot fixedSlot
.section "scene adv sync var cd 3" free
  incrementSyncVarCounter:
    tma #$10
    pha
    lda #freeBankMemPage
    tam #$10
      jsr incrementSyncVarCounterExt
    pla
    tam #$10
    rts
.ends

;===================================
; increment sync var for adpcm cplay
;===================================

.bank fixedBank2 slot fixedSlot2
.orga cplayAdpcm+($6F0D-$6EDB)
.section "scene adv sync var cplay adpcm 1" overwrite
  jmp doCplayAdpcmVarInc
.ends

.bank fixedBank slot fixedSlot
.section "scene adv sync var cplay adpcm 2" free
  doCplayAdpcmVarInc:
  doSetSceneTimerVarInc:
    ; make up work
    sta $13.b
    jmp incrementSyncVarCounter
.ends

;===================================
; prevent vram writes in new code
; while original code is currently
; writing it
;===================================

.bank fixedBank2 slot fixedSlot2
.orga sceneVramCopy+($657E-$657E)
.section "scene adv vram write protect 1" overwrite
  jmp doVramCopyProtectStart_vramWrite
.ends

.bank fixedBank2 slot fixedSlot2
.orga sceneVramCopy+($65E0-$657E)
.section "scene adv vram write protect 2" overwrite
  jmp doVramCopyProtectEnd_vramWrite
.ends

.bank fixedBank slot fixedSlot
.section "scene adv vram write protect 3" free
  doVramCopyProtectExt:
    tma #$10
    pha
    lda #scdBaseMemPage+freeBank
    tam #$10
      inc blockVramWrites.w
    pla
    tam #$10
    rts
    
  doVramCopyProtectEndExt:
    tma #$10
    pha
    lda #scdBaseMemPage+freeBank
    tam #$10
      stz blockVramWrites.w
    pla
    tam #$10
    rts
  
  doVramCopyProtectStart_vramWrite:
    jsr doVramCopyProtectExt
    
    ; make up work
    stz $28.b
    ldy #$01
    jmp sceneVramCopy+($6582-$657E)
    
  doVramCopyProtectEnd_vramWrite:
    jsr doVramCopyProtectEndExt
    
    ; make up work
    lda $12.b
    clc 
    jmp sceneVramCopy+($65E3-$657E)
  
  doVramCopyProtectStart_tilemapWrite:
    jsr doVramCopyProtectExt
    
    ; make up work
    lda #$05
    sta $6A.b
    jmp sceneTilemapCopy+($6742-$66EB)
    
  doVramCopyProtectEnd_tilemapWrite:
    ; make up work
    sta $13.b
    pha
      jsr doVramCopyProtectEndExt
    pla
    rts
.ends

;===================================
; prevent vram writes in new code
; when tilemaps are being transferred
;===================================

.bank fixedBank2 slot fixedSlot2
.orga sceneTilemapCopy+($673E-$66EB)
.section "scene adv tilemap write protect 1" overwrite
  jmp doVramCopyProtectStart_tilemapWrite
.ends

.bank fixedBank2 slot fixedSlot2
.orga sceneTilemapCopy+($67AD-$66EB)
.section "scene adv tilemap write protect 2" overwrite
  jmp doVramCopyProtectEnd_tilemapWrite
.ends

;===================================
; fixed bank hacks
;===================================

; TODO

;.bank 0 slot 0
;.orga advSceneBlockStartPtr
;.section "advscene end of bank pointer + content marker" overwrite
;  .dw scriptData
;  .db advScenePresentMarkerA,advScenePresentMarkerB
;.ends

;===================================
; engine
;===================================

.include "include/scene_adv.inc"

;==============================================================================
; mid-frame CR write fixes
;==============================================================================

; this is a bug in the original game which is exacerbated by the hack:
; mid-frame updates to the VDP CR are not interrupt-protected,
; and if a line interrupt happens to occur in the time between the game loading
; a value and writing the updated value back, it will end up in the wrong state.
; FIXME: this most likely applies to every existing CR write in the program

.bank fixedBank slot fixedSlot
.section "cr write fix 1" free
  crLowerByteOrFix:
    sei
      lda #$0C
      ora $F3.b
      sta vdp_dataLo.w
    cli
    rts
  
  crUpperByteAndFix:
    sei
      lda #$E7
      and $F4.b
      sta vdp_dataHi.w
    cli
    rts
.ends

; sprite table generator
; (seems to be the biggest culprit)
.bank fixedBank2 slot fixedSlot2
.orga genSpriteTable+($73E3-$7384)
.section "cr write fix 2" overwrite
  jsr crLowerByteOrFix
  jsr crUpperByteAndFix
  jmp genSpriteTable+($73F3-$7384)
.ends

;==============================================================================
; controller read interrupt protection
;==============================================================================

; the game reads the controllers immediately after the end of
; its vsync wait loop. to do so, it disables interrupts.
; this is normally okay, since the controller read is supposed to occur
; immediately after vsync.
; however, if lag occurs, then the end of the vsync wait loop could
; actually happen at any point during the frame, which means that disabling
; interrupts for the controller read may interfere with e.g. line interrupts.
; since these are just cutscenes, and the controller input isn't very important
; anyways, we just check if lag has occurred and skip the read if so.
; the only interactivity in these scenes is pressing a button to skip them,
; and it's no big deal if that occasionally fails because the user hit the
; button during a lag period -- this occurs all the time in the original game
; anyway due to the use of AD_CPLAY for audio.

.bank fixedBank slot fixedSlot
.orga $4CF2
.section "controller read protect 1" overwrite
  jmp doControllerReadProtect
.ends

.bank fixedBank slot fixedSlot
.section "controller read protect 2" free
  doControllerReadProtect:
    ; check vsync counter.
    ; this will be 1 if vsync only occurred once between this frame
    ; and the previous one, i.e. there was no lag.
    lda $64.b
    cmp #$02
    bcs @lagged
    ; if no lag
      ; make up work
      lda $10.b
      pha
      jmp $4CF5
    @lagged:
    ; do nothing
    rts
.ends


