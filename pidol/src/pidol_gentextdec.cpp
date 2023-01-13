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
#include <cctype>
#include <string>
#include <vector>
#include <map>
#include <iostream>
#include <sstream>
#include <fstream>

//const static int textCharsStart = 0x10;

const static int fontPatternW = 16;
const static int fontPatternH = 16;
const static int numFontChars = 3584;
const static int numUpperCodepoints = 0x27;
const static int indexBase = 0x21;

using namespace std;
using namespace BlackT;
using namespace Pce;

typedef std::map<int, TGraphic> FontMap;

struct FontCodeSeg {
  int baseId;
  int size;
};

typedef std::map<int, FontCodeSeg> FontSegMap;

std::string as2bHex(int num) {
  std::string str = TStringConversion::intToString(num,
    TStringConversion::baseHex).substr(2, string::npos);
  while (str.size() < 2) str = string("0") + str;
  return str;
}

std::string as4bHex(int num) {
  std::string str = TStringConversion::intToString(num,
    TStringConversion::baseHex).substr(2, string::npos);
  while (str.size() < 4) str = string("0") + str;
  return str;
}

void outputCompressionSeg(int baseIn, int baseOut, int size,
                    std::ostream& ofs,
                    int extraOffset = 0) {
  int crossAdjustment = 0;
  for (int i = 0; i < size; i++) {
    int left = baseIn + i + extraOffset;
    int right = baseOut + i;
    
    // HACK
    if ((right & 0xFF) == 0x7F) {
      --crossAdjustment;
      // ?
      ++size;
      continue;
    }
    
//    if (left == 0xF8) {
//      cout << hex << left << " " << right << endl;
//    }
    
    left += crossAdjustment;
    
    ofs << as2bHex(left);
    ofs << "=";
    ofs << (char)((right & 0xFF00) >> 8);
    ofs << (char)((right & 0x00FF));
    ofs << std::endl;
  }
}

void outputTableSeg(int baseIn, int baseOut, int size,
                    std::ostream& ofs,
                    int extraOffset = 0) {
  int crossAdjustment = 0;
  for (int i = 0; i < size; i++) {
    int left = ((indexBase + baseIn) << 8) + indexBase + i + extraOffset;
    int right = baseOut + i;
    
    // HACK
    if ((right & 0xFF) == 0x7F) {
      --crossAdjustment;
      continue;
    }
    
    left += crossAdjustment;
    
    ofs << as4bHex(left);
    ofs << "=";
    ofs << (char)((right & 0xFF00) >> 8);
    ofs << (char)((right & 0x00FF));
    ofs << std::endl;
  }
}

int main(int argc, char* argv[]) {
  if (argc < 2) {
    cout << "Private Eye Dol text decoding generator" << endl;
    cout << "Usage: " << argv[0] << " <outprefix>" << endl;
    return 0;
  }
  
  string outPrefix = string(argv[1]);
  
/*  FontMap fontMap;
  {
    TBufStream ifs;
    ifs.open("syscard3.pce");
    ifs.seek(0x10000);
  
    for (int i = 0; i < numFontChars; i++) {
      TGraphic grp(fontPatternW, fontPatternH);
      grp.clearTransparent();
      for (int j = 0; j < 16; j++) {
        int row = ifs.readu16be();
        for (int k = 0; k < 16; k++) {
          if ((row & 0x8000) != 0) {
            grp.setPixel(k, j, TColor(255, 255, 255));
          }
          row <<= 1;
        }
      }
      
      grp.regenerateTransparencyModel();
      fontMap[i] = grp;
    }
  }
  
  FontSegMap fontSegMap;
  int longestSeg = 0;
  {
    TBufStream ifs;
    ifs.open("base/kernel.bin");
    ifs.seek(0x7A1B - 0x4000);
    
    for (int i = 0; i < numUpperCodepoints; i++) {
      int current = ifs.readu16le();
      int next = ifs.readu16le();
      ifs.seekoff(-2);
      
//      if (i == (numUpperCodepoints - 1)) next = numFontChars;
      if (i == (numUpperCodepoints - 1)) next = current + 64;
      
      int size = (next - current);
      
      FontCodeSeg seg;
      seg.baseId = current;
      seg.size = size;
      fontSegMap[i] = seg;
      
      if (size > longestSeg) longestSeg = size;
    }
  }
  
  TGraphic previewGrp(longestSeg * fontPatternW,
                      fontSegMap.size() * fontPatternH);
//  previewGrp.clearTransparent();
  previewGrp.clear(TColor(0, 0, 0));
  for (FontSegMap::iterator it = fontSegMap.begin();
       it != fontSegMap.end();
       ++it) {
    int index = it->first;
    int size = it->second.size;
    int base = it->second.baseId;
    int y = (index * fontPatternH);
    
    for (int i = 0; i < size; i++) {
      int code = base + i;
      int x = (i * fontPatternW);
      previewGrp.blit(fontMap.at(code),
                      TRect(x, y, 0, 0));
    }
  }
  
  TPngConversion::graphicToRGBAPng((outPrefix + "test.png").c_str(),
    previewGrp);*/
  
  {
    std::ofstream ofs((outPrefix + "pidol_raw.tbl").c_str());
    
    // control codes
    // set font foreground color
    ofs << "00=\\c" << endl;
    // NOTE: changes font shadow color; never used?
    ofs << "01=[scolor]" << endl;
    // newline
    ofs << "02=\\n" << endl;
    ofs << "03=[clear]" << endl;
    ofs << "04=[wait]" << endl;
    ofs << "05=[1x]" << endl;
    ofs << "06=[2x]" << endl;
    ofs << "07=[3x]" << endl;
    // set printing speed
    ofs << "08=\\s" << endl;
    ofs << "09=[br_noxreset]" << endl;
    ofs << "0A=[op0A]" << endl;
    ofs << "0B=[op0B]" << endl;
    ofs << "0C=[subimg]" << endl;
    ofs << "0D=[expr]" << endl;
    ofs << "0E=[targetbox0]" << endl;
    ofs << "0F=[targetbox1]" << endl;
    ofs << "10=[op10]" << endl;
    ofs << "11=[smallpor]" << endl;
    ofs << "12=[op12]" << endl;
    ofs << "13=[op13]" << endl;
    ofs << "14=[adpcm]" << endl;
    ofs << "15=[op15]" << endl;
    ofs << "16=[end16]" << endl;
    ofs << "17=[check3B84?]" << endl;
    ofs << "18=[insta]" << endl;
    ofs << "19=[noinsta]" << endl;
    ofs << "1A=[end1A]" << endl;
    ofs << "1B=[spaces]" << endl;
    ofs << "1C=[img]" << endl;
    ofs << "1D=[porfx]" << endl;
    ofs << "1E=[flapon]" << endl;
    ofs << "1F=[flapoff]" << endl;
    
    // 8-bit compression codepoints
    //; - 0x26-0x2F -> 0x2330 = digits
    outputCompressionSeg(0x26, 0x824F, 0x30 - 0x26, ofs);
    //; - 0x50-0xA2 -> 0x2421 = hiragana
    outputCompressionSeg(0x50, 0x829F, 0xA3 - 0x50, ofs);
    //; - 0xA3-0xF8 -> 0x2521 = katakana
    outputCompressionSeg(0xA3, 0x8340, 0xF9 - 0xA3, ofs);
    //; - 0xF9-0xFA -> 0x2122 = "、"/"。"
    outputCompressionSeg(0xF9, 0x8141, 2, ofs);
    //; - 0xFB-0xFC -> 0x2129 = "？"/"！"
    outputCompressionSeg(0xFB, 0x8148, 2, ofs);
    //; - 0xFD -> 0x2145 = "‥"
    outputCompressionSeg(0xFD, 0x8164, 1, ofs);
    //; - 0xFE -> 0x214A = "（"
    outputCompressionSeg(0xFE, 0x8169, 1, ofs);
    //; - 0xFF -> 0x2156 = "「"
    outputCompressionSeg(0xFF, 0x8175, 1, ofs);
    
    // row 0 / index 0x21: random stuff
    outputTableSeg(0x0, 0x8140, 0x5F, ofs);
    // row 1 / index 0x22: more random stuff
    outputTableSeg(0x1, 0x819F, 0xE, ofs);
    // row 2 / index 0x23: digits + english alphabet,
    // mapped following SJIS conventions rather than consecutively
    outputTableSeg(0x2, 0x824F, 10, ofs,
                   0xF);
    outputTableSeg(0x2, 0x8260, 26, ofs,
                   0x20);
    outputTableSeg(0x2, 0x8281, 26, ofs,
                   0x40);
    // row 3 / index 0x24: hiragana
    outputTableSeg(0x3, 0x829F, 0x53, ofs);
    // row 4 / index 0x25: katakana
    outputTableSeg(0x4, 0x8340, 0x57, ofs);
    // row 5 / index 0x26: greek
    // (despite going to the trouble of mapping it,
    // the game cannot actually use this range, as indices 0x26-0x2F
    // are part of the compression and get remapped to the
    // digit range instead)
/*    outputTableSeg(0x5, 0x839F, 0x18, ofs);
    outputTableSeg(0x5, 0x83BF, 0x18, ofs,
                   0x20);
    // row 6 / index 0x27: cyrillic
    // (as above, not usable)
    outputTableSeg(0x6, 0x8440, 0x21, ofs);
    outputTableSeg(0x6, 0x8470, 0x22, ofs,
                   0x30);*/
    
    // indices 0x29-0x2F are remapped to 0x21-0x27 in code,
    // but lack the special hardcoded SJIS remapping
    // applied to e.g. the alphanumeric characters.
    // however, they're covered by the compression range as
    // explained above, so they're unusable anyway.
    
    // indices 0x30-0x4F: kanji
//    outputTableSeg(0xF, 0x889F, 0x5E, ofs);
//    outputTableSeg(0x10, 0x8940, 0x5E, ofs);
//    outputTableSeg(0x11, 0x899F, 0x5E, ofs);
//    outputTableSeg(0x12, 0x8A40, 0x5E, ofs);
    for (int i = 0; i < 32; i += 2) {
      int size1 = 0x5E;
      outputTableSeg(0xF + i, 0x889F + ((i / 2) * 0x100), size1, ofs);
      
//      int size2 = (i == 30) ? 0x32 : 0x5F;
      int size2 = (i == 30) ? 0x33 : 0x5F;
      outputTableSeg(0x10 + i, 0x8940 + ((i / 2) * 0x100), size2, ofs);
    }
    
    // index 0x76: special characters
    ofs << "7621=[heart]" << endl;
    ofs << "7622=!!" << endl;
    ofs << "7623=?!" << endl;
    ofs << "7624=[I]" << endl;
    ofs << "7625=[II]" << endl;
  }
  
  return 0;
}

