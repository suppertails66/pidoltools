#include "pidol/PidolLineWrapper.h"
#include "pidol/PidolTextScript.h"
#include "util/TParse.h"
#include "util/TStringConversion.h"
#include "exception/TGenericException.h"
#include <iostream>

using namespace BlackT;

namespace Pce {

//const static int controlOpsStart = 0x40;

const static int code_br       = 0x02;
const static int code_clear    = 0x03;
const static int code_end16    = 0x16;
const static int code_end1A    = 0x1A;
const static int code_period   = 0x5F;
const static int code_exclaim  = 0x61;
const static int code_question = 0x62;
const static int code_rquotesing = 0x63;
const static int code_rquote   = 0x69;
const static int code_hyphen   = 0x6A;
const static int code_ellipsis = 0x6B;
const static int code_dash     = 0x6D;

const static int code_emphModeToggle = 0x7F;
//const static int code_space   = 0x20;
//const static int code_battleBreak = 0x02;
//const static int code_wait    = 0x02;
//const static int code_lulu    = 0x03;
//const static int code_hyphen  = 0x5A;
/*const static int code_wait    = 0x05;
const static int code_clear_and_close = 0x06;
const static int code_clear   = 0x07;
const static int code_clear_goto_line2 = 0x08;
const static int code_wait_for_voice = 0x2D; */
// conditionally print an "s" if quantity requires plural
//const static int code_plural    = 0x09;

PidolLineWrapper::PidolLineWrapper(BlackT::TStream& src__,
                ResultCollection& dst__,
                const BlackT::TThingyTable& thingy__,
                CharSizeTable sizeTable__,
                CharSizeTable sizeTableEmph__,
                bool isNonstd__,
                int xSize__,
                int ySize__,
                int controlOpsEnd__)
  : TLineWrapper(src__, dst__, thingy__, xSize__, ySize__),
    controlOpsEnd(default_controlOpsEnd),
    sizeTable(sizeTable__),
    sizeTableEmph(sizeTableEmph__),
    isNonstd(isNonstd__),
    xBeforeWait(-1),
//    clearMode(clearMode_default),
    breakMode(breakMode_single),
    failOnBoxOverflow(false),
    doubleWidthModeOn(false),
    doubleWidthCharsInWord(false),
    padAndCenter_on(false),
    padAndCenter_leftPad(0),
    padAndCenter_width(0),
    longestLineLen(0),
    emphModeOn(false) {
  
}

int PidolLineWrapper::getLocalBrId() const {
  // HACK
  // (br char differs between regular and cutscene fonts)
  return thingy.matchTableEntry("\\n").id;
}

int PidolLineWrapper::getLocalSpaceId() const {
  // HACK
  return thingy.matchTableEntry(" ").id;
}

/*int PidolLineWrapper::getLocalEspId() const {
  // HACK
  return thingy.matchTableEntry("[esp]").id;
}*/

int PidolLineWrapper::widthOfKey(int key) {
  if ((key == getLocalBrId())) return 0;
  else if ((key < controlOpsEnd)) return 0;
  
  if (key == code_emphModeToggle) return 0;
  
//  std::cerr << std::hex << key << " " << std::dec << sizeTable[key] << " " << currentWordWidth << " " << xPos << std::endl;
//  char c;
//  std::cin >> c;
  
  int result = sizeTable[key];
  
  // HACK: assume emph mode table follows non-emph mode table
  // unless a space
  if (emphModeOn
      && (key != getLocalSpaceId()))
    result = sizeTableEmph[key];
  
  if (doubleWidthModeOn) result *= 2;
  return result;
}

int PidolLineWrapper::advanceWidthOfKey(int key) {
  return widthOfKey(key);
}

bool PidolLineWrapper::isWordDivider(int key) {
  if ((key == getLocalBrId())
      || (key == getLocalSpaceId()
      // TRANSLATION ONLY
      || (key == PidolTextScript::op_13)
      )
     ) return true;
  
  return false;
}

bool PidolLineWrapper::isVisibleWordDivider(int key, int nextKey) {
  if (isNonstd) return false;
  
  if ((key == code_hyphen)
      || (key == code_ellipsis)
      || (key == code_dash)) {
    // if followed by punctuation, do not treat as divider
    if ((nextKey == code_exclaim)
        || (nextKey == code_question)
        || (nextKey == code_rquote)
        || (nextKey == code_rquotesing)) {
      return false;
    }
    
    return true;
  }
  
  return false;
}

bool PidolLineWrapper::isLinebreak(int key) {
  if ((key == getLocalBrId())
      // TRANSLATION ONLY
      || (key == PidolTextScript::op_13)
      ) return true;
  
  return false;
}

bool PidolLineWrapper::isBoxClear(int key) {
  if (
//      (key == code_end16)
//      || (key == code_end1A)
//      || 
      (key == code_clear)
    ) return true;
  
  return false;
}

void PidolLineWrapper::onBoxFull() {
  // TODO: pretty sure the game has autoscrolling
  // (which isn't normally used)
/*  std::string content;
  if (lineHasContent) {
    // wait
    content += thingy.getEntry(code_wait);
    // full box + linebreak = automatic box wait + clear
//    content += thingy.getEntry(getLocalBrId());
    
//    content += thingy.getEntry(code_br);
//    content += linebreakString();

//    content += thingy.getEntry(code_clear);
    
    currentScriptBuffer.write(content.c_str(), content.size());
  }
  // linebreak
  stripCurrentPreDividers(); */
  
  std::string content;
  if (lineHasContent) {
    // TODO?
    // wait
//    content += thingy.getEntry(code_wait);
    // full box + linebreak = automatic box wait + clear
    content += thingy.getEntry(getLocalBrId());
    
//    content += thingy.getEntry(code_br);
//    content += linebreakString();

//    content += thingy.getEntry(code_clear);
    
    currentScriptBuffer.write(content.c_str(), content.size());
  }
  // linebreak
  stripCurrentPreDividers();
  
  currentScriptBuffer.put('\n');
  currentScriptBuffer.put('\n');
  xPos = 0;
  yPos = -1;
}

//int PidolLineWrapper::linebreakKey() {
//  return code_br;
//}

std::string PidolLineWrapper::linebreakString() const {
  std::string breakString = thingy.getEntry(getLocalBrId());
  if (breakMode == breakMode_single) {
    return breakString;
  }
  else {
    return breakString + breakString;
  }
}

//int PidolLineWrapper::linebreakHeight() const {
//  if (breakMode == breakMode_single) {
//    return 1;
//  }
//  else {
//    return 2;
//  }
//}

void PidolLineWrapper::onSymbolAdded(BlackT::TStream& ifs, int key) {
/*  if (isLinebreak(key)) {
    if ((yPos != -1) && (yPos >= ySize - 1)) {
      flushActiveWord();
      
    }
  } */
  
  if (key == PidolTextScript::op_size1x) {
    doubleWidthModeOn = false;
  }
  else if ((key == PidolTextScript::op_size2x)
          || (key == PidolTextScript::op_size3x)) {
    doubleWidthModeOn = true;
  }
  else if (!PidolTextScript::isOp(key)) {
    if (doubleWidthModeOn) doubleWidthCharsInWord = true;
  }
  else if (key == code_emphModeToggle) {
    emphModeOn = !emphModeOn;
  }
}

void PidolLineWrapper
    ::handleManualLinebreak(TLineWrapper::Symbol result, int key) {
  if ((key != getLocalBrId()) || (breakMode == breakMode_single)) {
    TLineWrapper::handleManualLinebreak(result, key);
  }
  else {
    outputLinebreak(linebreakString());
  }
}

void PidolLineWrapper::onLineContentStarted() {
  lineContentStartOffsets.push_back(currentScriptBuffer.tell());
}

void PidolLineWrapper::beforeLinebreak(
    LinebreakSource clearSrc, int key) {
  if (clearSrc == linebreakManual) {
    applyPadAndCenterToCurrentLine();
    doLineEndPadChecks();
  }
}

void PidolLineWrapper::afterLinebreak(
    LinebreakSource clearSrc, int key) {
/*  if (clearSrc != linebreakBoxEnd) {
    if (spkrOn) {
      xPos = spkrLineInitialX;
    }
  } */
  
/*  if (clearSrc == linebreakManual) {
    if (breakMode == breakMode_double) {
      --yPos;
    }
  } */
  
  // the double-width text modes can't have text automatically broken
  // because there aren't enough lines in the box for it,
  // so it's an immediate error
  if (
//      doubleWidthModeOn
      doubleWidthCharsInWord
//    && (clearSrc != linebreakManual)
      ) {
    throw TGenericException(T_SRCANDLINE,
                            "PidolLineWrapper::afterLinebreak()",
                            "Line "
                              + TStringConversion::intToString(lineNum)
                              + ": double-width mode box overflow");
  }
}

void PidolLineWrapper::beforeBoxClear(
    BoxClearSource clearSrc, int key) {
//  if (((clearSrc == boxClearManual) && (key == code_wait))) {
//    xBeforeWait = xPos;
//  }
  if (failOnBoxOverflow && (clearSrc != boxClearManual)) {
    throw TGenericException(T_SRCANDLINE,
                            "PidolLineWrapper::beforeBoxClear()",
                            "Line "
                              + TStringConversion::intToString(lineNum)
                              + ": box overflow");
  }
  
  doLineEndPadChecks();
  
//  currentScriptBuffer.put('\n');
//  currentScriptBuffer.put('\n');
}

void PidolLineWrapper::afterBoxClear(
  BoxClearSource clearSrc, int key) {
  // wait pauses but does not automatically break the line
//  if (((clearSrc == boxClearManual) && (key == code_wait))) {
//    xPos = xBeforeWait;
//    yPos = -1;
/*    if (breakMode == breakMode_single) {
      yPos = -1;
    }
    else {
      yPos = -2;
    } */
//  }
}

void PidolLineWrapper::beforeWordFlushed() {
  doubleWidthCharsInWord = false;
}

char PidolLineWrapper::literalOpenSymbol() const {
  return myLiteralOpenSymbol;
}

char PidolLineWrapper::literalCloseSymbol() const {
  return myLiteralCloseSymbol;
}

bool PidolLineWrapper::processUserDirective(BlackT::TStream& ifs) {
  TParse::skipSpace(ifs);
  
  std::string name = TParse::matchName(ifs);
  TParse::matchChar(ifs, '(');
  
  for (int i = 0; i < name.size(); i++) {
    name[i] = toupper(name[i]);
  }
  
  if (name.compare("STARTSTRING") == 0) {
/*    // don't care
    TParse::matchInt(ifs);
    // don't care
    TParse::matchChar(ifs, ',');
    TParse::matchInt(ifs);
    // don't care
    TParse::matchChar(ifs, ',');
    TParse::matchInt(ifs);
    // isLiteral
    TParse::matchChar(ifs, ',');
    
    // turn on literal mode if literal
    copyEverythingLiterally = (TParse::matchInt(ifs) != 0); */
    
    return false;
  }
  else if (name.compare("ENDSTRING") == 0) {
    // HACK: for pad+center.
    // i don't remember how much of this is actually necessary,
    // this is pure copy and paste from another file
    // FIXME
      // output current word
      flushActiveWord();
      
      doLineEndPadChecks();
      applyPadAndCenterToCurrentLine();
//      applyPadAndCenterToCurrentBlock();
      padAndCenter_on = false;
      
      beforeBoxClear(boxClearManual, PidolTextScript::op_end16);
        
      xPos = 0;
      yPos = 0;
      pendingAdvanceWidth = 0;
      
      lineContentStartOffsets.clear();
      longestLineLen = 0;
      
      afterBoxClear(boxClearManual, PidolTextScript::op_end16);
      
      lineHasContent = false;
      currentLineContentStartInBuffer = -1;
    
    processEndMsg(ifs);
    return true;
  }
  else if (name.compare("SETBREAKMODE") == 0) {
    std::string type = TParse::matchName(ifs);
    
    if (type.compare("SINGLE") == 0) {
      breakMode = breakMode_single;
    }
    else if (type.compare("DOUBLE") == 0) {
      breakMode = breakMode_double;
    }
    else {
      throw TGenericException(T_SRCANDLINE,
                              "PidolLineWrapper::processUserDirective()",
                              "Line "
                                + TStringConversion::intToString(lineNum)
                                + ": unknown break mode '"
                                + type
                                + "'");
    }
    
    return true;
  }
  else if (name.compare("SETFAILONBOXOVERFLOW") == 0) {
    int value = TParse::matchInt(ifs);
    failOnBoxOverflow = (value != 0);
    
    return true;
  }
  else if (name.compare("SETPADANDCENTER") == 0) {
    padAndCenter_leftPad = TParse::matchInt(ifs);
    TParse::matchChar(ifs, ',');
    padAndCenter_width = TParse::matchInt(ifs);
    
    padAndCenter_on = true;
    
    return true;
  }
  else if (name.compare("DISABLEPADANDCENTER") == 0) {
    // output current word
    flushActiveWord();
    applyPadAndCenterToCurrentLine();
    padAndCenter_on = false;
    
    return true;
  }
  else if (name.compare("BREAKBOX") == 0) {
/*    flushActiveWord();
    int count = ySize - yPos;
    for (int i = 0; i < count; i++) {
      outputLinebreak();
    } */
    
    if (ySize == -1) {
      throw TGenericException(T_SRCANDLINE,
                              "PidolLineWrapper::processUserDirective()",
                              "Line "
                                + TStringConversion::intToString(lineNum)
                                + ": tried to break infinitely-high box");
    }
    
    flushActiveWord();
    std::string breakstr = thingy.getEntry(getLocalBrId());
    while (yPos < (ySize - 1)) {
      currentScriptBuffer.write(breakstr.c_str(), breakstr.size());
      ++yPos;
    }
    
    onBoxFull();
    
    return true;
  }
  else if (name.compare("BREAKGROUP") == 0) {
    if (yPos > ((ySize/2) - 1)) {
      throw TGenericException(T_SRCANDLINE,
                              "PidolLineWrapper::processUserDirective()",
                              "Line "
                                + TStringConversion::intToString(lineNum)
                                + ": tried to break overflowed group");
    }
      
    std::string breakstr = thingy.getEntry(getLocalBrId());
  
//    if (currentWordBuffer.size() <= 0) {
//      currentScriptBuffer.write(breakstr.c_str(), breakstr.size());
//    }
    
//    if (yPos != ((ySize/2) - 1)) {
//      std::cerr << "1: " << ySize << " " << yPos << std::endl;
    flushActiveWord();
//      std::cerr << "2: " << ySize << " " << yPos << std::endl;
    while (yPos < ((ySize/2) - 1)) {
//      while (yPos < ((ySize/2))) {
      currentScriptBuffer.write(breakstr.c_str(), breakstr.size());
      ++yPos;
    }
//      std::cerr << "3: " << ySize << " " << yPos << std::endl;
  
    // HACK to correctly handle empty groups
    lineHasContent = true;
    
    onBoxFull();
//      std::cerr << "4: " << ySize << " " << yPos << std::endl;
//    }
    
    return true;
  }
/*  else if (name.compare("PARABR") == 0) {
//    if (yPos >= ySize) {
//      onBoxFull();
//    }
//    else {
//      onBoxFull();
//    }
    flushActiveWord();
    outputLinebreak();
    return true;
  } */
//  else if (name.compare("ENDMSG") == 0) {
//    processEndMsg(ifs);
//    return true;
//  }
  
  return false;
}

std::string PidolLineWrapper::getPadString(int width) {
  std::string output;
  if (width <= 0) return output;
  
/*  while (width > 0) {
    if (width >= 8) {
      output += thingy.getEntry(code_space8px);
      width -= 8;
    }
    else if (width >= 4) {
      output += thingy.getEntry(code_space4px);
      width -= 4;
    }
    else {
      output += thingy.getEntry(code_space1px);
      width -= 1;
    }
  }*/
  
  output += thingy.getEntry(PidolTextScript::op_spaces);
  output += "<$";
  std::string valstr
    = TStringConversion::intToString(width, TStringConversion::baseHex)
        .substr(2, std::string::npos);
  while (valstr.size() < 2) valstr = std::string("0") + valstr;
  output += valstr;
  output += ">";
  return output;
}

void PidolLineWrapper::doLineEndPadChecks() {
  if (xPos > longestLineLen) longestLineLen = xPos;
}

void PidolLineWrapper::applyPadAndCenterToCurrentLine() {
  if (!padAndCenter_on) return;
  if (!lineHasContent) return;

  TBufStream temp;
  
  // copy script buffer up to start of current line content
  currentScriptBuffer.seek(0);
  temp.writeFrom(currentScriptBuffer, currentLineContentStartInBuffer);
  
  // insert padding at start of current line
//  std::cerr << "x: " << xPos << std::endl;
//  std::cerr << "padAndCenter_width: " << padAndCenter_width << std::endl;
  int centerOffset = 0;
  if (padAndCenter_width > 0) {
    centerOffset = (padAndCenter_width - xPos) / 2;
//    if (centerOffset < padAndCenter_leftPad) {
    if (centerOffset < 0) {
      throw TGenericException(T_SRCANDLINE,
                              "PidolLineWrapper::applyPadAndCenterToCurrentLine()",
                              "Line "
                                + TStringConversion::intToString(lineNum)
                                + ": cannot fit on line");
    }
  }
//  std::cerr << "centerOffset: " << centerOffset << std::endl;
//  char c;
//  std::cin >> c;
  temp.writeString(getPadString(padAndCenter_leftPad + centerOffset));
  
  // copy remaining content from original script buffer
  if (currentScriptBuffer.remaining() > 0)
    temp.writeFrom(currentScriptBuffer, currentScriptBuffer.remaining());
  
  currentScriptBuffer = temp;
}

void PidolLineWrapper::applyPadAndCenterToCurrentBlock() {
  if (!padAndCenter_on) return;
  if (longestLineLen <= 0) return;
  if (lineContentStartOffsets.size() <= 0) return;

  TBufStream temp;
  
//  std::cerr << longestLineLen << std::endl;
  
  int centerOffset = 0;
  if (padAndCenter_width > 0) {
    centerOffset = (padAndCenter_width - longestLineLen) / 2;
    if ((centerOffset < 0)
        || (longestLineLen > padAndCenter_width)) {
      throw TGenericException(T_SRCANDLINE,
                              "PidolLineWrapper::applyPadAndCenterToCurrentBlock()",
                              "Line "
                                + TStringConversion::intToString(lineNum)
                                + ": cannot fit on line");
    }
  }
  
  // copy script buffer up to start of first line
  currentScriptBuffer.seek(0);
  temp.writeFrom(currentScriptBuffer, lineContentStartOffsets[0]);
  
  std::string padString = getPadString(padAndCenter_leftPad + centerOffset);
//  std::cerr << padString << std::endl;
  // awkwardly splice all subsequent lines together with padding applied
  for (int i = 0; i < lineContentStartOffsets.size() - 1; i++) {
    temp.writeString(padString);
    temp.writeFrom(currentScriptBuffer,
      lineContentStartOffsets[i + 1] - lineContentStartOffsets[i]);
  }
  
  // remaining content
  temp.writeString(padString);
  if (currentScriptBuffer.remaining() > 0)
    temp.writeFrom(currentScriptBuffer, currentScriptBuffer.remaining());
  
  currentScriptBuffer = temp;
}

}
