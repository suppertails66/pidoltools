#include "util/TBufStream.h"
#include "util/TIfstream.h"
#include "util/TOfstream.h"
#include "util/TStringConversion.h"
#include "util/TFileManip.h"
#include "util/TSort.h"
#include "exception/TException.h"
#include "exception/TGenericException.h"
#include <algorithm>
#include <vector>
#include <string>
#include <map>
#include <iostream>
#include <fstream>
#include <sstream>
#include <iomanip>
#include <cmath>

using namespace std;
using namespace BlackT;

typedef std::map<unsigned long int, std::vector<int> > AddrToOpMap;
AddrToOpMap textscrAddrToOpMap;

string as3bHex(int num) {
  string str = TStringConversion::intToString(num,
                  TStringConversion::baseHex).substr(2, string::npos);
  while (str.size() < 3) str = string("0") + str;
  
//  return "<$" + str + ">";
  return str;
}

string as2bHex(int num) {
  string str = TStringConversion::intToString(num,
                  TStringConversion::baseHex).substr(2, string::npos);
  while (str.size() < 2) str = string("0") + str;
  
//  return "<$" + str + ">";
  return str;
}

string as2bHexPrefix(int num) {
  return "$" + as2bHex(num) + "";
}

string asHex(int num) {
  string str = TStringConversion::intToString(num,
                  TStringConversion::baseHex).substr(2, string::npos);
  return str;
}

const static int sectorSize = 0x800;

void dumpMod(TStream& ifs, int sectorNum, int sectorCount,
             std::string outNameBase) {
  TBufStream ofs;
  ifs.seek(sectorNum * sectorSize);
  ofs.writeFrom(ifs, sectorCount * sectorSize);
  
  std::string outName = outNameBase + "_" + asHex(sectorNum)
    + ".bin";
//  std::cout << outName << std::endl;
  TFileManip::createDirectoryForFile(outName);
  
  ofs.save(outName.c_str());
}

int main(int argc, char* argv[]) {
  if (argc < 3) {
    cout << "Module dumper for Galaxy Fraulein Yuna 2" << endl;
    cout << "Usage: " << argv[0] << " [iso] [outprefix]" << endl;
    
    return 0;
  }
  
  std::string inFile(argv[1]);
  std::string outPrefix(argv[2]);
  
  TIfstream ifs;
  ifs.open(inFile.c_str());
  
  dumpMod(ifs, 0x2, 0xC, outPrefix + "adv");
  dumpMod(ifs, 0x32, 0x5, outPrefix + "scene_main");
  dumpMod(ifs, 0x8A, 0x3, outPrefix + "spaceduck");
  dumpMod(ifs, 0xCA, 0x7, outPrefix + "starbowl");
  dumpMod(ifs, 0x10A, 0xA, outPrefix + "battle");
  dumpMod(ifs, 0x206, (0x1A * 0x34), outPrefix + "battleblock_all");
  dumpMod(ifs, 0x2E7A, (50 * 4), outPrefix + "text_all");
  
  return 0;
}
