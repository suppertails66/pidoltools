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

void printRawChars(TStream& ifs, int numChars, std::ostream& ofs) {
  for (int i = 0; i < numChars; i++) {
    int value = ifs.readu8();
    ofs << as2bHexLiteral(value);
  }
}

int main(int argc, char* argv[]) {
  if (argc < 4) {
    cout << "Private Eye Dol: binary -> text converter, via Thingy table" << endl;
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
    TThingyTable::MatchResult result = thingy.matchId(ifs, 2);
    
    if (result.id != -1) {
      ofs << thingy.getEntry(result.id);
    }
    else {
      TThingyTable::MatchResult result = thingy.matchId(ifs, 1);
      
      if (result.id != -1) {
        ofs << thingy.getEntry(result.id);
        
        // control codes
        switch (result.id) {
        case 0x00:
          printRawChars(ifs, 1, ofs);
          break;
        case 0x01:
          printRawChars(ifs, 1, ofs);
          break;
        case 0x08:
          printRawChars(ifs, 1, ofs);
          break;
        case 0x0A:
        case 0x0B:
          printRawChars(ifs, 5, ofs);
          break;
        case 0x0C:
          printRawChars(ifs, 5, ofs);
          break;
        case 0x0D:
          printRawChars(ifs, 1, ofs);
          break;
        case 0x10:
          printRawChars(ifs, 1, ofs);
          break;
        case 0x11:
          printRawChars(ifs, 2, ofs);
          break;
        case 0x14:
          printRawChars(ifs, 8, ofs);
          break;
        case 0x15:
          printRawChars(ifs, 1, ofs);
          break;
        case 0x17:
          printRawChars(ifs, 1, ofs);
          break;
        case 0x1B:
          printRawChars(ifs, 1, ofs);
          break;
        case 0x1C:
          printRawChars(ifs, 9, ofs);
          break;
        case 0x1D:
          printRawChars(ifs, 2, ofs);
          break;
        default:
          break;
        }
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
