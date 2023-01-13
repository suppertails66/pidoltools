#include "pidol/PidolCmp.h"
#include "util/TStringConversion.h"
#include "util/TBufStream.h"
#include "util/TIfstream.h"
#include "util/TOfstream.h"
#include "util/TBufStream.h"
#include "util/TByte.h"
#include "util/TParse.h"
#include "util/MiscMath.h"
#include "exception/TGenericException.h"
#include <vector>
#include <map>
#include <cctype>
#include <iostream>
#include <fstream>

using namespace BlackT;

namespace Pce {


void PidolCmp::decmp(BlackT::TStream& ifs, BlackT::TStream& ofs) {
  PidolDecompressor(ifs, ofs)();
}

//void PidolCmp::decmpBitstream(BlackT::TStream& ifs, BlackT::TStream& ofs) {
//  
//}

void PidolCmp::decmpRle(BlackT::TStream& ifs, BlackT::TStream& ofs) {
  while (!ifs.eof()) {
    TByte next = ifs.get();
//    int len = (next & 0x7F);
    int len = ((next - 1) & 0x7F) + 1;
    if ((next & 0x80) != 0) {
      TByte val = ifs.get();
      for (int i = 0; i < len; i++) {
        ofs.put(val);
      }
    }
    else {
      for (int i = 0; i < len; i++) {
        ofs.put(ifs.get());
      }
    }
  }
}

void PidolCmp::cmp(BlackT::TStream& ifs, BlackT::TStream& ofs) {
  TBufStream temp;
  cmpBitstream(ifs, temp);
  temp.seek(0);
  cmpRle(temp, ofs);
}

void PidolCmp::cmpBitstream(BlackT::TStream& ifs, BlackT::TStream& ofs) {
/*  TBufStream temp;
  PidolBitstreamCompressor(ifs, temp)();
  temp.seek(0);
  while (!temp.eof()) 
    ofs.put(temp.get()); */
  PidolBitstreamCompressor(ifs, ofs)();
}

void PidolCmp::cmpRle(BlackT::TStream& ifs, BlackT::TStream& ofs) {
  PidolRleCompressor(ifs, ofs)();
}

PidolCmp::PidolDecompressor::PidolDecompressor(BlackT::TStream& ifs__,
                  BlackT::TStream& ofs__)
  : ifs(ifs__),
    ofs(ofs__),
    mask(0x01),
    cmd(0x00),
    isRepeat(false),
    length(0x00),
    repeatVal(0x00) { }

void PidolCmp::PidolDecompressor::operator()() {
  while (!ifs.eof()) {
//    std::cerr << std::hex << ifs.tell() << std::endl;
    if (fetchBit() == 0) {
      if (fetchBit() == 0) {
        // 00 = output zero byte
        ofs.put(0x00);
      }
      else {
        // 01 = output 0xFF byte
        ofs.put(0xFF);
      }
    }
    else {
      // 1 = output literal byte
      TByte value = 0;
      for (int i = 0; i < 8; i++) {
        value <<= 1;
        value |= fetchBit();
      }
      
      // a literal-encoded zero terminates output
      if (value == 0) break;
      
      ofs.put(value);
    }
  }
}

BlackT::TByte PidolCmp::PidolDecompressor::fetchBit() {
  mask >>= 1;
//  std::cerr << "mask: " << std::hex << (unsigned int)mask << std::endl;
  if (mask == 0) {
    mask = 0x80;
    cmd = fetchCmd();
  }
  return ((cmd & mask) == 0) ? 0 : 1;
}

BlackT::TByte PidolCmp::PidolDecompressor::fetchCmd() {
  if (length == 0) {
    TByte next = ifs.get();
    isRepeat = (next & 0x80) != 0;
    --next;
    length = next & 0x7F;
    if (isRepeat) repeatVal = ifs.get();
  }
  else {
    --length;
  }
  
  if (isRepeat) return repeatVal;
  else return ifs.get();
}

PidolCmp::PidolBitstreamCompressor::PidolBitstreamCompressor(
                  BlackT::TStream& ifs__,
                  BlackT::TStream& ofs__)
  : ifs(ifs__),
    ofs(ofs__),
    mask(0x80),
    cmd(0x00) { }
  
void PidolCmp::PidolBitstreamCompressor::operator()() {
  while (!ifs.eof()) {
//    std::cerr << std::hex << ifs.tell() << " " << ofs.tell() << std::endl;
    
    TByte next = ifs.get();
    if (next == 0x00) {
      addBit(0);
      addBit(0);
    }
    else if (next == 0xFF) {
      addBit(0);
      addBit(1);
    }
    else {
      addBit(1);
      addByte(next);
    }
  }
  
  // write terminator (literal zero)
  addBit(1);
  addByte(0);
  
  // write any pending final byte
  if (mask != 0x80) ofs.put(cmd);
}

void PidolCmp::PidolBitstreamCompressor::addBit(BlackT::TByte bit) {
  if (bit != 0) cmd |= mask;
  mask >>= 1;
  if (mask == 0) {
    ofs.put(cmd);
    cmd = 0x00;
    mask = 0x80;
  }
}

void PidolCmp::PidolBitstreamCompressor::addByte(BlackT::TByte byt) {
  for (TByte mask = 0x80; mask != 0; mask >>= 1) addBit(byt & mask);
}

PidolCmp::PidolRleCompressor::PidolRleCompressor(
                  BlackT::TStream& ifs__,
                  BlackT::TStream& ofs__)
  : ifs(ifs__),
    ofs(ofs__),
    pendingAbsPos(-1),
    pendingAbsSz(0) { }
  
void PidolCmp::PidolRleCompressor::operator()() {
  while (!ifs.eof()) {
//    std::cerr << std::hex << ifs.tell() << " " << ofs.tell() << std::endl;
    
    int nextRepeatLen = getNextRepeatLen();
    MiscMath::clamp(nextRepeatLen, 0, maxRepeatSz);
    
//    std::cerr << "  " << std::hex << nextRepeatLen << std::endl;
    
    // adding this case doesn't compress any better, but is required
    // to match the output of the original compressor
    if ((pendingAbsSz == 0)
        && (nextRepeatLen == (minEfficientRepeatSz - 1))) {
      addRepeat(nextRepeatLen);
    }
    else if (nextRepeatLen < minEfficientRepeatSz) {
      if (pendingAbsSz == 0) pendingAbsPos = ifs.tell();
      
      ifs.get();
      ++pendingAbsSz;
      
      if (pendingAbsSz >= maxSz) {
        addCurrentAbs();
      }
    }
    else {
      addCurrentAbs();
      addRepeat(nextRepeatLen);
    }
  }
  
  addCurrentAbs();
}

int PidolCmp::PidolRleCompressor::getNextRepeatLen() {
  if (ifs.eof()) return 0;
  
  int basePos = ifs.tell();
  TByte val = ifs.get();
  int sz = 1;
  while (!ifs.eof() && ((TByte)ifs.get() == val)) ++sz;
  
  ifs.seek(basePos);
  return sz;
}

void PidolCmp::PidolRleCompressor::addCurrentAbs() {
  if (pendingAbsSz == 0) return;
  
  TByte cmd = pendingAbsSz;
//  ++cmd;
  cmd &= 0x7F;
  
  ofs.put(cmd);
  
  int oldPos = ifs.tell();
  ifs.seek(pendingAbsPos);
  for (int i = 0; i < pendingAbsSz; i++) ofs.put(ifs.get());
  
  ifs.seek(oldPos);
  pendingAbsSz = 0;
  pendingAbsPos = -1;
}

void PidolCmp::PidolRleCompressor::addRepeat(int len) {
  if (len == 0) return;
  
  TByte cmd = len;
//  ++cmd;
  cmd &= 0x7F;
  cmd |= 0x80;
  
  ofs.put(cmd);
  TByte value = ifs.get();
  ofs.put(value);
  
  ifs.seekoff(len - 1);
}


}
