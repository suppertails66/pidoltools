#ifndef YUNA2SCRIPT_H
#define YUNA2SCRIPT_H


#include "util/TStream.h"
#include "util/TBufStream.h"
#include "util/TArray.h"
#include "util/TByte.h"
#include "util/TThingyTable.h"
#include "yuna2/Yuna2ScriptOp.h"
#include <map>
#include <string>
#include <vector>

namespace Pce {


typedef std::vector<Yuna2ScriptOp> Yuna2ScriptOpCollection;

class Yuna2Script {
public:
  
  Yuna2Script();
  
  void read(BlackT::TStream& ifs, int size);
  
  Yuna2ScriptOpCollection ops;
  
protected:
  
};


}


#endif
