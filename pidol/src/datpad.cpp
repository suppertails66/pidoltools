#include "util/TFreeSpace.h"
#include "util/TIniFile.h"
#include "util/TStringConversion.h"
#include "util/TBufStream.h"
#include "util/TIfstream.h"
#include <vector>
#include <sstream>
#include <iostream>

using namespace std;
using namespace BlackT;

int main(int argc, char* argv[]) {
  if (argc < 3) {
    cout << "Data padding utility" << endl;
    cout << "Usage: " << argv[0] << " <infile> <outsize> [outfile]"
      << " [padchar]"
      << endl;
    
    return 0;
  }
  
  std::string inFile(argv[1]);
  int outSize = TStringConversion::stringToInt(argv[2]);
  std::string outFile = inFile;
  if (argc >= 4)
    outFile = std::string(argv[3]);
  unsigned char padChar = 0xFF;
  if (argc >= 5)
    padChar = TStringConversion::stringToInt(argv[4]);
  
  TBufStream ifs;
  ifs.open(inFile.c_str());
  
  ifs.seek(ifs.size());
  while (ifs.size() < outSize) ifs.put(padChar);
  
  ifs.save(outFile.c_str());
  
  return 0;
}

