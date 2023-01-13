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

//const static int patternsPerRow = 16;

int main(int argc, char* argv[]) {
  if (argc < 6) {
    cout << "PC Engine-format sprite builder" << endl;
    cout << "Usage: " << argv[0] << " <inpng> <inscript> <inpal> <outgrp> <outspr> [options]" << endl;
    
/*    cout << "Options: " << endl;
    cout << "  -basepattern   " << "Sets base pattern number" << endl;
    cout << "  -xoffset       " << "X-offset applies to output" << endl;
    cout << "  -yoffset       " << "Y-offset applies to output" << endl;*/
    
    return 0;
  }
  
  string inPng = string(argv[1]);
  string inScript = string(argv[2]);
  string inPal = string(argv[3]);
  string outGrp = string(argv[4]);
  string outSpr = string(argv[5]);
  
  int basePattern = 0;
//  TOpt::readNumericOpt(argc, argv, "-basepattern", &basePattern);
  
  int xOffset = 0;
//  TOpt::readNumericOpt(argc, argv, "-xoffset", &xOffset);
  
  int yOffset = 0;
//  TOpt::readNumericOpt(argc, argv, "-yoffset", &yOffset);

  int padSize = 0;
  
  TGraphic grp;
  TPngConversion::RGBAPngToGraphic(inPng, grp);
  
  PcePalette palette;
  {
    TBufStream ifs;
    ifs.open(inPal.c_str());
    palette.read(ifs);
  }
  
  TBufStream scriptIfs;
  scriptIfs.open(inScript.c_str());
  
  TBufStream grpOfs;
  TBufStream sprOfs;
  
  vector<PceSpriteId> sprites;
  
  //=============================
  // parse script
  //=============================
  
  int lineNum = 0;
  while (!scriptIfs.eof()) {
    std::string line;
    scriptIfs.getLine(line);
    ++lineNum;
    
    if (line.size() <= 0) continue;
    
    TBufStream ifs;
    ifs.writeString(line);
    ifs.seek(0);
    
    TParse::skipSpace(ifs);
    if (ifs.eof()) continue;
    if (ifs.peek() == '#') continue;
    
    std::string cmd = TParse::getSpacedSymbol(ifs);
    if (cmd.compare("add") == 0) {
      PceSpriteId sprite;
    
      TParse::skipSpace(ifs);
      while (!ifs.eof()) {
        TParse::skipSpace(ifs);
        
        std::string subCmd = TParse::getUntilChars(ifs, "=");
//        TParse::matchChar(ifs, '=');
        int param = TParse::matchInt(ifs);
        
        if (subCmd.compare("x") == 0) sprite.x = param;
        else if (subCmd.compare("y") == 0) sprite.y = param;
        else if (subCmd.compare("w") == 0)
          sprite.width = (param / PceSpritePattern::w) - 1;
        else if (subCmd.compare("h") == 0)
          sprite.height = (param / PceSpritePattern::h) - 1;
        else if (subCmd.compare("pal") == 0) sprite.palette = param;
        else if (subCmd.compare("pri") == 0) sprite.priority = (param != 0);
        else {
          std::cerr << "Line " << lineNum << ": unknown add subcommand '"
            << subCmd << "'" << std::endl;
          return 1;
        }
      }
      
      sprites.push_back(sprite);
    }
    else if (cmd.compare("set") == 0) {
      TParse::skipSpace(ifs);
      while (!ifs.eof()) {
        TParse::skipSpace(ifs);
        
        std::string subCmd = TParse::getUntilChars(ifs, "=");
        int param = TParse::matchInt(ifs);
        
        if (subCmd.compare("basepattern") == 0) basePattern = param;
        else if (subCmd.compare("xoffset") == 0) xOffset = param;
        else if (subCmd.compare("yoffset") == 0) yOffset = param;
        else if (subCmd.compare("padsize") == 0) padSize = param;
        else {
          std::cerr << "Line " << lineNum << ": unknown set subcommand '"
            << subCmd << "'" << std::endl;
          return 1;
        }
      }
    }
    else {
      std::cerr << "Line " << lineNum << ": unknown command '"
        << cmd << "'" << std::endl;
      return 1;
    }
  }
  
  //=============================
  // read sprites
  //=============================
  
  // HACK: write sprite count to start of list
  sprOfs.writeu8(sprites.size());
  
  int currentPatternNum = 0;
  for (vector<PceSpriteId>::iterator it = sprites.begin();
       it != sprites.end();
       ++it) {
    int x = it->x;
    int y = it->y;
    int w = it->width + 1;
    int h = it->height + 1;
    int palIndex = it->palette;
    
    // adjust output pattern according to base
    it->pattern = basePattern + currentPatternNum;
    
    for (int j = 0; j < h; j++) {
      for (int i = 0; i < w; i++) {
        int realX = x + (i * PceSpritePattern::w);
        int realY = y + (j * PceSpritePattern::h);
        
        PceSpritePattern spritePattern;
        int result = spritePattern.fromGraphic(grp, realX, realY,
                                    &palette.paletteLines[palIndex]);
        if (result != 0) {
          cerr << "Error processing subsprite at ("
            << x << ", " << y << "): cannot convert using palette line"
            << palIndex << endl;
          return 1;
        }
        
        spritePattern.write(grpOfs);
        ++currentPatternNum;
      }
    }
    
    // adjust output position according to offset
    it->x = x + xOffset;
    it->y = y + yOffset;
    
    it->write(sprOfs);
    
    // HACK: ???
    sprOfs.seekoff(-4);
    int raw = sprOfs.readu16le();
//    raw |= 0x0200;
//    raw = ((raw >> 1) + 0x0100) << 1;
    raw += 0x200;
    sprOfs.seekoff(-2);
    sprOfs.writeu16le(raw);
    sprOfs.seekoff(2);
  }
  
  // pad to specified output size
  if (sprites.size() < padSize) {
    int remaining = padSize - sprites.size();
    for (int i = 0; i < remaining; i++) {
      for (int j = 0; j < PceSpriteId::size; j++) {
        sprOfs.put(0x00);
      }
    }
  }
  
  //=============================
  // save output
  //=============================
  
  grpOfs.save(outGrp.c_str());
  sprOfs.save(outSpr.c_str());
  
  return 0;
}
