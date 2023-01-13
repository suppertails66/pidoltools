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
#include "pce/PcePattern.h"
#include "pce/PcePalette.h"
#include "pce/PcePaletteLine.h"
#include <iostream>
#include <string>

using namespace std;
using namespace BlackT;
using namespace Pce;

int patternsPerRow = 16;

int main(int argc, char* argv[]) {
  if (argc < 6) {
    cout << "Private Eye Dol tilemap merger" << endl;
    cout << "Usage: " << argv[0] << " <origmap> <newmap> <emptytileid>"
      << " <map2offset> <outfile>" << endl;
    
    return 0;
  }
  
  std::string map1Name = string(argv[1]);
  std::string map2Name = string(argv[2]);
  int emptyTileId = TStringConversion::stringToInt(string(argv[3]));
  int map2Offset = TStringConversion::stringToInt(string(argv[4]));
  std::string outfileName = string(argv[5]);
  
  TBufStream map1Ifs;
  map1Ifs.open(map1Name.c_str());
  TBufStream map2Ifs;
  map2Ifs.open(map2Name.c_str());
  
  TBufStream ofs;
  
  while (!map1Ifs.eof() && !map2Ifs.eof()) {
    int map1TileRaw = map1Ifs.readu16le();
    int map2TileRaw = map2Ifs.readu16le();
    
    int map2TileNum = map2TileRaw & 0x0FFF;
    
    int outputTile = map1TileRaw;
    if (map2TileNum != emptyTileId) {
      outputTile = (map2TileRaw + map2Offset);
    }
    
    ofs.writeu16le(outputTile);
  }
  
  ofs.save(outfileName.c_str());
  
  return 0;
}
