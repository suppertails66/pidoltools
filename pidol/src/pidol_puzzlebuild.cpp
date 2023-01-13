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

const static int pieceW = 32;
const static int pieceH = 32;
const static int piecePatternW = pieceW / PcePattern::w;
const static int piecePatternH = pieceH / PcePattern::h;
const static int pieceXSpacing = 24;
const static int pieceYSpacing = 24;

void makePieceGraphic(const TGraphic& baseGrp,
                      const TGraphic& maskGrp,
                      int baseX, int baseY, TColor targetMaskColor,
                      TGraphic& output) {
  output.resize(pieceW, pieceH);
  output.clearTransparent();
  
  for (int j = 0; j < pieceH; j++) {
    for (int i = 0; i < pieceW; i++) {
      int rawX = i;
      int rawY = j;
      int srcX = baseX + i;
      int srcY = baseY + j;
      
//      std::cerr << rawX << " " << rawY << " " << srcX << " " << srcY << std::endl;
      
      TColor maskColor = maskGrp.getPixel(srcX, srcY);
      
      // if mask color matches target color,
      // this pixel is part of the piece interior
      if (maskColor == targetMaskColor) {
        // copy pixel at target position
        output.setPixel(rawX, rawY, baseGrp.getPixel(srcX, srcY));
        
        // check the 8 surrounding pixels in the mask to see if
        // any of them are the outline color.
        // for any which are, copy the pixel at that position.
        
        for (int j = -1; j <= 1; j++) {
          for (int i = -1; i <= 1; i++) {
            // ignore middle pixel
            if ((i == 0) && (j == 0)) continue;
            
            int rawCheckX = rawX + i;
            int rawCheckY = rawY + j;
            
            // ignore pixels outside target area
            if (rawCheckX < 0) continue;
            if (rawCheckX >= pieceW) continue;
            if (rawCheckY < 0) continue;
            if (rawCheckY >= pieceH) continue;
            
            int srcCheckX = srcX + i;
            int srcCheckY = srcY + j;
            
            TColor maskColor = maskGrp.getPixel(srcCheckX, srcCheckY);
            if ((maskColor.r() == 0)
                && (maskColor.g() == 0)
                && (maskColor.b() == 0)) {
              output.setPixel(rawCheckX, rawCheckY,
                  baseGrp.getPixel(srcCheckX, srcCheckY));
            }
          }
        }
        
      }
    }
  }
}

int main(int argc, char* argv[]) {
  if (argc < 5) {
    cout << "Private Eye Dol jigsaw puzzle builder" << endl;
    cout << "Usage: " << argv[0] << " <graphic> <mask> <palline> <outfile>"
      << endl;
    return 0;
  }
  
  string graphicFile = string(argv[1]);
  string maskFile = string(argv[2]);
  string palLineFile = string(argv[3]);
  string outFile = string(argv[4]);
  
  TGraphic baseGrp;
  TPngConversion::RGBAPngToGraphic(graphicFile, baseGrp);
  
  TGraphic maskGrp;
  TPngConversion::RGBAPngToGraphic(maskFile, maskGrp);
  
  PcePaletteLine palLine;
  {
    TBufStream ifs;
    ifs.open(palLineFile.c_str());
    palLine.read(ifs);
  }
  
  TBufStream ofs;
  
  for (int j = 0; j < 5; j++) {
    for (int i = 3; i >= 0; i--) {
      int baseX = i * pieceXSpacing;
      int baseY = j * pieceYSpacing;
      
      int targetMaskMag = ((3 - i) + 1) * 0x44;
      MiscMath::clamp(targetMaskMag, 0, 0xFF);
      
      int targetMaskR = 0;
      int targetMaskG = 0;
      int targetMaskB = 0;
      
      switch (j % 3) {
      case 0:
        targetMaskR = targetMaskMag;
        break;
      case 1:
        targetMaskG = targetMaskMag;
        break;
      case 2:
        targetMaskB = targetMaskMag;
        break;
      default:
        break;
      }
      
      TColor targetMaskColor(targetMaskR, targetMaskG, targetMaskB);
      
      TGraphic output;
      makePieceGraphic(baseGrp, maskGrp, baseX, baseY, targetMaskColor,
                       output);
      
      for (int j = 0; j < piecePatternH; j++) {
        for (int i = 0; i < piecePatternW; i++) {
          int targetX = i * PcePattern::w;
          int targetY = j * PcePattern::h;
          
          PcePattern pattern;
          int result = pattern.fromGraphic(output, targetX, targetY,
                              &palLine, true);
          if (result < 0) {
            std::cerr << "error generating piece at ("
              << baseX
              << ", "
              << baseY
              << ")"
              << endl;
            return 1;
          }
          
          pattern.write(ofs);
        }
      }
      
//      TPngConversion::graphicToRGBAPng("test.png", output);
//      char c;
//      std::cin >> c;
    }
  }
  
  ofs.save(outFile.c_str());
  
  return 0;
}

