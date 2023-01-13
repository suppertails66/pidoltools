#ifndef PIDOLCMP_H
#define PIDOLCMP_H


#include "util/TStream.h"
#include "util/TBufStream.h"
#include "util/TArray.h"
#include "util/TByte.h"
#include <map>
#include <string>
#include <vector>

namespace Pce {


class PidolCmp {
public:
  
  static void decmp(BlackT::TStream& ifs, BlackT::TStream& ofs);
//  static void decmpBitstream(BlackT::TStream& ifs, BlackT::TStream& ofs);
  static void decmpRle(BlackT::TStream& ifs, BlackT::TStream& ofs);
  static void cmp(BlackT::TStream& ifs, BlackT::TStream& ofs);
  static void cmpBitstream(BlackT::TStream& ifs, BlackT::TStream& ofs);
  static void cmpRle(BlackT::TStream& ifs, BlackT::TStream& ofs);
  
protected:
  
  struct PidolDecompressor {
  public:
    PidolDecompressor(BlackT::TStream& ifs__,
                      BlackT::TStream& ofs__);
    
    void operator()();
    
  protected:
    BlackT::TStream& ifs;
    BlackT::TStream& ofs;
    
    BlackT::TByte mask;
    BlackT::TByte cmd;
    
    bool isRepeat;
    int length;
    BlackT::TByte repeatVal;
    
    BlackT::TByte fetchBit();
    BlackT::TByte fetchCmd();
  };
  
  struct PidolBitstreamCompressor {
  public:
    PidolBitstreamCompressor(BlackT::TStream& ifs__,
                      BlackT::TStream& ofs__);
    
    void operator()();
    
  protected:
    BlackT::TStream& ifs;
    BlackT::TStream& ofs;
    
    BlackT::TByte mask;
    BlackT::TByte cmd;
    
    void addBit(BlackT::TByte bit);
    void addByte(BlackT::TByte byt);
  };
  
  struct PidolRleCompressor {
  public:
    PidolRleCompressor(BlackT::TStream& ifs__,
                      BlackT::TStream& ofs__);
    
    void operator()();
  protected:
    BlackT::TStream& ifs;
    BlackT::TStream& ofs;
    
    int pendingAbsPos;
    int pendingAbsSz;
    
    const static int maxSz = 0x7F;
    const static int maxRepeatSz = 0x80;
    const static int minEfficientRepeatSz = 3;
    
    int getNextRepeatLen();
    void addCurrentAbs();
    void addRepeat(int len);
  };
  
};


}


#endif
