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
#include "util/TBitmapFont.h"
#include "util/TThingyTable.h"
#include <iostream>
#include <string>
#include <vector>

using namespace std;
using namespace BlackT;
//using namespace Md;

//const static int outputW = 256;
//const static int outputH = 32;
//const static int lineHeight = 16;
//const static int lineYOffset = 3;
const static int defaultOutputW = 256;
const static int defaultOutputH = 224;
const static int lineHeight = 8;
const static int lineYOffset = 0;

void doPixelOutline(TGraphic& grp, int x, int y) {
  if (x < 0) return;
  if (x >= grp.w()) return;
  if (y < 0) return;
  if (y >= grp.h()) return;
  
  if (grp.getPixel(x, y).a() == TColor::fullAlphaTransparency) {
    grp.setPixel(x, y, TColor(0, 0, 0, TColor::fullAlphaOpacity));
  }
}

int main(int argc, char* argv[]) {
  if (argc < 6) {
    cout << "Complex string renderer" << endl;
    cout << "Usage: " << argv[0]
      << " <fontprefix> <fonttable> <srcfile> <srctable> <outfile>"
      << endl
      << "Options:" << endl
      << "  -w           Set output width" << endl
      << "  -h           Set output height" << endl
      << "  --fgcolor    Set font color R/G/B" << endl
      << "  --bgcolor    Set background color R/G/B" << endl
      << endl;
    
    return 0;
  }
  
  char* fontPrefix = argv[1];
  char* fonttableFile = argv[2];
  char* srcfile = argv[3];
  char* srctableFile = argv[4];
  char* outfile = argv[5];
  
  TColor textShiftColor(0, 0, 0, TColor::fullAlphaOpacity);
  TColor backgroundColor(0, 0, 0, TColor::fullAlphaTransparency);
  bool textColorShift = false;
  
  int target;
  
  if ((target = TOpt::findOpt(argc, argv, "--fgcolor")) > 0) {
    textColorShift = true;
    textShiftColor.setR(TStringConversion::stringToInt(std::string(argv[target + 1])));
    textShiftColor.setG(TStringConversion::stringToInt(std::string(argv[target + 2])));
    textShiftColor.setB(TStringConversion::stringToInt(std::string(argv[target + 3])));
  }
  
  if ((target = TOpt::findOpt(argc, argv, "--bgcolor")) > 0) {
    backgroundColor.setR(TStringConversion::stringToInt(std::string(argv[target + 1])));
    backgroundColor.setG(TStringConversion::stringToInt(std::string(argv[target + 2])));
    backgroundColor.setB(TStringConversion::stringToInt(std::string(argv[target + 3])));
    backgroundColor.setA(TColor::fullAlphaOpacity);
  }
  
  int outputW = defaultOutputW;
  int outputH = defaultOutputH;
  TOpt::readNumericOpt(argc, argv, "-w", &outputW);
  TOpt::readNumericOpt(argc, argv, "-h", &outputH);
  
/*  if (argc > 6) {
    textColorShift = true;
    textShiftColor.setR(TStringConversion::stringToInt(std::string(argv[6])));
    textShiftColor.setG(TStringConversion::stringToInt(std::string(argv[7])));
    textShiftColor.setB(TStringConversion::stringToInt(std::string(argv[8])));
    
    if (argc > 9) {
      backgroundColor.setR(TStringConversion::stringToInt(std::string(argv[9])));
      backgroundColor.setG(TStringConversion::stringToInt(std::string(argv[10])));
      backgroundColor.setB(TStringConversion::stringToInt(std::string(argv[11])));
      backgroundColor.setA(TColor::fullAlphaOpacity);
    }
    
    if (argc > 12) {
      outputW = TStringConversion::stringToInt(std::string(argv[12]));
    }
    
    if (argc > 13) {
      outputH = TStringConversion::stringToInt(std::string(argv[13]));
    }
  }*/
  
  TBitmapFont font;
  font.load(std::string(fontPrefix));
  
  TThingyTable fonttable;
  fonttable.readSjis(fonttableFile);
  
  TThingyTable srctable;
  srctable.readSjis(srctableFile);
  
  std::vector<std::string> lines;
  {
    TBufStream ifs;
    ifs.open(srcfile);
    
    std::string currentLine;
    while (!ifs.eof()) {
      TThingyTable::MatchResult result = srctable.matchId(ifs);
      if (result.id == -1) {
        std::cerr << "unknown character at " << ifs.tell() << std::endl;
        return 1;
      }
      
      std::string entry = srctable.getEntry(result.id);
      if (entry.compare("\\n") == 0) {
        lines.push_back(currentLine);
        currentLine = "";
      }
      else if ((entry.compare("[end16]") == 0)
               || (entry.compare("[end1A]") == 0)) {
        break;
      }
      else {
        currentLine += entry;
      }
    }
    
    lines.push_back(currentLine);
  }
  
  std::vector<TGraphic> lineGrps;
  for (unsigned int i = 0; i < lines.size(); i++) {
    TBufStream ifs;
    ifs.writeString(lines[i]);
    ifs.seek(0);
    
    TGraphic grp;
    font.render(grp, ifs, fonttable);
    lineGrps.push_back(grp);
//    TPngConversion::graphicToRGBAPng(std::string(outfile), grp);
  }
  
  TGraphic output(outputW, outputH);
  output.clearTransparent();
  
  // center horizontally
//  int hOffset = (outputH - (lineGrps.size() * lineHeight)) / 2;
  int hOffset = 0;
  for (unsigned int i = 0; i < lineGrps.size(); i++) {
    TGraphic& src = lineGrps[i];
    output.blit(src,
//                TRect(((outputW - src.w()) / 2),
                TRect(0,
                      (i * lineHeight) + lineYOffset + hOffset,
                      0, 0),
                TRect(0, 0, 0, 0));
  }
  
  // outline
/*  for (int j = 0; j < output.h(); j++) {
    for (int i = 0; i < output.w(); i++) {
      TColor pixel = output.getPixel(i, j);
//      if ((!pixel.a() == TColor::fullAlphaTransparency)
//          && (pixel == TColor(255, 255, 255))) {
      if (pixel == TColor(255, 255, 255, TColor::fullAlphaOpacity)) {
        doPixelOutline(output, i - 1, j - 1);
        doPixelOutline(output, i - 0, j - 1);
        doPixelOutline(output, i + 1, j - 1);
        
        doPixelOutline(output, i - 1, j - 0);
//        doPixelOutline(output, i - 0, j - 0);
        doPixelOutline(output, i + 1, j - 0);
        
        doPixelOutline(output, i - 1, j + 1);
        doPixelOutline(output, i - 0, j + 1);
        doPixelOutline(output, i + 1, j + 1);
      }
    }
  }*/
  
  for (int j = 0; j < output.h(); j++) {
    for (int i = 0; i < output.w(); i++) {
      TColor pixel = output.getPixel(i, j);
      if (pixel.a() == TColor::fullAlphaOpacity) {
        if (textColorShift) {
          output.setPixel(i, j, textShiftColor);
        }
      }
      else {
        output.setPixel(i, j, backgroundColor);
      }
    }
  }
  
  TPngConversion::graphicToRGBAPng(std::string(outfile), output);
  
  return 0;
}
