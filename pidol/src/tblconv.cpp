#include "util/TThingyTable.h"
#include "util/TStringConversion.h"
#include "util/TIfstream.h"
#include "util/TOfstream.h"
#include "util/TBufStream.h"
#include "exception/TGenericException.h"
#include <string>
#include <fstream>
#include <iostream>

using namespace std;
using namespace BlackT;
//using namespace Md;

std::string as2bHex(int num) {
  std::string str = TStringConversion::intToString(num,
    TStringConversion::baseHex).substr(2, string::npos);
  while (str.size() < 2) str = string("0") + str;
  return str;
}

std::string as2bHexLiteral(int num) {
  std::string str = TStringConversion::intToString(num,
    TStringConversion::baseHex).substr(2, string::npos);
  return std::string("<$") + as2bHex(num) + ">";
}

int main(int argc, char* argv[]) {
  if (argc < 4) {
    cout << "Binary -> text converter, via Thingy table" << endl;
    cout << "Usage: " << argv[0] << " <thingy> <infile> <outfile>" << endl;
    cout << "The Thingy table must be in SJIS (or compatible) format."
      << endl;
    
    return 0;
  }
  
  TThingyTable thingy;
  thingy.readSjis(string(argv[1]));
//  std::ifstream ifs(argv[2], ios_base::binary);

//  TIfstream ifs(argv[2], ios_base::binary);

  TBufStream ifs(1);
  ifs.open(argv[2]);
  ifs.seek(0);

  std::ofstream ofs(argv[3], ios_base::binary);
  
  while (!ifs.eof()) {
//    int next = (unsigned char)ifs.get();
    TThingyTable::MatchResult result = thingy.matchId(ifs, 1);
    
    if (result.id != -1) {
      ofs << thingy.getEntry(result.id);
      
      // control codes
//      if 
    }
    else {
      TThingyTable::MatchResult result = thingy.matchId(ifs, 2);
      
      if (result.id != -1) {
        ofs << thingy.getEntry(result.id);
      }
      else {
        ofs << "?";
        ifs.get();
//        ofs << "?";
//        ifs.get();
      }
    }
    
//    std::cerr << std::hex << ifs.tell() << std::endl;
    
    if ((ifs.tell() % 0x40) == 0) {
      ofs << std::endl;
      ofs << "// $" << std::hex << ifs.tell() << std::endl;
    }
  }
  
/*  for (int i = 0; i < 521; i++) {
    string left
      = TStringConversion::intToString(i, TStringConversion::baseHex);
    left = left.substr(2, string::npos);
    cout << left << "=？" << std::endl;
  } */
  
  return 0; 
}
