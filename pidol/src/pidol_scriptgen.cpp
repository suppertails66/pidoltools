#include "util/TBufStream.h"
#include "util/TIfstream.h"
#include "util/TOfstream.h"
#include "util/TStringConversion.h"
#include "util/TThingyTable.h"
#include "util/TFileManip.h"
#include "util/TStringSearch.h"
#include "exception/TGenericException.h"
#include "pidol/PidolTranslationSheet.h"
#include "pidol/PidolScript.h"
#include "pidol/PidolTextScript.h"
#include <vector>
#include <list>
#include <string>
#include <iostream>
#include <map>
#include <exception>

using namespace std;
using namespace BlackT;
using namespace Pce;

const static int textBlockBaseSector = 0x2E7A;
const static int textBlockSize = 0x4000;
// note: looks like they allocated 10 blocks per chapter,
// with each chapter's section padded out with empty placeholder
// entries as needed
const static int numTextBlocks = 50;
const static int numBattleBlocks = 26;
const static int battleSectorBase = 0x206;
const static int battleBlockSize = 0x34;

const static int sectorSize = 0x800;
const static int areaBlockSize = 0x10000;
const static int advBlockSize = 0x20000;
const static int visualBlockSize = 0x40000;

// when auto-detecting free space, ignore up to this many bytes
// at the start (in case of misdetection at the end of some valid content
// and beginning of actual free space)
const static int freeAreaAutoDetectStartOffset = 16;

// for advscenes which also have text, reserve this many bytes
// of free space in the block for text, with the rest used for
// script content
const static int hybridAdvSceneReservedTextSize = 0x400;

// return true if target sector contains an adv
// which should have both subtitles and text
bool isHybridAdvScene(int sectorNum) {
  if ((sectorNum == 0x22FE)
      || (sectorNum == 0x3542)
      || (sectorNum == 0x3982))
    return true;
  return false;
}

struct FreeSpaceSpec {
  int pos;
  int size;
};

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

string as1bHex(int num) {
  string str = TStringConversion::intToString(num,
                  TStringConversion::baseHex).substr(2, string::npos);
  while (str.size() < 1) str = string("0") + str;
  
//  return "<$" + str + ">";
  return str;
}

string as2bHexPrefix(int num) {
  return "$" + as2bHex(num) + "";
}

string as2bHexLiteral(int num) {
  return "<$" + as2bHex(num) + ">";
}

string as1bHexLiteral(int num) {
  return "<$" + as1bHex(num) + ">";
}

//const static unsigned int mainExeLoadAddr = 0x8000F800;
//const static unsigned int mainExeBaseAddr = 0x80010000;
//const static unsigned int mapDataOffsetTableAddr = 0x8012335C;
//const static unsigned int numMaps = 0x46;

//TThingyTable tableScript;
//TThingyTable tableFixed;
//TThingyTable tableSjis;
//TThingyTable tableEnd;

TThingyTable tableRaw;
TThingyTable tableText;
TThingyTable tableCredits;
TThingyTable tableBackUtil;

void generateAnalyzedBoxString(
    std::string& content, std::string& prefix, std::string& suffix,
    bool noDefaultQuotes = false) {
  // scan first line of content for sjis open quote (81 75).
  // if one exists, and is not at the start of the line,
  // take whatever precedes it as the nametag and turn it
  // into a prefix.
  // also, we want to wrap all boxes of spoken text in quotes,
  // and this game makes the convenient stylistic choice of
  // having almost no narration, so we just assume everything
  // will be quoted in the script dump.
  // the handful of lines that aren't will be manually edited later.
  
//  std::cerr << "starting: " << content << std::endl;
  
  // default prefix = open quote
//  prefix = "{";
  
  // check if nametag prefix exists
  bool found = false;
  // fucking unsigned sizes!!
  for (int i = 0; i < (int)(content.size() - 1); i++) {
    unsigned char next = content[i];
    if (next >= 0x80) {
      unsigned char nextnext = content[i + 1];
      
      if ((next == 0x81) && (nextnext == 0x75)) {
        // sjis open quote on first line:
        // turn this into the prefix
        prefix += content.substr(0, i + 2);
        content = content.substr(i + 2, std::string::npos);
        found = true;
        break;
      }
      
      // 2-byte sequence: skip second char
      ++i;
    }
    else if ((char)next == '\n') {
      // we're only looking at the first line
      break;
    }
  }
  
  if (!found && !noDefaultQuotes) {
    // default prefix = open quote
    prefix += "{";
  }
  
  // suffix = close quote
  if (!noDefaultQuotes) {
    suffix += "}";
  }
  
//  std::cerr << "done: " << content << std::endl;
}

std::string doBattleCodeConversions(std::string str) {
  std::string result;
  
  TBufStream ifs;
  ifs.writeString(str);
  ifs.seek(0);
  
  while (!ifs.eof()) {
    unsigned char next = ifs.get();
    if (!ifs.eof()
        && (next >= 0x80)) {
      // sjis literal
      result += next;
      result += ifs.get();
    }
    else if ((char)next == '\\') {
      // command code
      char nextnext = ifs.get();
      
      // no params
      if ((nextnext == 'n') || (nextnext == 'N')
          || (nextnext == 's') || (nextnext == 'S')
          || (nextnext == 'u') || (nextnext == 'U')
          || (nextnext == '\\')) {
        result += next;
        // decapitalize for compatibility with our tables
        result += tolower(nextnext);
      }
      // these take a 2-digit param
      else if ((nextnext == 'l') || (nextnext == 'L')
               || (nextnext == 'p') || (nextnext == 'P')
               || (nextnext == 'w') || (nextnext == 'W')) {
        result += next;
        // decapitalize for compatibility with our tables
        result += tolower(nextnext);
        
        // convert 2-digit param to literal
        std::string intStr;
        // ignore first digit if zero
        if (ifs.peek() != '0') intStr += ifs.get();
        else ifs.get();
        // add second digit
        intStr += ifs.get();
        
        int val;
        // game uses "++" as a special sequence that's remapped
        // to 0x80 in code
        if (intStr.compare("++") == 0) val = 0x80;
        else val = TStringConversion::stringToInt(intStr);
        
        result += as2bHexLiteral(val);
      }
      else {
        throw TGenericException(T_SRCANDLINE,
                                "doBattleCodeConversions()",
                                "bad input");
      }
    }
    else {
      result += next;
    }
  }
  
  return result;
}

void generateAnalyzedBattleString(
    std::string& content, std::string& prefix, std::string& suffix) {
  // move any initial slash commands to the prefix
  
  std::string newPrefix;
  
//  std::cerr << content << std::endl;
  
  for (int i = 0; i < content.size() - 1; i++) {
    unsigned char next = content[i];
    if (next >= 0x80) {
      // done
      break;
    }
//    else if ((char)next == '\n') {
//      // we're only looking at the first line
//      break;
//    }
    else if ((char)next == '\\') {
      char nextnext = content[i + 1];
      
      // no params
      if ((nextnext == 'n') || (nextnext == 'N')
          || (nextnext == 's') || (nextnext == 'S')
          || (nextnext == 'u') || (nextnext == 'U')
          || (nextnext == '\\')) {
        newPrefix += next;
        newPrefix += nextnext;
        
        i += 1;
      }
      // these take a 2-digit param
      else if ((nextnext == 'l') || (nextnext == 'L')
               || (nextnext == 'p') || (nextnext == 'P')
               || (nextnext == 'w') || (nextnext == 'W')) {
        newPrefix += next;
        newPrefix += nextnext;
        newPrefix += content[i + 2];
        newPrefix += content[i + 3];
        
        i += 3;
      }
      else {
        throw TGenericException(T_SRCANDLINE,
                                "generateAnalyzedBattleString()",
                                "bad input");
      }
    }
    else {
      break;
    }
  }
  
//  std::cerr << "done: " << newPrefix << std::endl;
  
  if (!newPrefix.empty()) {
    prefix += newPrefix;
    if (newPrefix.size() == content.size()) content = "";
    else content = content.substr(newPrefix.size(), std::string::npos);
  }
  
  // convert character code sequences to new format
  content = doBattleCodeConversions(content);
  prefix = doBattleCodeConversions(prefix);
  suffix = doBattleCodeConversions(suffix);
  
//  std::cerr << "done2" << std::endl;
}

std::string toUtf8(std::string str) {
  // convert from SJIS to UTF8
  
  TBufStream conv;
  conv.writeString(str);
  conv.seek(0);
  
  std::string newStr;
  while (!conv.eof()) {
    if (conv.peek() == '\x0A') {
      newStr += conv.get();
    }
/*    else if (conv.peek() == '[') {
      std::string name;
      while (!conv.eof()) {
        char next = conv.get();
        name += next;
        if (next == ']') break;
      }
      newStr += name;
    } */
    else {
      TThingyTable::MatchResult result = tableRaw.matchId(conv);
      
      if (result.id == -1) {
        throw TGenericException(T_SRCANDLINE,
                                "toUtf8()",
                                "bad input string");
      }
      
      newStr += tableRaw.getEntry(result.id);
    }
  }
  
  return newStr;
}

/*std::string toUtf8(std::string str) {
  // convert from SJIS to UTF8
  
  TBufStream conv;
  conv.writeString(str);
  conv.seek(0);
  
  std::string newStr;
  while (!conv.eof()) {
    if (conv.peek() == '\x0A') {
      newStr += conv.get();
    }
    else {
      TThingyTable::MatchResult result = tableRaw.matchId(conv);
      
      if (result.id == -1) {
        throw TGenericException(T_SRCANDLINE,
                                "toUtf8()",
                                "bad input string");
      }
      
      newStr += tableRaw.getEntry(result.id);
    }
  }
  
  return newStr;
}*/

class PidolSubString {
public:
  PidolSubString()
    : visible(true) { }
  
  std::string content;
  std::string prefixBase;
  std::string suffixBase;
  bool visible;
};

typedef std::vector<PidolSubString> PidolSubStringCollection;

class PidolGenericString {
public:
  PidolGenericString()
      // needs to not be initialized to -1
      // see PidolScriptReader::flushActiveScript()
    : offset(0),
      size(0),
      mayNotExist(false),
      doBattleAnalysis(false),
      doBoxAnalysis(false) { }
  
  enum Type {
    type_none,
    type_string,
    type_mapString,
    type_setRegion,
    type_setRegionProperty,
    type_setMap,
    type_setNotCompressible,
    type_addOverwrite,
    type_addFreeSpace,
    type_genericLine,
    type_comment,
    type_marker
  };
  
  Type type;
  
  std::string content;
  std::string prefixBase;
  std::string suffixBase;
  int offset;
  int size;
  bool mayNotExist;
  bool doBattleAnalysis;
  bool doBoxAnalysis;
  
  std::string idOverride;
  
  int scriptRefStart;
  int scriptRefEnd;
  int scriptRefCode;
  
  std::string regionId;
  
  int mapMainId;
  int mapSubId;
  
  bool notCompressible;
  
  std::vector<int> pointerRefs;
//  int pointerBaseAddr;

  // fuck this
  std::vector<FreeSpaceSpec> freeSpaces;

  std::string translationPlaceholder;
  
  std::vector<int> overwriteAddresses;
  std::vector<int> extraIds;
  std::vector<std::string> genericLines;
  PidolSubStringCollection subStrings;
  
  void addPropSet(std::string name, std::string value) {
    if (prefixBase.size() > 0) prefixBase += "\r\n";
    prefixBase = prefixBase + "#P("
      + "\"\"" + name + "\"\", "
      + "\"\"" + value + "\"\")";
  }
  
protected:
  
};

typedef std::vector<PidolGenericString> PidolGenericStringCollection;

class PidolGenericStringSet {
public:
    
  PidolGenericStringCollection strings;
  
  static PidolGenericString readString(TStream& src, const TThingyTable& table,
                              int offset) {
    PidolGenericString result;
    result.type = PidolGenericString::type_string;
    result.offset = offset;
    
    src.seek(offset);
    while (!src.eof()) {
      if (src.peek() == 0x00) {
        src.get();
        result.size = src.tell() - offset;
        return result;
      }
      
      TThingyTable::MatchResult matchCheck
        = table.matchId(src);
      if (matchCheck.id == -1) break;
      
      std::string newStr = table.getEntry(matchCheck.id);
      result.content += newStr;
      
      // HACK
      if (newStr.compare("\\n") == 0) result.content += "\n";
    }
    
    throw TGenericException(T_SRCANDLINE,
                            "PidolGenericStringSet::readString()",
                            std::string("bad string at ")
                            + TStringConversion::intToString(offset));
  }
  
  void addString(TStream& src, const TThingyTable& table,
                 int offset) {
    PidolGenericString result = readString(src, table, offset);
    strings.push_back(result);
  }
  
  void addRawString(std::string content, int offset, int size) {
    PidolGenericString result;
    result.type = PidolGenericString::type_string;
    result.content = content;
    result.offset = offset;
    result.size = size;
    strings.push_back(result);
  }
  
  void addOverwriteString(TStream& src, const TThingyTable& table,
                 int offset) {
    PidolGenericString result = readString(src, table, offset);
    result.overwriteAddresses.push_back(offset);
    strings.push_back(result);
  }
  
  void addPlaceholderStrings(int count, std::string label) {
    for (int i = 0; i < count; i++) {
      PidolGenericString result;
      
      result.type = PidolGenericString::type_string;
      result.offset = 0;
      result.size = 0;
      result.mayNotExist = true;
      result.idOverride = label
        + TStringConversion::intToString(i,
            TStringConversion::baseDec);
      strings.push_back(result);
    }
  }
  
  void addMarker(std::string content) {
    PidolGenericString result;
    result.type = PidolGenericString::type_marker;
    result.content = content;
    strings.push_back(result);
  }
  
  void addPointerTableString(TStream& src, const TThingyTable& table,
                             int offset, int pointerOffset) {
    // check if string already exists, and add pointer ref if so
    for (unsigned int i = 0; i < strings.size(); i++) {
      PidolGenericString& checkStr = strings[i];
      // mapStrings need not apply
      if (checkStr.type == PidolGenericString::type_string) {
        if (checkStr.offset == offset) {
          checkStr.pointerRefs.push_back(pointerOffset);
          return;
        }
      }
    }
    
    // new string needed
    PidolGenericString result = readString(src, table, offset);
    result.pointerRefs.push_back(pointerOffset);
    strings.push_back(result);
  }
  
  void addComment(std::string comment) {
    PidolGenericString result;
    result.type = PidolGenericString::type_comment;
    result.content = comment;
    strings.push_back(result);
  }
  
  void addSetNotCompressible(bool notCompressible) {
    PidolGenericString result;
    result.type = PidolGenericString::type_setNotCompressible;
    result.notCompressible = notCompressible;
    strings.push_back(result);
  }
  
  void addAddOverwrite(int offset) {
    PidolGenericString result;
    result.type = PidolGenericString::type_addOverwrite;
    result.offset = offset;
    strings.push_back(result);
  }
  
  void addAddFreeSpace(int offset, int size) {
    PidolGenericString result;
    result.type = PidolGenericString::type_addFreeSpace;
    result.offset = offset;
    result.size = size;
    strings.push_back(result);
    
    std::cerr << "adding free space: "
      << hex << offset << " " << hex << size << endl;
  }
  
  void addSetRegion(std::string regionId) {
    PidolGenericString str;
    str.type = PidolGenericString::type_setRegion;
    str.regionId = regionId;
    strings.push_back(str);
  }
  
  void addSetRegionProperty(std::string propertyName,
                      std::string propertyValue) {
    PidolGenericString str;
    str.type = PidolGenericString::type_setRegionProperty;
    str.regionId = propertyName;
    str.content = propertyValue;
    strings.push_back(str);
  }
  
  void addGenericLine(std::string content) {
    PidolGenericString str;
    str.type = PidolGenericString::type_genericLine;
    str.content = content;
    strings.push_back(str);
  }
  
  void exportToSheet(
      PidolTranslationSheet& dst,
      std::ostream& ofs,
      std::string idPrefix) const {
    int strNum = 0;
    for (unsigned int i = 0; i < strings.size(); i++) {
//      const PidolGenericString& item = strings[i];
      PidolGenericString item = strings[i];
      
      if ((item.type == PidolGenericString::type_string)
          || (item.type == PidolGenericString::type_mapString)) {
        // force everything onto substring system
        if (item.subStrings.size() == 0) {
          PidolSubString str;
          str.content = item.content;
          str.prefixBase = item.prefixBase;
          str.suffixBase = item.suffixBase;
          item.subStrings.push_back(str);
        }
        
        std::string idString = idPrefix
//          + TStringConversion::intToString(strNum)
//          + "-"
          + TStringConversion::intToString(item.offset,
              TStringConversion::baseHex);
        if (!item.idOverride.empty()) idString = item.idOverride;
        
        for (int j = 0; j < item.subStrings.size(); j++) {
          std::string subIdString
            = idString + "_" + TStringConversion::intToString(j);
        
//          std::string content = item.content;
//          std::string prefix = "";
//          std::string suffix = "";
          std::string content = item.subStrings[j].content;
          std::string prefix = "";
          std::string suffix = "";
          
          prefix = item.subStrings[j].prefixBase + prefix;
          suffix = item.subStrings[j].suffixBase + suffix;
      
  //    std::cerr << content << std::endl;
          
  //        content = toUtf8(content);
  //        prefix = toUtf8(prefix);
  //        suffix = toUtf8(suffix);
          
  //        std::cerr << content << std::endl;
          
          // items flagged as possibly-not-existing do not get a dummy entry
          // in the translation sheet; we assume the user will add them
          // as needed
          // ...actually, no, do just the opposite of that
//          if (!item.mayNotExist) {
            if (item.subStrings[j].visible) {
              dst.addStringEntry(
                subIdString, content, prefix, suffix,
                item.translationPlaceholder);
            }
//          }
        }
        
        ofs << "#STARTSTRING("
          << "\"" << idString << "\""
/*          << ", "
          << TStringConversion::intToString(item.offset,
              TStringConversion::baseHex)
          << ", "
          << TStringConversion::intToString(item.size,
              TStringConversion::baseHex)*/
          << ")" << endl;
        
/*        ofs << "#SETSTRINGORIGINALOFFSET("
          << TStringConversion::intToString(item.offset,
              TStringConversion::baseHex)
          << ")" << endl;
        ofs << "#SETSTRINGORIGINALSIZE("
          << TStringConversion::intToString(item.size,
              TStringConversion::baseHex)
          << ")" << endl;*/
        
        if (item.size > 0) {
          ofs << "#ADDFREESPACE("
            << TStringConversion::intToString(item.offset,
                TStringConversion::baseHex)
            << ", "
            << TStringConversion::intToString(item.size,
                TStringConversion::baseHex)
            << ")" << endl;
        }
        
/*        for (auto refOffset: item.pointerRefs) {
          ofs << "#ADDPOINTERREF("
            << TStringConversion::intToString(refOffset,
                 TStringConversion::baseHex)
            << ")" << endl;
        }*/
        
        if (item.type == PidolGenericString::type_mapString) {
          ofs << "#SETSCRIPTREF("
            << TStringConversion::intToString(item.scriptRefStart,
              TStringConversion::baseHex)
            << ", "
            << TStringConversion::intToString(item.scriptRefEnd,
              TStringConversion::baseHex)
            << ", "
            << TStringConversion::intToString(item.scriptRefCode,
              TStringConversion::baseHex)
            << ")"
            << endl;
        }
        
        for (unsigned int i = 0; i < item.freeSpaces.size(); i++) {
          ofs << "#ADDFREESPACE("
            << TStringConversion::intToString(item.freeSpaces[i].pos,
              TStringConversion::baseHex)
            << ", "
            << TStringConversion::intToString(item.freeSpaces[i].size,
              TStringConversion::baseHex)
            << ")"
            << endl;
        }
        
//        ofs << "#SETNUMPOINTERREFS("
//          << TStringConversion::intToString(item.pointerRefs.size(),
//            TStringConversion::baseHex)
//          << ")"
//          << endl;
        
        for (unsigned int i = 0; i < item.pointerRefs.size(); i++) {
          ofs << "#ADDPOINTERREF("
            << TStringConversion::intToString(item.pointerRefs[i],
              TStringConversion::baseHex)
            << ")"
            << endl;
        }
        
        for (unsigned int i = 0; i < item.overwriteAddresses.size(); i++) {
          ofs << "#ADDOVERWRITE("
            << TStringConversion::intToString(item.overwriteAddresses[i],
              TStringConversion::baseHex)
            << ")"
            << endl;
        }
        
        for (unsigned int i = 0; i < item.extraIds.size(); i++) {
          ofs << "#ADDEXTRAID("
            << TStringConversion::intToString(item.extraIds[i],
              TStringConversion::baseHex)
            << ")"
            << endl;
        }
        
        for (unsigned int i = 0; i < item.genericLines.size(); i++) {
          ofs << item.genericLines[i] << std::endl;
        }
        
        for (int j = 0; j < item.subStrings.size(); j++) {
          if (item.subStrings[j].visible) {
            if (item.mayNotExist)
              ofs << "#IMPORTIFEXISTS(\"";
            else
              ofs << "#IMPORT(\"";
            
            ofs << (idString + "_" + TStringConversion::intToString(j))
              << "\")" << endl;
          }
          else {
            ofs << item.subStrings[j].prefixBase
              << item.subStrings[j].content
              << item.subStrings[j].suffixBase << endl;
          }
        }
        
        ofs << "#ENDSTRING()" << endl;
        ofs << endl;
        
        ++strNum;
      }
      else if (item.type == PidolGenericString::type_setRegion) {
        ofs << "#STARTREGION(\""
          << item.regionId
          << "\")" << endl;
        ofs << endl;
      }
      else if (item.type == PidolGenericString::type_setRegionProperty) {
        ofs << "#SETREGIONPROPERTY(\""
          << item.regionId
          << "\", \""
          << item.content
          << "\")" << endl;
        ofs << endl;
      }
      else if (item.type == PidolGenericString::type_setMap) {
        ofs << "#SETMAP("
          << item.mapMainId
          << ", "
          << item.mapSubId
          << ")" << endl;
        ofs << endl;
      }
      else if (item.type == PidolGenericString::type_setNotCompressible) {
        ofs << "#SETNOTCOMPRESSIBLE("
          << (item.notCompressible ? 1 : 0)
          << ")" << endl;
        ofs << endl;
      }
      else if (item.type == PidolGenericString::type_addOverwrite) {
        ofs << "#ADDOVERWRITE("
          << TStringConversion::intToString(item.offset,
            TStringConversion::baseHex)
          << ")" << endl;
        ofs << endl;
      }
      else if (item.type == PidolGenericString::type_addFreeSpace) {
        ofs << "#ADDFREESPACE("
          << TStringConversion::intToString(item.offset,
            TStringConversion::baseHex)
          << ", "
          << TStringConversion::intToString(item.size,
            TStringConversion::baseHex)
          << ")" << endl;
        ofs << endl;
      }
      else if (item.type == PidolGenericString::type_genericLine) {
        ofs << item.content << endl;
        ofs << endl;
      }
      else if (item.type == PidolGenericString::type_comment) {
        dst.addCommentEntry(item.content);
        
        ofs << "//===================================" << endl;
        ofs << "// " << item.content << endl;
        ofs << "//===================================" << endl;
        ofs << endl;
      }
      else if (item.type == PidolGenericString::type_marker) {
        dst.addMarkerEntry(item.content);
        
        ofs << "// === MARKER: " << item.content << endl;
        ofs << endl;
      }
    }
  }
  
protected:
  
};

class TextscriptBadException : public std::exception {
public:
  
protected:
  
};

int testForTextscript(TStream& ifs) {
  int start = ifs.tell();
//  bool textContentFound = false;
  int numTextCharsFound = 0;
  while (true) {
    if (ifs.remaining() <= 0) throw TextscriptBadException();
    
    int next = ifs.readu8();
    ifs.seekoff(-1);
    
    // terminator check
    if (PidolTextScript::isTerminator(next)) {
      ifs.seekoff(1);
      break;
    }
    // op check
    else if (PidolTextScript::isOp(next)) {
//      ofs.put(next);
      ifs.seekoff(1);
      int argsSize = PidolTextScript::getOpArgsSize(next);
      int nextPos = ifs.tell() + argsSize;
//      for (int i = 0; i < argsSize; i++) {
//        ofs.put(ifs.get());
//      }
      
      if (ifs.remaining() < argsSize) throw TextscriptBadException();
      
      // sanity checks for specific ops
      if ((next == PidolTextScript::op_fcolor)
          || (next == PidolTextScript::op_scolor)) {
        // valid text colors are 0x0-0xF
        int colorIndex = ifs.readu8();
        if (colorIndex >= 0x10) throw TextscriptBadException();
      }
      
      ifs.seek(nextPos);
    }
    // text check
    else {
      TThingyTable::MatchResult result = tableText.matchId(ifs);
      if (result.id == -1) {
        throw TextscriptBadException();
      }
      
      if (ifs.remaining() < result.size) throw TextscriptBadException();
      
//      ifs.seekoff(result.size);
//      textContentFound = true;
      ++numTextCharsFound;
    }
  }
  
  // no text in textscript means we don't care about it
  // (TODO: probably. will space generator commands matter?)
  if (numTextCharsFound == 0) throw TextscriptBadException();
  
  int outputSize = ifs.tell() - start;
  
  // prevent generation of inordinately long output with very
  // few characters
//  if ((outputSize >= 512) && (numTextCharsFound <= 8))
  if ((outputSize >= 512) && ((outputSize / numTextCharsFound) >= 32)) {
//    std::cerr << "throwing out large+sparse output" << std::endl;
    throw TextscriptBadException();
  }
  
  return outputSize;
}

void dumpRawTextscript(TStream& ifs, std::string& output) {
  while (true) {
    if (ifs.remaining() <= 0) throw TextscriptBadException();
    
//    int next = (unsigned int)ifs.peek();
    
    TThingyTable::MatchResult result = tableRaw.matchId(ifs);
    output += tableRaw.getEntry(result.id);
    int next = result.id;
    
    // terminator check
    if (PidolTextScript::isTerminator(next)) {
      break;
    }
    // op check
    else if (PidolTextScript::isOp(next)) {
      int argsSize = PidolTextScript::getOpArgsSize(next);
      for (int i = 0; i < argsSize; i++) {
        output += as2bHexLiteral(ifs.readu8());
      }
      
      // HACK: newlines
      // box wait
      if ((next == 0x04) && (!PidolTextScript::isTerminator(ifs.peek()))) {
        output += "\n\n"; 
      }
      // anything else
      else {
        output += "\n";
      }
    }
    // text
    else {
      
    }
  }
}

//enum TextscriptDumpMode {
//  textscriptDumpMode_none,
//  textscriptDumpMode_text,
//  textscriptDumpMode_other
//};

bool dumpNextTextscriptSubstring(TStream& ifs,
    PidolSubStringCollection& outputContainer) {
  bool terminated = false;
  
  PidolSubString output;
  
//  TextscriptDumpMode dumpMode = textscriptDumpMode_none;
  bool modeSet = false;
  int numTextCharsOnLine = 0;
  int numTextCharsTotal = 0;
  int numLines = 1;
  bool containsSpaces = false;
  while (true) {
    if (ifs.remaining() <= 0) throw TextscriptBadException();
    
    int startPos = ifs.tell();
    
    TThingyTable::MatchResult result = tableRaw.matchId(ifs);
    int next = result.id;
    
    if (!modeSet) {
      if (!PidolTextScript::isOp(next)
          || PidolTextScript::isInlineableOp(next)) {
        output.visible = true;
      }
      else {
        output.visible = false;
      }
      
      modeSet = true;
    }
    else {
      if (!output.visible
          && (!PidolTextScript::isOp(next)
              || PidolTextScript::isInlineableOp(next))) {
        ifs.seek(startPos);
        break;
      }
      else if (output.visible
          && (PidolTextScript::isOp(next)
              && !PidolTextScript::isInlineableOp(next))) {
        ifs.seek(startPos);
        break;
      }
    }
    
    // terminator check
    if (PidolTextScript::isTerminator(next)) {
      output.content += tableRaw.getEntry(result.id);
      
      terminated = true;
      break;
    }
    // op check
    else if (PidolTextScript::isOp(next)
             && (next != PidolTextScript::op_spaces)) {
      output.content += tableRaw.getEntry(result.id);
      
      int argsSize = PidolTextScript::getOpArgsSize(next);
      for (int i = 0; i < argsSize; i++) {
        output.content += as2bHexLiteral(ifs.readu8());
      }
      
//      if ((next == PidolTextScript::op_spaces)) {
//        containsSpaces = true;
//      }
      
      // HACK: newlines
      // box wait
//      if ((next == PidolTextScript::op_clear)
//          && (!PidolTextScript::isTerminator(ifs.peek()))) {
//        output.content += "\n\n"; 
//      }
//      else
      if ((next == PidolTextScript::op_newline)) {
        output.content += "\n";
        numTextCharsOnLine = 0;
        ++numLines;
      }
      // anything else
      else {
//        output.content += "\n";
      }
    }
    // text
    else {
      int repeatCount = 1;
      std::string nextSymbol = tableRaw.getEntry(result.id);
      
      if ((next == PidolTextScript::op_spaces)) {
        containsSpaces = true;
        repeatCount = ifs.readu8();
        // character to output = sjis space
        nextSymbol = "\x81\x40";
      }
      
      for (int i = 0; i < repeatCount; i++) {
        // auto-newline
        if (numTextCharsOnLine >= 16) {
          output.content += "\n";
          numTextCharsOnLine = 0;
          ++numLines;
        }
        
        output.content += nextSymbol;
        
        ++numTextCharsOnLine;
        ++numTextCharsTotal;
      }
    }
  }
  
  // trim trailing newlines
  while ((output.content.back() == '\n')
          || (output.content.back() == '\r'))
    output.content = output.content.substr(0, output.content.size() - 1);
  
  // anything with no literal characters whatsoever should not be visible
  if (numTextCharsTotal == 0)
    output.visible = false;
  
  if (output.visible) {
    // if nametag prefix detected, handle appropriately
    for (int i = 0; i < output.content.size(); ) {
      TByte next = output.content[i];
      
      // ignore if not on first line
      if (next == '\n') break;
      
      if (next >= 0x80) {
        // sjis
        TByte nextnext = output.content[i + 1];
        
        // check for open quote
        if (((next == 0x81) && (nextnext == 0x75))) {
          output.prefixBase = output.content.substr(0, i + 2);
          output.suffixBase = "\x81\x76";
          output.content = output.content.substr(i + 2, std::string::npos);
          break;
        }
        // open parenthesis
        else if (((next == 0x81) && (nextnext == 0x69))) {
          // name + open parenthesis is used to indicate thoughts,
          // but parentheses are also used when listing name readings
          // on the character bio menu.
          // ignore entries containing spaces to circumvent this.
          if (!containsSpaces) {
            output.prefixBase = output.content.substr(0, i + 2);
            output.suffixBase = "\x81\x6A";
            output.content = output.content.substr(i + 2, std::string::npos);
            break;
          }
        }
        
        i += 2;
      }
      else {
        ++i;
      }
    }
  }
  
  outputContainer.push_back(output);
  return terminated;
}

void dumpTextscriptAsSubstrings(TStream& ifs,
    PidolSubStringCollection& output) {
  while (!dumpNextTextscriptSubstring(ifs, output));
}

struct TextscrCheckResult {
  std::list<int> srcRefOffsets;
  int size;
};

void dumpScriptBlock(TStream& ifs, int blockBaseOffset, int blockSize,
                     PidolGenericStringSet& strings,
                     std::string baseIdName = "") {
  
  std::map<int, TextscrCheckResult> textscrCheckOffsets;
  {
    int nextSearchPos = blockBaseOffset;
    // note that the scan is linear and includes the
    // parameter portion of things it thinks are ops.
    // this is in case of a misdetection.
    while (nextSearchPos++ <= ((blockBaseOffset + blockSize) - 3)) {
      ifs.seek(nextSearchPos);
      
      TByte next = ifs.get();
      if (next != 0x3E) continue;
      
      int offset = ifs.readu16le();
      if (offset >= blockSize) continue;
      
      // there are 0x69 gamescript ops (and 0xFF as terminator?);
      // if the next byte doesn't fall in that range,
      // this isn't valid
      int nextnext = ifs.readu8();
      if ((nextnext != 0xFF) && (nextnext >= 0x69)) continue;
      
      textscrCheckOffsets[offset].srcRefOffsets.push_back(nextSearchPos + 1);
    }
  }
  
  std::map<int, TextscrCheckResult> textscrFoundOffsets;
  for (auto it: textscrCheckOffsets) {
    int offset = it.first;
    ifs.seek(blockBaseOffset + offset);
//    TBufStream ofs;
    
    std::cerr << std::hex << ifs.tell() << std::endl;
    
    try {
      int start = ifs.tell();
      int size = testForTextscript(ifs);
      
      // HACK: hardcoded filter for various misdetections
      if (
          (baseIdName.compare("area-0x2D6") == 0
              && ((start == 0x764D)
                  || (start == 0x9164))
              )
          || (baseIdName.compare("area-0x336") == 0
            && ((start == 0xA117)
                )
            )
          || (baseIdName.compare("area-0x356") == 0
            && ((start >= 0xA630))
            )
          || (baseIdName.compare("area-0x132E") == 0
            && ((start == 0x8168)
                || (start == 0x8520)
                || (start == 0x8521)
                || (start == 0x8528)
                || (start == 0x8553)
                || (start == 0x8559))
            )
          || (baseIdName.compare("area-0x1EBE") == 0
            && ((start == 0x795F))
            )
          || (baseIdName.compare("area-0x1EFE") == 0
            && ((start == 0xA843))
            )
          || (baseIdName.compare("area-0x1F5E") == 0
            && ((start == 0xBA6C)
                || (start == 0xBA6F))
            )
          || (baseIdName.compare("area-0x31C2") == 0
            && ((start == 0x4206))
            )
          || (baseIdName.compare("area-0x3202") == 0
            && ((start == 0x4E00))
            )
          || (baseIdName.compare("area-0x3222") == 0
            && ((start == 0x5537)
                || (start == 0x8F03))
            )
          ) {
        throw TextscriptBadException();
      }
      
      std::cerr << "  success" << std::endl;
      
      textscrFoundOffsets[offset] = textscrCheckOffsets[offset];
      textscrFoundOffsets[offset].size = size;
      
/*//      std::string content;
//      dumpRawTextscript(ifs, content);
      
      PidolGenericString result;
      
      ifs.seek(start);
      dumpTextscriptAsSubstrings(ifs, result.subStrings);
      
      result.type = PidolGenericString::type_string;
//      result.content = content;
      result.offset = start;
      result.size = size;
//      result.idOverride = idOverride;
      strings.strings.push_back(result);*/
    }
    catch (TextscriptBadException& e) {
      std::cerr << "  failed at " << std::hex << ifs.tell() << std::endl;
    }
  }
  
  // check for overlapping scripts, taking the earliest offset
  // available if there is a conflict.
  // this could potentially be a problem if the game ever does the
  // old-school rpg trick of skipping earlier parts of a conversation
  // by pointing directly into a later segment, but i'm hoping it won't
  // come to that...
  std::map<int, TextscrCheckResult> textscrSemifinalOffsets;
  for (std::map<int, TextscrCheckResult>::iterator it
        = textscrFoundOffsets.begin();
       it != textscrFoundOffsets.end();
       // !! no increment!
       ) {
    ++it;
/*    if (it == textscrFoundOffsets.end()) {
      // final entry
      --it;
      textscrSemifinalOffsets[it->first] = it->second;
      break;
    }*/
    std::map<int, TextscrCheckResult>::iterator nextIt = it;
    --it;
    
    int startPos = it->first;
    int endPos = startPos + it->second.size;
    
    while (true) {
      if (nextIt == textscrFoundOffsets.end()) {
        textscrSemifinalOffsets[it->first] = it->second;
        break;
      }
      
      if ((nextIt->first >= startPos) && (nextIt->first < endPos)) {
        // overlap
        ++nextIt;
      }
      else {
        // no overlap
        textscrSemifinalOffsets[it->first] = it->second;
        break;
      }
    }
    
    it = nextIt;
  }
  
  // prune any references which overlap a script
  
  std::map<int, bool> refOffsets;
  for (auto it: textscrSemifinalOffsets) {
    for (auto jt: it.second.srcRefOffsets) {
      refOffsets[jt] = false;
    }
  }
  
  std::map<int, bool> badRefOffsets;
  for (auto it: refOffsets) {
    int refStart = it.first - 1;
    // a genuine reference must have, at minimum, one byte of gamescript
    // data following (for a script terminator), so the size here is 4
    // rather than just 3 for the reference op itself
    int refEnd = refStart + 4;
    
  
//    if (baseIdName.compare("area-0x1EDE") == 0) {
//      std::cerr << "refStart: " << hex << refStart << std::endl;
//    }
    for (auto jt: textscrSemifinalOffsets) {
//      if (baseIdName.compare("area-0x1EDE") == 0) {
//        std::cerr << "comparing: " << hex << jt.first << " " << hex << jt.second.size << std::endl;
//      }
      
      int textscrStartAbsolute = jt.first + blockBaseOffset;
      int textscrEndAbsolute = textscrStartAbsolute + jt.second.size;
      
      if (((refStart >= textscrStartAbsolute)
             && (refStart < textscrEndAbsolute))
          || ((refEnd > textscrStartAbsolute)
             && (refEnd <= textscrEndAbsolute))
          ) {
        std::cerr << "bad ref: " << hex << refStart << " " << hex << refEnd << std::endl;
        std::cerr << "  overlaps: " << hex << textscrStartAbsolute
          << " " << hex << textscrEndAbsolute << std::endl;
        badRefOffsets[it.first] = false;
        continue;
      }
    }
  }

/*  if (baseIdName.compare("area-0x1EDE") == 0) {
//    for (auto kt: badRefOffsets) {
//      std::cerr << hex << kt.first << std::endl;
//    }
    char c;
    std::cin >> c;
  }*/
  
//  for (auto it: textscrSemifinalOffsets) {
  std::map<int, TextscrCheckResult> textscrFinalOffsets;
  for (std::map<int, TextscrCheckResult>::iterator it
        = textscrSemifinalOffsets.begin();
       it != textscrSemifinalOffsets.end();
       ++it) {
    for (std::list<int>::iterator jt
          = it->second.srcRefOffsets.begin();
         jt != it->second.srcRefOffsets.end();
         // !! no increment!
         ) {
      bool erased = false;
      for (auto kt: badRefOffsets) {
        if ((*jt) == kt.first) {
          std::list<int>::iterator temp = jt;
          ++jt;
          it->second.srcRefOffsets.erase(temp);
          erased = true;
          std::cerr << "erased: " << std::hex << kt.first << std::endl;
          break;
        }
      }
      
      if (!erased) ++jt;
    }
    
    // prune anything which is left with no references
    if (it->second.srcRefOffsets.size() > 0) {
      textscrFinalOffsets[it->first] = it->second;
    }
  }
  
  // dump final output
  for (auto it: textscrFinalOffsets) {
    int offset = it.first;
    ifs.seek(blockBaseOffset + offset);
    int start = ifs.tell();
    int size = it.second.size;
    
    std::string content;
    
    PidolGenericString result;
    
//    ifs.seek(start);
    dumpTextscriptAsSubstrings(ifs, result.subStrings);
    
    for (auto jt: it.second.srcRefOffsets) {
      result.pointerRefs.push_back(jt);
    }
    
    result.type = PidolGenericString::type_string;
    result.offset = start;
    result.size = size;
    result.idOverride = baseIdName
      + "-"
      + TStringConversion::intToString(result.offset,
          TStringConversion::baseHex);
    
    // HACK: dump certain lines "raw" instead of splitting into boxes
    if (
        // case 2b: letter in sickle handle,
        // message shown when first opened
        ((baseIdName.compare("area-0x1F1E") == 0)
          && (start == 0x7350))
        // case 2b: letter in sickle handle,
        // when choosing "view note" option
        || ((baseIdName.compare("area-0x1F1E") == 0)
            && (start == 0x970A))
        ) {
      PidolSubString newOutput;
      newOutput.visible = true;
      for (auto jt: result.subStrings) {
        newOutput.content += jt.prefixBase;
        newOutput.content += jt.content;
        newOutput.content += jt.suffixBase;
      }
      result.subStrings.clear();
      result.subStrings.push_back(newOutput);
    }
    
    strings.strings.push_back(result);
  }
}

void dumpAreaBlock(TStream& ifs, PidolGenericStringSet& strings,
                   std::string baseIdName = "") {
  
  // - scan banks 2-7 for anything that looks like a gamescript
  //   command to run a textscript.
  //   - format is 3E XX XX, where XXXX is a 16-bit little endian
  //     offset into the bank2+ area;
  //     anything over 0xC000 is invalid
  // - go through and try to read all those locations as textscripts;
  //   throw out anything invalid
  // - mark down all textscript start offsets in a TFreeSpace.
  //   in a separate TFreeSpace, keep track of which areas have been
  //   established as having content, including the source gamescript
  //   commands, so we know that anything which intersects those
  //   is already found or not valid
  // - do a linear scan for anything that looks like a valid textscript;
  //   throw out anything with an intersection in the TFreeSpace
  
/*  std::map<int, int> textscrCheckOffsets;
  {
    int nextSearchPos = 0x4000;
    // note that the scan is linear and includes the
    // parameter portion of things it thinks are ops.
    // this is in case of a misdetection.
    while (nextSearchPos++ <= (ifs.size() - 3)) {
      ifs.seek(nextSearchPos);
      
      TByte next = ifs.get();
      if (next != 0x3E) continue;
      
      int offset = ifs.readu16le();
      if (offset >= 0xC000) continue;
      
      // there are 0x69 gamescript ops;
      // if the next byte doesn't fall in that range,
      // this isn't valid
      if (ifs.readu8() >= 0x69) continue;
      
      textscrCheckOffsets[offset] = offset;
    }
  }
  
  for (auto it: textscrCheckOffsets) {
    int offset = it.first;
    ifs.seek(0x4000 + offset);
//    TBufStream ofs;
    
    std::cerr << std::hex << ifs.tell() << std::endl;
    
    try {
      int start = ifs.tell();
      int size = testForTextscript(ifs);
      
      // TEST
      
      std::cerr << "  success" << std::endl;
      
      ifs.seek(start);
      std::string content;
      dumpRawTextscript(ifs, content);
      
      PidolGenericString result;
      result.type = PidolGenericString::type_string;
      result.content = content;
      result.offset = start;
      result.size = size;
//      result.idOverride = idOverride;
      strings.strings.push_back(result);
    }
    catch (TextscriptBadException& e) {
      std::cerr << "  failed at " << std::hex << ifs.tell() << std::endl;
    }
  } */
  
  dumpScriptBlock(ifs, 0x4000, 0xC000, strings,
                  baseIdName);
}

void dumpAdvBlock(TStream& ifs, PidolGenericStringSet& strings,
                  std::string baseIdName = "") {
  dumpScriptBlock(ifs, 0x0, 0x2000, strings,
                  baseIdName);
}

int countBackwardsRepeats(TStream& ifs, int endPos, char checkByte) {
  if (endPos == 0) return 0;
  
  ifs.seek(endPos - 1);
  if (ifs.peek() != checkByte) return 0;
  
  while ((ifs.tell() > 0) && (ifs.peek() == checkByte)) ifs.seekoff(-1);
  return (endPos - ifs.tell());
}

int countSafeBackwardsRepeats(TStream& ifs, int endPos, char checkByte) {
  int result = countBackwardsRepeats(ifs, endPos, checkByte);
  result -= freeAreaAutoDetectStartOffset;
  if (result < 0) result = 0;
  return result;
}

void dumpIsoAreaBlock(TStream& ifs, int sectorNum,
                      PidolGenericStringSet& strings) {
  // TEST
//  return;
  std::cout << "dumping area block at " << std::hex << sectorNum << std::endl;
  
  strings.addComment(
               string("Area block ")
                + TStringConversion::intToString(sectorNum,
                    TStringConversion::baseHex));
  
  std::string regionName = std::string("area-")
    + TStringConversion::intToString(sectorNum,
        TStringConversion::baseHex);
  strings.addSetRegion(regionName);
  strings.addGenericLine("#SETREGIONTYPE(\"area\")");
  strings.addSetRegionProperty("originSector",
    TStringConversion::intToString(sectorNum,
      TStringConversion::baseHex));
  
  int blockBaseAddr = (sectorNum * sectorSize);
  ifs.seek(blockBaseAddr);
  TBufStream areaOfs;
  areaOfs.writeFrom(ifs, areaBlockSize);
  
  int freeArea1Size = countSafeBackwardsRepeats(areaOfs, 0x2000, 0xFF);
  int freeArea2Size = countSafeBackwardsRepeats(areaOfs, 0x3000, 0xFF);
  int freeArea3Size = countSafeBackwardsRepeats(areaOfs, 0x4000, 0xFF);
  
  if (freeArea1Size > 0)
    // HACK: we need some extra free space for new code and data
    // in the cafe menu, so exclude part of the end of the bank
    if ((sectorNum == 0x3202)) {
      strings.addAddFreeSpace(0x2000 - freeArea1Size, freeArea1Size - 0x180);
    }
    else {
      strings.addAddFreeSpace(0x2000 - freeArea1Size, freeArea1Size);
    }
  else {
    cerr << "no area free space 1!" << endl;
  }
  
  if (freeArea2Size > 0)
    strings.addAddFreeSpace(0x3000 - freeArea2Size, freeArea2Size);
  else {
    cerr << "no area free space 2!" << endl;
  }
  
  if (freeArea3Size > 0)
    // HACK: we need some extra free space for new code and data
    // in the cafe menu, so exclude part of the end of the bank
    if ((sectorNum == 0x3202)) {
      strings.addAddFreeSpace(0x4000 - freeArea3Size, freeArea3Size - 0x280);
    }
    // art gallery
    else if ((sectorNum == 0x356)) {
      strings.addAddFreeSpace(0x4000 - freeArea3Size, freeArea3Size - 0x600);
    }
    else {
      strings.addAddFreeSpace(0x4000 - freeArea3Size, freeArea3Size);
    }
  else {
    cerr << "no area free space 3!" << endl;
  }
  
  // HACKs for areas where needed
  if ((sectorNum == 0x1EBE)) {
    // first segment of case 2b, which is unusually full.
    // the translation actually just barely fit until i decided
    // to change "youth" to "young man".
    
    // unused text
//    strings.addAddFreeSpace(0x7900, 0x75);
    // end-of-bank space
    strings.addAddFreeSpace(0xFC00, 0x400);
  }
  
  // search for and add marker for the menu column layout table.
  // the original game's layouts have to accommodate some unevenness
  // caused by misalignment between the 8x8 pattern grid and the
  // the text's immutable 14-pixel monospacing, but we can align
  // text however we want, so these layouts can be made uniform.
  //
  // for whatever reason, the block containing the raft puzzle
  // and forest minigames for case 2b either doesn't have this table
  // or has a different version, so exclude it
  if ((sectorNum != 0x1F7E)) {
    /*  ; 1-column menu:
        ; left column highlight starts at pattern 0x0
        ; right column highlight starts at pattern 0x1C (end of box)
        00 1C 00 00 00 00 00 00
        ; 2-column menu:
        ; left column highlight starts at pattern 0x0
        ; middle column highlight starts at pattern 0xE
        ; right column highlight starts at pattern 0x1C (end of box)
        00 0E 1C 00 00 00 00 00
        00 08 11 1C 00 00 00 00
        00 07 0E 15 1C 00 00 00
        00 05 0B 10 17 1C 00 00
    */
    int menuColLayoutTable_raw
      = TStringSearch::searchFullStreamForUnique(areaOfs,
          std::string(
            "00 1C 00 00 00 00 00 00 "
            "00 0E 1C 00 00 00 00 00 "
            "00 08 11 1C 00 00 00 00 "
            "00 07 0E 15 1C 00 00 00 "
            "00 05 0B 10 17 1C 00 00"
          )
        ).offset;
    strings.addSetRegionProperty("menuColLayoutTable_raw",
      TStringConversion::intToString(menuColLayoutTable_raw,
        TStringConversion::baseHex));
  }
  
  int newStringsStart = strings.strings.size();
  
  areaOfs.seek(0);
  dumpAreaBlock(areaOfs, strings,
                std::string("area-")
                  + TStringConversion::intToString(sectorNum,
                      TStringConversion::baseHex));
  
  std::string outputFileName
    = std::string("base/area/") + regionName + ".bin";
  TFileManip::createDirectoryForFile(outputFileName);
  areaOfs.save(outputFileName.c_str());
  
/*  // TEST
  for (int j = newStringsStart; j < strings.strings.size(); j++) {
    const PidolGenericString& it = strings.strings[j];
    if ((it.type == PidolGenericString::type_string)
        && (it.size > 0)) {
      areaOfs.seek(it.offset);
      int sz = it.size;
      for (int i = 0; i < sz; i++) {
        areaOfs.put(0xFF);
      }
    }
  }
  
  std::string outputFileNameBlanked
    = std::string("baseblanked/area/") + regionName + ".bin";
  TFileManip::createDirectoryForFile(outputFileNameBlanked);
  areaOfs.save(outputFileNameBlanked.c_str());*/
}

void dumpIsoAdvBlockStd(TStream& ifs, int sectorNum,
                     PidolGenericStringSet& strings) {
  std::cout << "dumping adv block at " << std::hex << sectorNum << std::endl;
  
  strings.addComment(
               string("ADV block ")
                + TStringConversion::intToString(sectorNum,
                    TStringConversion::baseHex));
  
  std::string regionName = std::string("adv-")
    + TStringConversion::intToString(sectorNum,
        TStringConversion::baseHex);
  strings.addSetRegion(regionName);
  strings.addGenericLine("#SETREGIONTYPE(\"adv\")");
  strings.addSetRegionProperty("originSector",
    TStringConversion::intToString(sectorNum,
      TStringConversion::baseHex));
  
  int blockBaseAddr = (sectorNum * sectorSize);
  ifs.seek(blockBaseAddr);
  TBufStream advOfs;
  advOfs.writeFrom(ifs, advBlockSize);
  
  // TODO: depending on scene, it seems there may be additional
  // space available beyond the 0x2000 area.
  // see adv-0xBC6, for instance, which follows a similar pattern
  // with the 0x3000 and 0x4000 ranges as the normal "area" blocks.
  // this doesn't seem to be the case consistently; not sure what
  // the distinction is (even other ADVs with text, such as 0xD86,
  // may not have these additional areas free).
  // these may just have to be handled manually if they become necessary.
  int freeArea1Size = countSafeBackwardsRepeats(advOfs, 0x2000, 0xFF);
  
  if (freeArea1Size > 0)
    if (isHybridAdvScene(sectorNum)) {
      // HACK: for sequences which have both subtitled audio
      // and text, reserve the first X bytes for text
      // and the rest for adv content
      strings.addAddFreeSpace((0x2000 - freeArea1Size),
                              hybridAdvSceneReservedTextSize);
    }
    else if ((sectorNum == 0xBC6)) {
      // HACK: reserved for new sprite states for title card
    }
    else if ((sectorNum == 0x1FBE)) {
      // HACK: reserve space at end for map graphic loading hacks
      strings.addAddFreeSpace((0x2000 - freeArea1Size),
                              (freeArea1Size - 0x100));
    }
    else if ((sectorNum == 0x207E)) {
      // HACK: this scene happens to contains 4 sprites consisting
      // entirely of 0xFF, used to crop out the top part of a vertically
      // scrolling scene, right at the end of its used area, causing them
      // to be misdetected as empty space
      strings.addAddFreeSpace((0x2000 - freeArea1Size + 0x200),
                              (freeArea1Size - 0x200));
    }
    else {
      strings.addAddFreeSpace(0x2000 - freeArea1Size, freeArea1Size);
    }
  else {
    cerr << "no adv free space 1!" << endl;
  }
  
  // HACKs for advs where needed
  if ((sectorNum == 0xBC6)) {
    strings.addAddFreeSpace(0xE200, 0x600);
  }
  
  int newStringsStart = strings.strings.size();
  
  advOfs.seek(0);
  dumpAdvBlock(advOfs, strings,
                std::string("adv-")
                  + TStringConversion::intToString(sectorNum,
                      TStringConversion::baseHex));
  
  std::string outputFileName
    = std::string("base/adv/") + regionName + ".bin";
  TFileManip::createDirectoryForFile(outputFileName);
  advOfs.save(outputFileName.c_str());
  
/*  // TEST
  for (int j = newStringsStart; j < strings.strings.size(); j++) {
    const PidolGenericString& it = strings.strings[j];
    if ((it.type == PidolGenericString::type_string)
        && (it.size > 0)) {
      advOfs.seek(it.offset);
      int sz = it.size;
      for (int i = 0; i < sz; i++) {
        advOfs.put(0xFF);
      }
    }
  }
  
  std::string outputFileNameBlanked
    = std::string("baseblanked/adv/") + regionName + ".bin";
  TFileManip::createDirectoryForFile(outputFileNameBlanked);
  advOfs.save(outputFileNameBlanked.c_str());*/
}

void dumpIsoAdvBlockScene(TStream& ifs, int sectorNum,
                     PidolGenericStringSet& strings) {
  std::cout << "dumping adv scene block at "
    << std::hex << sectorNum << std::endl;
  
  strings.addComment(
               string("ADV scene block ")
                + TStringConversion::intToString(sectorNum,
                    TStringConversion::baseHex));
  
  std::string regionName = std::string("advscene-")
    + TStringConversion::intToString(sectorNum,
        TStringConversion::baseHex);
  strings.addSetRegion(regionName);
//  strings.addGenericLine("#SETREGIONTYPE(\"adv\")");
  strings.addSetRegionProperty("originSector",
    TStringConversion::intToString(sectorNum,
      TStringConversion::baseHex));
  strings.addSetRegionProperty("stringsAreSceneFormat",
    TStringConversion::intToString(1,
      TStringConversion::baseHex));
  
  int blockBaseAddr = (sectorNum * sectorSize);
  ifs.seek(blockBaseAddr);
  TBufStream advOfs;
  advOfs.writeFrom(ifs, advBlockSize);
  
  int freeArea1Size = countSafeBackwardsRepeats(advOfs, 0x2000, 0xFF);
  
  if (freeArea1Size > 0)
    if (isHybridAdvScene(sectorNum)) {
      // HACK: for sequences which have both subtitled audio
      // and text, reserve the first 0x100 bytes for text
      // and the rest for adv content
      strings.addAddFreeSpace((0x2000 - freeArea1Size) + hybridAdvSceneReservedTextSize,
                              freeArea1Size - hybridAdvSceneReservedTextSize);
    }
    else {
      strings.addAddFreeSpace(0x2000 - freeArea1Size, freeArea1Size);
    }
  else {
    cerr << "no adv scene free space 1!" << endl;
  }
  
  // HACKs where needed
//  if ((sectorNum == 0xBC6)) {
//    strings.addAddFreeSpace(0xE200, 0x600);
//  }
  
//  advOfs.seek(0);
//  dumpAdvBlock(advOfs, strings,
//                std::string("adv-")
//                  + TStringConversion::intToString(sectorNum,
//                      TStringConversion::baseHex));
  
  // add string placeholders
  for (int i = 0; i < 100; i++) {
    PidolGenericString result;
    
    result.type = PidolGenericString::type_string;
    result.offset = 0;
    result.size = 0;
    result.mayNotExist = true;
    result.idOverride = std::string("advscene-")
      + TStringConversion::intToString(sectorNum,
          TStringConversion::baseHex)
      + "-"
      + TStringConversion::intToString(i,
          TStringConversion::baseDec);
    strings.strings.push_back(result);
  }
  
  std::string outputFileName
    = std::string("base/advscene/") + regionName + ".bin";
  TFileManip::createDirectoryForFile(outputFileName);
  advOfs.save(outputFileName.c_str());
}

void dumpIsoVisualBlock(TStream& ifs, int sectorNum,
                     PidolGenericStringSet& strings) {
  std::cout << "dumping visual scene block at "
    << std::hex << sectorNum << std::endl;
  
  strings.addComment(
               string("visual scene block ")
                + TStringConversion::intToString(sectorNum,
                    TStringConversion::baseHex));
  
  std::string regionName = std::string("visual-")
    + TStringConversion::intToString(sectorNum,
        TStringConversion::baseHex);
  strings.addSetRegion(regionName);
//  strings.addGenericLine("#SETREGIONTYPE(\"adv\")");
  strings.addSetRegionProperty("originSector",
    TStringConversion::intToString(sectorNum,
      TStringConversion::baseHex));
  strings.addSetRegionProperty("stringsAreSceneFormat",
    TStringConversion::intToString(1,
      TStringConversion::baseHex));
  
  int blockBaseAddr = (sectorNum * sectorSize);
  ifs.seek(blockBaseAddr);
  TBufStream advOfs;
  advOfs.writeFrom(ifs, visualBlockSize);
  
  // HACK: ignore scenes that will not be subtitled (voice actor interviews)
  if ((sectorNum != 0x554E)
      && (sectorNum != 0x55CE)) {
    
    // HACK: credits have free space in different area
    // ...except actually they don't. oh well
    if (sectorNum != 0x54CE) {
      int freeArea1Size = countSafeBackwardsRepeats(advOfs, 0x6000, 0xFF);
      if (freeArea1Size > 0)
        strings.addAddFreeSpace(0x6000 - freeArea1Size, freeArea1Size);
      else {
        cerr << "no visual scene free space 1!" << endl;
      }
    }
    else if (sectorNum == 0x54CE) {
      int freeArea1Size = countSafeBackwardsRepeats(advOfs, 0x6000, 0xFF);
      if (freeArea1Size > 0)
        strings.addAddFreeSpace(0x6000 - freeArea1Size, freeArea1Size);
      else {
        cerr << "no visual scene free space 1!" << endl;
      }
    }
    
    if (sectorNum != 0x54CE) {
      /*007384  9C 24 33             stz $3324
007387  A9 03                lda #$03
007389  18                   clc 
00738A  6D F5 FF             adc $FFF5
00738D  38                   sec 
00738E  E9 18                sbc #$18
007390  53 20                tam #$20
007392  A9 CF                lda #$CF
007394  85 14                sta $0014
007396  A9 2A                lda #$2A
007398  85 15                sta $0015
00739A  A2 05                ldx #$05*/
      int genSpriteTable_raw
        = TStringSearch::searchFullStreamForUnique(advOfs,
            std::string(
              "9C 24 33 "
              "A9 03 "
              "18 "
              "6D F5 FF "
              "38 "
              "E9 18 "
              "53 20 "
              "A9 CF "
              "85 14 "
              "A9 2A "
              "85 15 "
              "A2 05"
            )
          ).offset;
      strings.addSetRegionProperty("genSpriteTable_raw",
        TStringConversion::intToString(genSpriteTable_raw,
          TStringConversion::baseHex));
      
      advOfs.seek(genSpriteTable_raw + (0x73BB - 0x7384));
      int currentSpriteCount_ptr = advOfs.readu16le();
      strings.addSetRegionProperty("currentSpriteCount_ptr",
        TStringConversion::intToString(currentSpriteCount_ptr,
          TStringConversion::baseHex));
//      std::cerr << "currentSpriteCount_ptr: " << hex << currentSpriteCount_ptr
//        << endl;
      
      /*
  006EA7  A0 01                ldy #$01
  006EA9  B1 12                lda ($0012),Y
  006EAB  85 F8                sta $00F8
  006EAD  C8                   iny 
  006EAE  B1 12                lda ($0012),Y
  006EB0  85 FC                sta $00FC
  006EB2  C8                   iny 
  006EB3  B1 12                lda ($0012),Y
  006EB5  85 FF                sta $00FF
  006EB7  A9 80                lda #$80
  006EB9  85 FB                sta $00FB
  006EBB  20 12 E0             jsr CD_PLAY [$E012]*/
      int playCdTrack_raw
        = TStringSearch::searchFullStreamForUnique(advOfs,
            std::string(
              "A0 01 "
              "B1 12 "
              "85 F8 "
              "C8 "
              "B1 12 "
              "85 FC "
              "C8 "
              "B1 12 "
              "85 FF "
              "A9 80 "
              "85 FB "
              "20 12 E0"
            )
          ).offset;
      strings.addSetRegionProperty("playCdTrack_raw",
        TStringConversion::intToString(playCdTrack_raw,
          TStringConversion::baseHex));
      
      /*
      006EDB  A0 01                ldy #$01
      006EDD  B1 12                lda ($0012),Y
      006EDF  85 FC                sta $00FC
      006EE1  C8                   iny 
      006EE2  B1 12                lda ($0012),Y
      006EE4  85 FE                sta $00FE
      006EE6  C8                   iny 
      006EE7  B1 12                lda ($0012),Y
      006EE9  85 FD                sta $00FD
      006EEB  C8                   iny 
      006EEC  B1 12                lda ($0012),Y
      006EEE  85 F8                sta $00F8
      006EF0  C8                   iny 
      006EF1  B1 12                lda ($0012),Y
      006EF3  85 F9                sta $00F9
      006EF5  64 FA                stz $00FA
      006EF7  A9 0E                lda #$0E
      006EF9  85 FF                sta $00FF
      006EFB  20 3F E0             jsr AD_CPLAY [$E03F]*/
      int cplayAdpcm_raw
        = TStringSearch::searchFullStreamForUnique(advOfs,
            std::string(
              "B1 12 "
              "85 F9 "
              "64 FA "
              "A9 0E "
              "85 FF "
              "20 3F E0"
            )
          ).offset - 0x16;
      strings.addSetRegionProperty("cplayAdpcm_raw",
        TStringConversion::intToString(cplayAdpcm_raw,
          TStringConversion::baseHex));
      
      /*
      0071FA  A0 01                ldy #$01
      0071FC  B1 12                lda ($0012),Y
      0071FE  8D 92 31             sta sceneTimerLo [$3192]
      007201  C8                   iny 
      007202  B1 12                lda ($0012),Y
      007204  8D 93 31             sta sceneTimerHi [$3193]*/
      int setSceneTimer_raw
        = TStringSearch::searchFullStreamForUnique(advOfs,
            std::string(
              "A0 01 "
              "B1 12 "
              "8D 92 31 "
              "C8 "
              "B1 12 "
              "8D 93 31"
            )
          ).offset;
      strings.addSetRegionProperty("setSceneTimer_raw",
        TStringConversion::intToString(setSceneTimer_raw,
          TStringConversion::baseHex));
    
/*    006F97  A0 01                ldy #$01
      006F99  B1 12                lda ($0012),Y
      006F9B  A0 08                ldy #$08
      006F9D  91 10                sta ($0010),Y
      006F9F  38                   sec 
      006FA0  ED 92 31             sbc sceneTimerLo [$3192]
      006FA3  A0 06                ldy #$06
      006FA5  91 10                sta ($0010),Y*/
      int doObjTimerSet1_raw
        = TStringSearch::searchFullStreamForUnique(advOfs,
            std::string(
              "A0 01 "
              "B1 12 "
              "A0 08 "
              "91 10 "
              "38 "
              "ED 92 31 "
              "A0 06 "
              "91 10"
            )
          ).offset;
      strings.addSetRegionProperty("doObjTimerSet1_raw",
        TStringConversion::intToString(doObjTimerSet1_raw,
          TStringConversion::baseHex));
    
/*    007150  A0 01                ldy #$01
      007152  B1 12                lda ($0012),Y
      007154  85 18                sta $0018
      007156  C8                   iny 
      007157  B1 12                lda ($0012),Y
      007159  85 19                sta $0019
      00715B  A0 08                ldy #$08
      00715D  A5 18                lda $0018
      00715F  18                   clc 
      007160  71 10                adc ($0010),Y
      007162  85 18                sta $0018
      007164  C8                   iny 
      007165  B1 10                lda ($0010),Y
      007167  65 19                adc $0019
      007169  85 19                sta $0019
      00716B  A0 06                ldy #$06
      00716D  A5 18                lda $0018
      00716F  38                   sec 
      007170  ED 92 31             sbc sceneTimerLo [$3192]*/
      int doObjTimerSet2_raw
        = TStringSearch::searchFullStreamForUnique(advOfs,
            std::string(
              "A0 01 "
              "B1 12 "
              "85 18 "
              "C8 "
              "B1 12 "
              "85 19 "
              "A0 08 "
              "A5 18 "
              "18 "
              "71 10 "
              "85 18 "
              "C8 "
              "B1 10 "
              "65 19 "
              "85 19 "
              "A0 06 "
              "A5 18 "
              "38 "
              "ED 92 31"
            )
          ).offset;
      strings.addSetRegionProperty("doObjTimerSet2_raw",
        TStringConversion::intToString(doObjTimerSet2_raw,
          TStringConversion::baseHex));
    
/*    00657E  64 28                stz $0028
      006580  A0 01                ldy #$01
      006582  B1 12                lda ($0012),Y
      006584  85 18                sta $0018
      006586  A5 18                lda $0018
      006588  18                   clc 
      006589  6D F5 FF             adc $FFF5
      00658C  38                   sec 
      00658D  E9 18                sbc #$18
      00658F  53 20                tam #$20
      006591  1A                   inc 
      006592  53 40                tam #$40
      006594  A9 05                lda #$05
      006596  85 6A                sta $006A
      006598  8D 00 00             sta $0000*/
      int sceneVramCopy_raw
        = TStringSearch::searchFullStreamForUnique(advOfs,
            std::string(
              "64 28 "
              "A0 01 "
              "B1 12 "
              "85 18 "
              "A5 18 "
              "18 "
              "6D F5 FF "
              "38 "
              "E9 18 "
              "53 20 "
              "1A "
              "53 40 "
              "A9 05 "
              "85 6A "
              "8D 00 00"
            )
          ).offset;
      strings.addSetRegionProperty("sceneVramCopy_raw",
        TStringConversion::intToString(sceneVramCopy_raw,
          TStringConversion::baseHex));
    
/*    0066EB  A0 01                ldy #$01
      0066ED  B1 12                lda ($0012),Y
      0066EF  85 22                sta $0022
      0066F1  C8                   iny 
      0066F2  B1 12                lda ($0012),Y
      0066F4  85 20                sta $0020
      0066F6  C8                   iny 
      0066F7  B1 12                lda ($0012),Y
      0066F9  4A                   lsr 
      0066FA  4A                   lsr 
      0066FB  4A                   lsr 
      0066FC  4A                   lsr 
      0066FD  4A                   lsr 
      0066FE  18                   clc 
      0066FF  65 22                adc $0022
      006701  85 22                sta $0022*/
      int sceneTilemapCopy_raw
        = TStringSearch::searchFullStreamForUnique(advOfs,
            std::string(
              "A0 01 "
              "B1 12 "
              "85 22 "
              "C8 "
              "B1 12 "
              "85 20 "
              "C8 "
              "B1 12 "
              "4A "
              "4A "
              "4A "
              "4A "
              "4A "
              "18 "
              "65 22 "
              "85 22"
            )
          ).offset;
      strings.addSetRegionProperty("sceneTilemapCopy_raw",
        TStringConversion::intToString(sceneTilemapCopy_raw,
          TStringConversion::baseHex));
    
/*    006A5F  C9 12                cmp #$12
      006A61  D0 47                bne [$6AAA]
      006A63  DA                   phx 
      006A64  A2 02                ldx #$02
      006A66  A0 05                ldy #$05
      006A68  B1 12                lda ($0012),Y*/
      int fadeSetupCmd_raw
        = TStringSearch::searchFullStreamForUnique(advOfs,
            std::string(
              "C9 12 "
              "D0 47 "
              "DA "
              "A2 02 "
              "A0 05 "
              "B1 12"
            )
          ).offset;
      advOfs.seek(fadeSetupCmd_raw + 12);
      int fadeArrayBase = advOfs.readu16le();
      strings.addSetRegionProperty("fadeArrayBase",
        TStringConversion::intToString(fadeArrayBase,
          TStringConversion::baseHex));
      strings.addSetRegionProperty("fadeOn",
        TStringConversion::intToString(fadeArrayBase+0x2,
          TStringConversion::baseHex));
      strings.addSetRegionProperty("fadeBgBase",
        TStringConversion::intToString(fadeArrayBase+0xF,
          TStringConversion::baseHex));
      strings.addSetRegionProperty("fadeSpriteBase",
        TStringConversion::intToString(fadeArrayBase+0x11,
          TStringConversion::baseHex));
    
/*    004CF2  A5 10                lda $0010
      004CF4  48                   pha 
      004CF5  64 10                stz $0010
      004CF7  08                   php 
      004CF8  78                   sei 
      004CF9  5A                   phy 
      004CFA  C2                   cly */
      int readControllers_raw
        = TStringSearch::searchFullStreamForUnique(advOfs,
            std::string(
              "A5 10 "
              "48 "
              "64 10 "
              "08 "
              "78 "
              "5A "
              "C2"
            )
          ).offset;
      strings.addSetRegionProperty("readControllers_raw",
        TStringConversion::intToString(readControllers_raw,
          TStringConversion::baseHex));
    }
    
    // HACKs where needed
  //  if ((sectorNum == 0xBC6)) {
  //    strings.addAddFreeSpace(0xE200, 0x600);
  //  }
    
  //  advOfs.seek(0);
  //  dumpAdvBlock(advOfs, strings,
  //                std::string("adv-")
  //                  + TStringConversion::intToString(sectorNum,
  //                      TStringConversion::baseHex));
    
    // add string placeholders
    for (int i = 0; i < 100; i++) {
      PidolGenericString result;
      
      result.type = PidolGenericString::type_string;
      result.offset = 0;
      result.size = 0;
      result.mayNotExist = true;
      result.idOverride = std::string("visual-")
        + TStringConversion::intToString(sectorNum,
            TStringConversion::baseHex)
        + "-"
        + TStringConversion::intToString(i,
            TStringConversion::baseDec);
      strings.strings.push_back(result);
    }
  }
  
  std::string outputFileName
    = std::string("base/visual/") + regionName + ".bin";
  TFileManip::createDirectoryForFile(outputFileName);
  advOfs.save(outputFileName.c_str());
}

// starting sector nums of audio-only adv scenes
int advSceneSectors[] = {
  0xB86,
  0xCC6,
  0xD06,
  0xDC6,
  0xE06,
  0xE46,
  0x138E,
  0x1FFE,
  0x20FE,
  0x227E,
  
  // case 2b getaway game over -- this has both dialogue and text
  0x22FE,
  
  0x233E,
  
  // case 3 newspaper clippings -- need subtitles for papers
  0x3542,
  
  0x3602,
  0x3802,
  0x3842,
  0x3882,
  0x3902,
  
  //  karaoke
  0x3982
};
int numAdvSceneSectors = sizeof(advSceneSectors) / sizeof(int);

void dumpIsoAdvBlock(TStream& ifs, int sectorNum,
                     PidolGenericStringSet& strings,
                     PidolGenericStringSet& advSceneStrings) {
  // TEST
//  return;
  // if this sector is on our hardcoded list of "scene" advs
  // (i.e. audio-only cutscenes that need subtitling),
  // dump appropriately.
  // otherwise, use default text-adv dumping.
  for (int i = 0; i < numAdvSceneSectors; i++) {
    if (sectorNum == advSceneSectors[i]) {
      dumpIsoAdvBlockScene(ifs, sectorNum, advSceneStrings);
      // HACK: some small number of scenes have both dialogue and text,
      // so don't return here for those
      if (!isHybridAdvScene(sectorNum)) {
        return;
      }
    }
  }
  
  dumpIsoAdvBlockStd(ifs, sectorNum, strings);
}

PidolGenericString dumpCreditsString(TStream& ifs,
    std::string baseIdName) {
  PidolGenericString result;
  result.type = PidolGenericString::type_string;
  result.offset = ifs.tell();
  result.idOverride = baseIdName
    + "_"
    + TStringConversion::intToString(result.offset,
        TStringConversion::baseHex);
  
  while (!ifs.eof()) {
    unsigned char next = ifs.peek();
    if (next == 0x00) {
      ifs.get();
      break;
    }
    
    TThingyTable::MatchResult tblresult = tableCredits.matchId(ifs);
    if (tblresult.id == -1) {
      throw TGenericException(T_SRCANDLINE,
                              "dumpCreditsString()",
                              "bad credits string id");
    }
    
    result.content += tableCredits.getEntry(tblresult.id);
    
    if ((next == 0x0B)
           || (next == 0x0E)) {
      // 1 arg
      result.content += as2bHexLiteral(ifs.readu8());
    }
    else if ((next == 0x0D)
           || (next == 0xFA)) {
      // no args
      
    }
    else if (next < 0x20) {
      // shouldn't happen
      
    }
    else {
      // literal
      
    }
  }
  
  result.size = ifs.tell() - result.offset;
  
  return result;
}

void dumpCreditsText(TStream& ifs,
                     PidolGenericStringSet& strings) {
  TBufStream scriptIfs;
  ifs.seek(0xE000);
  scriptIfs.writeFrom(ifs, 0x2000);
  
//  scriptIfs.save("test.bin");
  
  ifs.seek(0x4634);
  for (int i = 0; i < 214; i++) {
    int offset = ifs.tell();
    int refTarget = offset + 0x6000;
    
    PidolGenericString str = dumpCreditsString(ifs, "credits_text");
    
    int endOffset = ifs.tell();
    
    // look up script refs
    std::string searchStr = "0C ";
    searchStr += as2bHex(refTarget & 0xFF);
    searchStr += " ";
    searchStr += as2bHex((refTarget >> 8) & 0xFF);
    
//    std::cerr << searchStr << std::endl;
    
    TStringSearchResultList refsFound
      = TStringSearch::searchFullStream(scriptIfs, searchStr);
    for (auto ref: refsFound) {
//      std::cerr << ref.offset << std::endl;
      str.pointerRefs.push_back(ref.offset + 1);
    }
    
    strings.strings.push_back(str);
    ifs.seek(endOffset);
  }
}

PidolGenericString dumpBackUtilString(TStream& ifs,
    std::string baseIdName) {
  PidolGenericString result;
  result.type = PidolGenericString::type_string;
  result.offset = ifs.tell();
  result.idOverride = baseIdName
    + "_"
    + TStringConversion::intToString(result.offset,
        TStringConversion::baseHex);
  
/*  result.addPropSet("origOffset",
    TStringConversion::intToString(ifs.tell(),
      TStringConversion::baseHex));
  result.prefixBase += "\r\n";*/
  
  bool first = true;
  while (!ifs.eof()) {
    unsigned char next = ifs.peek();
    if (next == 0x00) {
      ifs.get();
      break;
    }
    
    bool is0A = (ifs.peek() == 0x0A);
    
    TThingyTable::MatchResult tblresult = tableBackUtil.matchId(ifs);
    if (tblresult.id == -1) {
      throw TGenericException(T_SRCANDLINE,
                              "dumpBackUtilString()",
                              string("bad backutil string id ")
                              + TStringConversion::intToString(
                                  (unsigned char)ifs.get(),
                                  TStringConversion::baseHex)
                              + " at "
                              + TStringConversion::intToString(
                                  ifs.tell(),
                                  TStringConversion::baseHex)
                                  );
    }
    
    if (first && is0A) {
      // initial color goes to prefix column
      // (almost every string starts with this command)
      
      result.prefixBase += tableBackUtil.getEntry(tblresult.id);
      result.prefixBase += as2bHexLiteral(ifs.readu8());
      result.prefixBase += as2bHexLiteral(ifs.readu8());
      
      first = false;
      continue;
    }
    
    result.content += tableBackUtil.getEntry(tblresult.id);
    
    if ((next == 0x0A)) {
      // 2 args
      result.content += as2bHexLiteral(ifs.readu8());
      result.content += as2bHexLiteral(ifs.readu8());
    }
    else if ((next == 0x0B)) {
      // 1 arg
      result.content += as2bHexLiteral(ifs.readu8());
    }
    else if ((next == 0x0C)) {
      // no args
      
    }
    else if (next < 0x20) {
      // shouldn't happen
      
    }
    else {
      // literal
      
    }
    
    first = false;
  }
  
  result.size = ifs.tell() - result.offset;
  
  return result;
}

void dumpBackUtilText(TStream& ifs,
                     PidolGenericStringSet& strings) {
//  TBufStream scriptIfs;
//  ifs.seek(0x5000);
//  scriptIfs.writeFrom(ifs, 0x1000);
  
//  scriptIfs.save("test.bin");
  
  ifs.seek(0x5000);
  for (int i = 0; i < 57; i++) {
//    int offset = ifs.tell();
//    int refTarget = offset + 0x6000;
    
//    std::cerr << "offset: " << std::hex << offset << std::endl;
    PidolGenericString str = dumpBackUtilString(ifs, "backutil");
    
    int endOffset = ifs.tell();
    
/*    // look up script refs
    std::string searchStr = "0C ";
    searchStr += as2bHex(refTarget & 0xFF);
    searchStr += " ";
    searchStr += as2bHex((refTarget >> 8) & 0xFF);
    
//    std::cerr << searchStr << std::endl;
    
    TStringSearchResultList refsFound
      = TStringSearch::searchFullStream(scriptIfs, searchStr);
    for (auto ref: refsFound) {
//      std::cerr << ref.offset << std::endl;
      str.pointerRefs.push_back(ref.offset + 1);
    }*/
    
    strings.strings.push_back(str);
    ifs.seek(endOffset);
  }
}

int main(int argc, char* argv[]) {
  if (argc < 1) {
    cout << "Private Eye Dol script generator" << endl;
//    cout << "Usage: " << argv[0] << " <outprefix>" << endl;
    cout << "Usage: " << argv[0] << endl;
    
    return 1;
  }
  
//  string outprefixName(argv[1]);

  TFileManip::createDirectory("script/orig");
  
  tableRaw.readSjis("table/pidol_raw.tbl");
  tableText.readSjis("table/pidol_text.tbl");
  tableCredits.readSjis("table/pidol_credits.tbl");
  tableBackUtil.readSjis("table/pidol_backutil.tbl");
  
  TBufStream ifs;
  ifs.open("pidol_02.iso");
  
  //========================================================================
  // main
  //========================================================================
  
  {
    PidolGenericStringSet strings;
    strings.addGenericLine("#SETSIZE(224, 4)");
    strings.addGenericLine("#SETFAILONBOXOVERFLOW(1)");
    
    PidolGenericStringSet advSceneStrings;
    advSceneStrings.addGenericLine("#SETSIZE(224, 4)");
    advSceneStrings.addGenericLine("#SETFAILONBOXOVERFLOW(1)");
    
    PidolGenericStringSet visualSceneStrings;
    visualSceneStrings.addGenericLine("#SETSIZE(224, 4)");
    visualSceneStrings.addGenericLine("#SETFAILONBOXOVERFLOW(1)");
    
    PidolGenericStringSet miscStrings;
    miscStrings.addGenericLine("#SETSIZE(224, 4)");
    miscStrings.addGenericLine("#SETFAILONBOXOVERFLOW(1)");
    
    PidolGenericStringSet miscStrings8x8;
//    miscStrings8x8.addGenericLine("#SETSIZE(256, -1)");
//    miscStrings8x8.addGenericLine("#SETFAILONBOXOVERFLOW(0)");
    
    PidolGenericStringSet creditsStrings;
    creditsStrings.addGenericLine("#SETSIZE(192, 4)");
    creditsStrings.addGenericLine("#SETFAILONBOXOVERFLOW(1)");
    
    PidolGenericStringSet creditsTextStrings;
//    creditsStrings.addGenericLine("#SETSIZE(256, 4)");
//    creditsStrings.addGenericLine("#SETFAILONBOXOVERFLOW(1)");
    
    PidolGenericStringSet backUtilStrings;
    
    //=======================================
    // case data
    //=======================================
    
//    for (int i = 0; i < numTextBlocks; i++) {
//      dumpTextBlock(ifs, strings, i);
//    }
    
    //=====
    // case 1 areas
    //=====
    
    for (int i = 0; i < 4; i++) {
      dumpIsoAreaBlock(ifs, 0x2D6 + (0x20 * i), strings);
    }
    
    //=====
    // case 1 advs
    //=====
    
    // note that 0xF06 is actually the game over for the case 2b end qte,
    // while 10C6 is the game over for the case 1 end qte.
    // everything else here seems to be for case 1.
    
//    for (int i = 0; i < 21; i++) {
    for (int i = 0; i < 22; i++) {
//      dumpIsoAdvBlock(ifs, 0xBC6 + (0x40 * i), strings,
      dumpIsoAdvBlock(ifs, 0xB86 + (0x40 * i), strings,
                      advSceneStrings);
    }
    
    //=====
    // case 2a areas
    //=====
    
    for (int i = 0; i < 2; i++) {
      dumpIsoAreaBlock(ifs, 0x130E + (0x20 * i), strings);
    }
    
    //=====
    // case 2a advs
    //=====
    
    for (int i = 0; i < 4; i++) {
//      dumpIsoAdvBlock(ifs, 0x13CE + (0x40 * i), strings);
      dumpIsoAdvBlock(ifs, 0x134E + (0x40 * i), strings,
                      advSceneStrings);
    }
    
    //=====
    // case 2b areas
    //=====
    
    // NOTE: there's one additional area at the end for the karaoke menu room;
    // this is dumped separately
    for (int i = 0; i < 7; i++) {
      dumpIsoAreaBlock(ifs, 0x1EBE + (0x20 * i), strings);
    }
    
    //=====
    // case 2b advs
    //=====
    
    for (int i = 0; i < 15; i++) {
      dumpIsoAdvBlock(ifs, 0x1FBE + (0x40 * i), strings,
                      advSceneStrings);
    }
    
    // for arcade card loading screen?
//    for (int i = 0; i < 1; i++) {
//      dumpIsoAdvBlock(ifs, 0x3902 + (0x40 * i), strings);
//    }
    
    // save prompt -- shared with other episodes
    dumpIsoAdvBlock(ifs, 0x237E, strings,
                    advSceneStrings);
    
    //=====
    // case 3 areas
    //=====
    
    for (int i = 0; i < 5; i++) {
      dumpIsoAreaBlock(ifs, 0x31C2 + (0x20 * i), strings);
    }
    
    //=====
    // case 3 advs
    //=====
    
//    for (int i = -32; i < 2; i++) {
    
    // ???
    // i originally added this by accident not realizing it was part of
    // the block that included the arcade card loading screen,
    // but it seems to have some valid, unique content...
    for (int i = 0; i < 26; i++) {
      dumpIsoAdvBlock(ifs, 0x3302 + (0x40 * i), strings,
                      advSceneStrings);
    }
    
    //=====
    // art gallery
    // (seems to actually be organized as part of the block of
    // case 1 maps)
    //=====
    
    for (int i = 0; i < 1; i++) {
      dumpIsoAreaBlock(ifs, 0x356 + (0x20 * i), strings);
    }
    
    //=====
    // karaoke mode
    //=====
    
    // probably irrelevant
//    for (int i = 0; i < 1; i++) {
//      dumpIsoAreaBlock(ifs, 0x1C36 + (0x20 * i), strings);
//      dumpIsoAreaBlock(ifs, 0x1C9E + (0x20 * i), strings);
//      dumpIsoAreaBlock(ifs, 0x1CB6 + (0x20 * i), strings);
//    }

    // song select menu (+debug options)
    // TODO: size may not be standard 0x20 sectors like normal maps
    for (int i = 0; i < 1; i++) {
      dumpIsoAreaBlock(ifs, 0x1F9E + (0x20 * i), strings);
    }
    
    // song content
    for (int i = 0; i < 1; i++) {
      dumpIsoAdvBlock(ifs, 0x3982 + (0x20 * i), strings,
                      advSceneStrings);
    }
    
    // the remainder of this looks like unused or debug stuff.
    // it's not useful to me, so i probably won't bother with it.
    
/*    //=====
    // ? case 2a area 0 dupe?
    // immediately precedes the sound test maps, which load in
    // the ship map, so perhaps they copy-pasted it to make those
    // maps
    //=====
    
    for (int i = 0; i < 1; i++) {
      dumpIsoAreaBlock(ifs, 0x3262 + (0x20 * i), strings);
    }
    
    //=====
    // sound debug rooms, one per case
    // the first of these is the nominal location
    // of the bonus feature select menu accessed by holding
    // button 1 as the game boots, then holding select+right
    // and starting a new game.
    // but that seems to bypass the actual room logic.
    //=====
    
    for (int i = 0; i < 4; i++) {
      dumpIsoAreaBlock(ifs, 0x3282 + (0x20 * i), strings);
    }*/
  
    //========================================================================
    // out-of-engine cutscenes
    //========================================================================
    
    // TODO
    for (int i = 0; i < 0x18; i++) {
      int targetSector = 0x4A4E + (0x80 * i);
/*      ifs.seek(targetSector * sectorSize);
      TBufStream ofs;
      ofs.writeFrom(ifs, 0x80 * sectorSize);
      
      std::string outName = std::string("base/scene/scene-")
        + TStringConversion::intToString(targetSector,
            TStringConversion::baseHex)
        + ".bin";
      TFileManip::createDirectoryForFile(outName);
      ofs.save(outName.c_str());*/
      
      dumpIsoVisualBlock(ifs, targetSector, visualSceneStrings);
    }
  
    //========================================================================
    // other
    //========================================================================
    
    miscStrings.addSetRegion("ayaka flashback");
    miscStrings.addSetRegionProperty("stringsAreSceneFormat",
      TStringConversion::intToString(1,
        TStringConversion::baseHex));
    
    // add string placeholders
/*    for (int i = 0; i < 2; i++) {
      PidolGenericString result;
      
      result.type = PidolGenericString::type_string;
      result.offset = 0;
      result.size = 0;
      result.mayNotExist = true;
      result.idOverride = std::string("ayaka-flashback-")
        + TStringConversion::intToString(i,
            TStringConversion::baseDec);
      miscStrings.strings.push_back(result);
    }*/
    miscStrings.addPlaceholderStrings(2, "ayaka-flashback-");
    
    miscStrings.addSetRegion("tongue twister");
    miscStrings.addSetRegionProperty("stringsAreSceneFormat",
      TStringConversion::intToString(1,
        TStringConversion::baseHex));
    miscStrings.addPlaceholderStrings(100, "tonguetwister-");
    
    miscStrings.addSetRegion("syscard error");
    miscStrings.addSetRegionProperty("stringsAreSceneFormat",
      TStringConversion::intToString(1,
        TStringConversion::baseHex));
    miscStrings.addPlaceholderStrings(30, "syscard-error-");
  
    //========================================================================
    // other (text format)
    //========================================================================
    
//    miscStrings8x8.addGenericLine("#LOADTABLE(\"table/ascii.tbl\")");
    
    miscStrings8x8.addSetRegion("case3 pc strings");
    miscStrings8x8.addGenericLine("#SETWIDTH(256)");
    miscStrings8x8.addPlaceholderStrings(8, "case3-pc-");
    
    miscStrings8x8.addSetRegion("autopsy strings");
    miscStrings8x8.addGenericLine("#SETWIDTH(256)");
    miscStrings8x8.addPlaceholderStrings(4, "autopsy-");
    
    miscStrings8x8.addSetRegion("autopsy 2 strings");
    miscStrings8x8.addGenericLine("#SETWIDTH(256)");
    miscStrings8x8.addPlaceholderStrings(4, "autopsy2-");
    
    miscStrings8x8.addSetRegion("cafe menu strings");
    miscStrings8x8.addGenericLine("#SETWIDTH(-1)");
    miscStrings8x8.addPlaceholderStrings(4, "cafe-");
    
    miscStrings8x8.addSetRegion("cafe passwords");
    miscStrings8x8.addGenericLine("#SETWIDTH(-1)");
    miscStrings8x8.addGenericLine("#LOADTABLE(\"table/pidol_menu_en.tbl\")");
    miscStrings8x8.addPlaceholderStrings(1, "cafe-passwords-");
    
    // FIXME
//    miscStrings8x8.addGenericLine("#LOADTABLE(\"table/pidol_en.tbl\")");
  
    //========================================================================
    // credits
    //========================================================================
    
    creditsStrings.addSetRegion("credits");
    creditsStrings.addSetRegionProperty("stringsAreSceneFormat",
      TStringConversion::intToString(1,
        TStringConversion::baseHex));
    creditsStrings.addPlaceholderStrings(30, "credits-");
  
    //========================================================================
    // credits text
    //========================================================================
    
    creditsTextStrings.addSetRegion("credits text");
    {
      ifs.seek(0x54CE * sectorSize);
      TBufStream credIfs;
      credIfs.writeFrom(ifs, 0x40000);
      
      credIfs.seek(0);
      dumpCreditsText(credIfs, creditsTextStrings);
//      credIfs.seek(0x4634);
    }
  
    //========================================================================
    // backup utility text
    //========================================================================
    
    backUtilStrings.addSetRegion("backutil text");
    {
      ifs.seek(0x36 * sectorSize);
      TBufStream backUtilIfs;
      backUtilIfs.writeFrom(ifs, 0x40000);
      
      backUtilIfs.seek(0);
      dumpBackUtilText(backUtilIfs, backUtilStrings);
//      credIfs.seek(0x4634);
    }
    
    







    
    
    //=======================================
    // export
    //=======================================
    
//    scriptSheet.exportCsv("script/orig/script_main.csv");
    
//    for (int i = 0; i < 34; i++) {
    
    {
      PidolTranslationSheet scriptSheet;
      
      std::ofstream ofs("script/orig/spec_main.txt");
      strings.exportToSheet(scriptSheet, ofs, "");
  //    extraStrings.exportToSheet(scriptSheet, ofs, "main-");
      scriptSheet.exportCsv("script/orig/script_main.csv");
    }
    
    {
      PidolTranslationSheet scriptSheet;
      std::ofstream ofs("script/orig/spec_advscene.txt");
      advSceneStrings.exportToSheet(scriptSheet, ofs, "");
      scriptSheet.exportCsv("script/orig/script_advscene.csv");
    }
    
    {
      PidolTranslationSheet scriptSheet;
      std::ofstream ofs("script/orig/spec_visual.txt");
      visualSceneStrings.exportToSheet(scriptSheet, ofs, "");
      scriptSheet.exportCsv("script/orig/script_visual.csv");
    }
    
    {
      PidolTranslationSheet scriptSheet;
      std::ofstream ofs("script/orig/spec_misc.txt");
      miscStrings.exportToSheet(scriptSheet, ofs, "");
      scriptSheet.exportCsv("script/orig/script_misc.csv");
    }
    
    {
      PidolTranslationSheet scriptSheet;
      std::ofstream ofs("script/orig/spec_8x8.txt");
      miscStrings8x8.exportToSheet(scriptSheet, ofs, "");
      scriptSheet.exportCsv("script/orig/script_8x8.csv");
    }
    
    {
      PidolTranslationSheet scriptSheet;
      std::ofstream ofs("script/orig/spec_credits.txt");
      creditsStrings.exportToSheet(scriptSheet, ofs, "");
      scriptSheet.exportCsv("script/orig/script_credits.csv");
    }
    
    {
      PidolTranslationSheet scriptSheet;
      std::ofstream ofs("script/orig/spec_creditstext.txt");
      creditsTextStrings.exportToSheet(scriptSheet, ofs, "");
      scriptSheet.exportCsv("script/orig/script_creditstext.csv");
    }
    
    {
      PidolTranslationSheet scriptSheet;
      std::ofstream ofs("script/orig/spec_backutil.txt");
      backUtilStrings.exportToSheet(scriptSheet, ofs, "");
      scriptSheet.exportCsv("script/orig/script_backutil.csv");
    }
  }
  
  return 0;
}
