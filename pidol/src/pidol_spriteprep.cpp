#include "util/TIfstream.h"
#include "util/TOfstream.h"
#include "util/TBufStream.h"
#include "util/TFileManip.h"
#include "util/TStringConversion.h"
#include "util/TGraphic.h"
#include "util/TPngConversion.h"
#include "util/TOpt.h"
#include "util/TArray.h"
#include "util/TByte.h"
#include "util/TFileManip.h"
#include "util/TParse.h"
#include "pce/PceSpritePattern.h"
#include "pce/PceSpriteId.h"
#include "pce/PcePalette.h"
#include "pce/PcePaletteLine.h"
#include <iostream>
#include <string>
#include <vector>

using namespace std;
using namespace BlackT;
using namespace Pce;

int main(int argc, char* argv[]) {
  if (argc < 2) {
    cout << "Private Eye Dol sprite prep tool" << endl;
    cout << "Usage: " << argv[0] << " <infile> [outfile]" << endl;
    cout << "If omitted, outfile is same as infile." << endl;
    
/*    cout << "Options: " << endl;
    cout << "  -basepattern   " << "Sets base pattern number" << endl;
    cout << "  -xoffset       " << "X-offset applies to output" << endl;
    cout << "  -yoffset       " << "Y-offset applies to output" << endl;*/
    
    return 0;
  }
  
  string inFile = string(argv[1]);
  
  string outFile = inFile;
  if (argc >= 3)
    outFile = string(argv[2]);
  
  TBufStream ifs;
  ifs.open(inFile.c_str());
  
  TBufStream ofs;
  
  int numSprites = ifs.size() / PceSpriteId::size;
  for (int i = 0; i < numSprites; i++) {
 //   PceSpriteId sprite;
//    sprite.read(ifs);
    int y = ifs.reads16le();
    int x = ifs.reads16le();
    int pattern = ifs.readu16le();
    int rawFlags = ifs.readu16le();
    
    if ((x >= 128) || (x < -128)) {
      std::cerr << "Error: out-of-range x-offset" << endl;
      return 1;
    }
    
    // note that y cannot be -128/0x80, even though this is within
    // the signed 8-bit range, because a 0x80 in the y position
    // is used to mark the end of the sprite struct list
    if ((y >= 128) || (y <= -128)) {
      std::cerr << "Error: out-of-range y-offset" << endl;
      return 1;
    }
    
    ofs.writes8(y);
    ofs.writes8(x);
    ofs.writeu16le(pattern);
    ofs.writeu16le(rawFlags);
  }
  
  // add terminator
  ofs.writeu8(0x80);
  
  ofs.save(outFile.c_str());
  
  return 0;
}
