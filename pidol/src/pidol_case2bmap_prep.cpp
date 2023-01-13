#include "pce/PcePattern.h"
#include "pce/PcePalette.h"
#include "pce/PcePaletteLine.h"
#include "util/TBufStream.h"
#include "util/TIfstream.h"
#include "util/TOfstream.h"
#include "util/TGraphic.h"
#include "util/TArray.h"
#include "util/TStringConversion.h"
#include "util/TPngConversion.h"
#include "util/MiscMath.h"
#include <string>
#include <vector>
#include <map>
#include <iostream>
#include <sstream>
#include <fstream>

using namespace std;
using namespace BlackT;
using namespace Pce;

const static int rowLen = 8;

void copyNameRow(TStream& ifs, TStream& dst, int x, int y) {
  for (int j = 0; j < 2; j++) {
    ifs.seek(((y + j) * 32 * 2) + (x * 2));
    for (int i = 0; i < rowLen; i++) {
      int id = ifs.readu16le();
      
      int palette = ((id & 0xF000) >> 12);
      id &= 0x0FFF;
      
      // force palette to 2 if nonzero
      if (palette != 0) palette = 2;

      id |= (palette << 12);
      
      dst.writeu16le(id);
    }
  }
}

int main(int argc, char* argv[]) {
  if (argc < 3) {
    cout << "Private Eye Dol case 2B map name patch map builder" << endl;
    cout << "Usage: " << argv[0] << " <map_tilemap> <outfile>"
      << endl;
    return 0;
  }
  
  string inFile = string(argv[1]);
  string outFile = string(argv[2]);
  
  TBufStream ifs;
  ifs.open(inFile.c_str());
  
  TBufStream ofs;
  
  // blank
  copyNameRow(ifs, ofs, 1, 1);
  // row 0
  copyNameRow(ifs, ofs, 2, 21);
  copyNameRow(ifs, ofs, 10, 21);
  copyNameRow(ifs, ofs, 18, 21);
  // row 1
  copyNameRow(ifs, ofs, 2, 23);
  copyNameRow(ifs, ofs, 10, 23);
  copyNameRow(ifs, ofs, 18, 23);
  // row 2
  copyNameRow(ifs, ofs, 2, 25);
  copyNameRow(ifs, ofs, 10, 25);
  copyNameRow(ifs, ofs, 18, 25);
  
  ofs.save(outFile.c_str());
  
  return 0;
}

