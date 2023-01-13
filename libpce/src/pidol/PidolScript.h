#ifndef PIDOLSCRIPT_H
#define PIDOLSCRIPT_H


#include "util/TStream.h"
#include "util/TBufStream.h"
#include "util/TArray.h"
#include "util/TByte.h"
#include "util/TThingyTable.h"
#include "pidol/PidolScriptOp.h"
#include <map>
#include <string>
#include <vector>

namespace Pce {


typedef std::vector<PidolScriptOp> PidolScriptOpCollection;

class PidolScript {
public:
  
  PidolScript();
  
  void read(BlackT::TStream& ifs, int size);
  
  PidolScriptOpCollection ops;
  
protected:
  
};


}


#endif
