#include "pidol/PidolTextScript.h"
#include "util/TStringConversion.h"
#include "util/TBufStream.h"
#include "util/TIfstream.h"
#include "util/TOfstream.h"
#include "util/TBufStream.h"
#include "util/TByte.h"
#include "util/TParse.h"
#include "exception/TGenericException.h"
#include <vector>
#include <map>
#include <cctype>
#include <iostream>
#include <fstream>

using namespace BlackT;

namespace Pce {


bool PidolTextScript::isOp(int opcode) {
  if ((opcode < 0) || (opcode >= opsEnd)) return false;
  return true;
}

int PidolTextScript::getOpArgsSize(int opcode) {
  if (!isOp(opcode)) return 0;
  
  int result = 0;
  
  switch (opcode) {
    case 0x02:
    case 0x03:
    case 0x04:
    case 0x05:
    case 0x06:
    case 0x07:
    case 0x09:
    case 0x0E:
    case 0x0F:
    case 0x10:
    case 0x12:
    case 0x13:
    case 0x16:
    case 0x18:
    case 0x19:
    case 0x1A:
    case 0x1E:
    case 0x1F:
      result = 0;
      break;
    case 0x00:
    case 0x01:
    case 0x08:
    case 0x0D:
    case 0x15:
    case 0x17:
    case 0x1B:
      result = 1;
      break;
    case 0x11:
    case 0x1D:
      result = 2;
      break;
    case 0x0A:
    case 0x0B:
    case 0x0C:
      result = 5;
      break;
    case 0x14:
      result = 8;
      break;
    case 0x1C:
      result = 9;
      break;
    default:
      break;
  }
  
  return result;
}

bool PidolTextScript::isInlineableOp(int opcode) {
  if (!isOp(opcode)) return false;
  
  switch (opcode) {
    case op_fcolor:
    case op_scolor:
    case op_newline:
    case op_size1x:
    case op_size2x:
    case op_size3x:
    case op_speed:
    case op_br_noxreset:
    case op_spaces:
    // ?
    case op_expression:
    // ?
//    case op_subimg:
      return true;
      break;
    default:
      break;
  }
  
  return false;
}

bool PidolTextScript::isTerminator(int opcode) {
  if (!isOp(opcode)) return false;
  
  switch (opcode) {
    case op_end16:
    case op_end1A:
      return true;
      break;
    default:
      break;
  }
  
  return false;
}


}
