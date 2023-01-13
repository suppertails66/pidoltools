
CdImage cd
  cd.addTrackStart(1, "AUDIO")
    cd.addTrackIndex(1)
    cd.addWavAudio("pidol_01.wav")
  cd.addTrackEnd()
  
  cd.addTrackStart(2, "MODE1RAW")
    cd.addModeChange("MODE1")
    cd.addPregapMsf(0, 3, 0)
    cd.addTrackIndex(1)
    cd.addRawData("pidol_02_build.iso")
  cd.addTrackEnd()
  
  cd.addTrackStart(3, "AUDIO")
    cd.addPregapMsf(0, 2, 0)
    cd.addTrackIndex(1)
    cd.addWavAudio("pidol_03.wav")
  cd.addTrackEnd()
  
  cd.addTrackStart(4, "AUDIO")
    cd.addTrackIndex(1)
    cd.addWavAudio("pidol_04.wav")
  cd.addTrackEnd()
  
  cd.addTrackStart(5, "AUDIO")
    cd.addTrackIndex(1)
    cd.addWavAudio("pidol_05.wav")
  cd.addTrackEnd()
  
  cd.addTrackStart(6, "AUDIO")
    cd.addTrackIndex(1)
    cd.addWavAudio("pidol_06.wav")
  cd.addTrackEnd()
  
  cd.addTrackStart(7, "AUDIO")
    cd.addTrackIndex(1)
    cd.addWavAudio("pidol_07.wav")
  cd.addTrackEnd()
  
  cd.addTrackStart(8, "AUDIO")
    cd.addTrackIndex(1)
    cd.addWavAudio("pidol_08.wav")
  cd.addTrackEnd()
  
  cd.addTrackStart(9, "AUDIO")
    cd.addTrackIndex(1)
    cd.addWavAudio("pidol_09.wav")
  cd.addTrackEnd()
  
  cd.addTrackStart(10, "AUDIO")
    cd.addTrackIndex(1)
    cd.addWavAudio("pidol_10.wav")
  cd.addTrackEnd()
  
  cd.addTrackStart(11, "AUDIO")
    cd.addTrackIndex(1)
    cd.addWavAudio("pidol_11.wav")
  cd.addTrackEnd()
  
  cd.addTrackStart(12, "AUDIO")
    cd.addTrackIndex(1)
    cd.addWavAudio("pidol_12.wav")
  cd.addTrackEnd()
  
  cd.addTrackStart(13, "AUDIO")
    cd.addTrackIndex(1)
    cd.addWavAudio("pidol_13.wav")
  cd.addTrackEnd()
  
  cd.addTrackStart(14, "AUDIO")
    cd.addTrackIndex(1)
    cd.addWavAudio("pidol_14.wav")
  cd.addTrackEnd()
  
  cd.addTrackStart(15, "AUDIO")
    cd.addTrackIndex(1)
    cd.addWavAudio("pidol_15.wav")
  cd.addTrackEnd()
  
  cd.addTrackStart(16, "AUDIO")
    cd.addTrackIndex(1)
    cd.addWavAudio("pidol_16.wav")
  cd.addTrackEnd()
  
  cd.addTrackStart(17, "AUDIO")
    cd.addTrackIndex(1)
    cd.addWavAudio("pidol_17.wav")
  cd.addTrackEnd()
  
  cd.addTrackStart(18, "AUDIO")
    cd.addTrackIndex(1)
    cd.addWavAudio("pidol_18.wav")
  cd.addTrackEnd()
  
  cd.addTrackStart(19, "AUDIO")
    cd.addTrackIndex(1)
    cd.addWavAudio("pidol_19.wav")
  cd.addTrackEnd()
  
  cd.addTrackStart(20, "AUDIO")
    cd.addTrackIndex(1)
    cd.addWavAudio("pidol_20.wav")
  cd.addTrackEnd()
  
  cd.addTrackStart(21, "AUDIO")
    cd.addTrackIndex(1)
    cd.addWavAudio("pidol_21.wav")
  cd.addTrackEnd()
  
  cd.addTrackStart(22, "AUDIO")
    cd.addTrackIndex(1)
    cd.addWavAudio("pidol_22.wav")
  cd.addTrackEnd()
  
  cd.addTrackStart(23, "AUDIO")
    cd.addTrackIndex(1)
    cd.addWavAudio("pidol_23.wav")
  cd.addTrackEnd()
  
  cd.addTrackStart(24, "AUDIO")
    cd.addTrackIndex(1)
    cd.addWavAudio("pidol_24.wav")
  cd.addTrackEnd()
  
  cd.addTrackStart(25, "AUDIO")
    cd.addTrackIndex(1)
    cd.addWavAudio("pidol_25.wav")
  cd.addTrackEnd()
  
cd.exportBinCue("pidol_build")
