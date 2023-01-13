#ifndef YUNA2CMP_H
#define YUNA2CMP_H


#include "util/TStream.h"
#include "util/TBufStream.h"
#include "util/TArray.h"
#include "util/TByte.h"
#include <map>
#include <string>
#include <vector>

namespace Pce {


class Yuna2Cmp {
public:
  
  static void decmp(BlackT::TStream& ifs, BlackT::TStream& ofs);
//  static void decmpBitstream(BlackT::TStream& ifs, BlackT::TStream& ofs);
  static void decmpRle(BlackT::TStream& ifs, BlackT::TStream& ofs);
  static void cmp(BlackT::TStream& ifs, BlackT::TStream& ofs);
  static void cmpBitstream(BlackT::TStream& ifs, BlackT::TStream& ofs);
  static void cmpRle(BlackT::TStream& ifs, BlackT::TStream& ofs);
  
protected:
  
  struct Yuna2Decompressor {
  public:
    Yuna2Decompressor(BlackT::TStream& ifs__,
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
  
  struct Yuna2BitstreamCompressor {
  public:
    Yuna2BitstreamCompressor(BlackT::TStream& ifs__,
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
  
  struct Yuna2RleCompressor {
  public:
    Yuna2RleCompressor(BlackT::TStream& ifs__,
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
