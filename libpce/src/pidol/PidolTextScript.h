#ifndef PIDOLTEXTSCRIPT_H
#define PIDOLTEXTSCRIPT_H


#include "util/TStream.h"
#include "util/TBufStream.h"
#include "util/TArray.h"
#include "util/TByte.h"
#include "util/TThingyTable.h"
//#include "pidol/PidolTextScriptOp.h"
#include <map>
#include <string>
#include <vector>

namespace Pce {


class PidolTextScript {
public:
  const static int numOps = 0x20;
  const static int opsEnd = 0x20;
  
  const static int op_fcolor      = 0x00;
  const static int op_scolor      = 0x01;
  const static int op_newline     = 0x02;
  const static int op_clear       = 0x03;
  const static int op_wait        = 0x04;
  const static int op_size1x      = 0x05;
  const static int op_size2x      = 0x06;
  const static int op_size3x      = 0x07;
  const static int op_speed       = 0x08;
  const static int op_br_noxreset = 0x09;
  const static int op_0A          = 0x0A;
  const static int op_0B          = 0x0B;
  const static int op_subimg      = 0x0C;
  const static int op_expression  = 0x0D;
  const static int op_0E          = 0x0E;
  const static int op_0F          = 0x0F;
  const static int op_10          = 0x10;
  const static int op_smallpor    = 0x11;
  const static int op_12          = 0x12;
  const static int op_13          = 0x13;
  const static int op_adpcm       = 0x14;
  const static int op_15          = 0x15;
  const static int op_end16       = 0x16;
  const static int op_17          = 0x17;
  const static int op_insta       = 0x18;
  const static int op_noinsta     = 0x19;
  const static int op_end1A       = 0x1A;
  const static int op_spaces      = 0x1B;
  const static int op_img         = 0x1C;
  const static int op_porfx       = 0x1D;
  const static int op_flapon      = 0x1E;
  const static int op_flapoff     = 0x1F;

  static bool isOp(int opcode);
  static bool isInlineableOp(int opcode);
  static int getOpArgsSize(int opcode);
  static bool isTerminator(int opcode);
  
protected:
  
};


}


#endif
