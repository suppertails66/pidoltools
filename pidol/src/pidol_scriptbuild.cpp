#include "pidol/PidolScriptReader.h"
#include "pidol/PidolLineWrapper.h"
#include "pidol/PidolTextScript.h"
#include "util/TBufStream.h"
#include "util/TIfstream.h"
#include "util/TOfstream.h"
#include "util/TGraphic.h"
#include "util/TStringConversion.h"
#include "util/TFileManip.h"
#include "util/TPngConversion.h"
#include "util/TFreeSpace.h"
#include <cctype>
#include <string>
#include <vector>
#include <iostream>
#include <sstream>
#include <fstream>

using namespace std;
using namespace BlackT;
using namespace Pce;

const static int sectorSize = 0x800;

const static int textCharsStart = 0x20;
const static int textCharsEnd = textCharsStart + 0x60;
const static int textEncodingMax = 0x100;
const static int maxDictionarySymbols = textEncodingMax - textCharsEnd;

const static int fontEmphToggleOp = 0x7F;

TThingyTable table;
TThingyTable tableScene;
TThingyTable table8x8;
TThingyTable tableCredits;
TThingyTable tableBackUtil;

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

std::string getNumStr(int num) {
  std::string str = TStringConversion::intToString(num);
  while (str.size() < 2) str = string("0") + str;
  return str;
}

std::string getHexByteNumStr(int num) {
  std::string str = TStringConversion::intToString(num,
    TStringConversion::baseHex).substr(2, string::npos);
  while (str.size() < 2) str = string("0") + str;
  return string("$") + str;
}

std::string getHexWordNumStr(int num) {
  std::string str = TStringConversion::intToString(num,
    TStringConversion::baseHex).substr(2, string::npos);
  while (str.size() < 4) str = string("0") + str;
  return string("$") + str;
}
                      

void binToDcb(TStream& ifs, std::ostream& ofs) {
  int constsPerLine = 16;
  
  while (true) {
    if (ifs.eof()) break;
    
    ofs << "  .db ";
    
    for (int i = 0; i < constsPerLine; i++) {
      if (ifs.eof()) break;
      
      TByte next = ifs.get();
      ofs << as2bHexPrefix(next);
      if (!ifs.eof() && (i != constsPerLine - 1)) ofs << ",";
    }
    
    ofs << std::endl;
  }
}




typedef std::map<std::string, int> UseCountTable;
//typedef std::map<std::string, double> EfficiencyTable;
typedef std::map<double, std::string> EfficiencyTable;

bool isCompressible(std::string& str) {
  for (int i = 0; i < str.size(); i++) {
    if ((unsigned char)str[i] < textCharsStart) return false;
    if ((unsigned char)str[i] >= textCharsEnd) return false;
    if ((unsigned char)str[i] == fontEmphToggleOp) return false;
  }
  
  return true;
}

void addStringToUseCountTable(std::string& input,
                        UseCountTable& useCountTable,
                        int minLength, int maxLength) {
  int total = input.size() - minLength;
  if (total <= 0) return;
  
  for (int i = 0; i < total; ) {
    int basePos = i;
    for (int j = minLength; j < maxLength; j++) {
      int length = j;
      if (basePos + length >= input.size()) break;
      
      std::string str = input.substr(basePos, length);
      
      // HACK: avoid analyzing parameters of control sequences
      // the ops themselves are already ignored in the isCompressible check;
      // we just check when an op enters into the first byte of the string,
      // then advance the check position so the parameter byte will
      // never be considered
/*      if ((str.size() > 0) && ((unsigned char)str[0] < textCharsStart)) {
        unsigned char value = str[0];
        if ((value == 0x02) // "L"
            || (value == 0x05) // "P"
            || (value == 0x06)) { // "W"
          // skip the argument byte
          i += 1;
        }
        break;
      }*/
      if (str.size() > 0) {
        unsigned char value = str[0];
        if (PidolTextScript::isOp(value)) {
          // skip the arguments
          i += PidolTextScript::getOpArgsSize(value);
          break;
        }
      }
      
      if (!isCompressible(str)) break;
      
      ++(useCountTable[str]);
    }
    
    // skip literal arguments to ops
/*    if ((unsigned char)input[i] < textCharsStart) {
      ++i;
      int opSize = numOpParamWords((unsigned char)input[i]);
      i += opSize;
    }
    else {
      ++i;
    } */
    ++i;
  }
}

void addRegionsToUseCountTable(PidolScriptReader::NameToRegionMap& input,
                        UseCountTable& useCountTable,
                        int minLength, int maxLength) {
  for (PidolScriptReader::NameToRegionMap::iterator it = input.begin();
       it != input.end();
       ++it) {
    PidolScriptReader::ResultCollection& results = it->second.strings;
    for (PidolScriptReader::ResultCollection::iterator jt = results.begin();
         jt != results.end();
         ++jt) {
//      std::cerr << jt->srcOffset << std::endl;
      if (jt->isLiteral) continue;
      if (jt->isNotCompressible) continue;
      
      addStringToUseCountTable(jt->str, useCountTable,
                               minLength, maxLength);
    }
  }
}

void buildEfficiencyTable(UseCountTable& useCountTable,
                        EfficiencyTable& efficiencyTable) {
  for (UseCountTable::iterator it = useCountTable.begin();
       it != useCountTable.end();
       ++it) {
    std::string str = it->first;
    // penalize by 1 byte (length of the dictionary code)
    double strLen = str.size() - 1;
    double uses = it->second;
//    efficiencyTable[str] = strLen / uses;
    
    efficiencyTable[strLen / uses] = str;
  }
}

void applyDictionaryEntry(std::string entry,
                          PidolScriptReader::NameToRegionMap& input,
                          std::string replacement) {
  for (PidolScriptReader::NameToRegionMap::iterator it = input.begin();
       it != input.end();
       ++it) {
    PidolScriptReader::ResultCollection& results = it->second.strings;
    int index = -1;
    for (PidolScriptReader::ResultCollection::iterator jt = results.begin();
         jt != results.end();
         ++jt) {
      ++index;
      
      if (jt->isNotCompressible) continue;
      
      std::string str = jt->str;
      if (str.size() < entry.size()) continue;
      
      std::string newStr;
      int i;
      for (i = 0; i < str.size() - entry.size(); ) {
        if (PidolTextScript::isOp((unsigned char)str[i])) {
/*          int numParams = numOpParamWords((unsigned char)str[i]);
          
          newStr += str[i];
          for (int j = 0; j < numParams; j++) {
            newStr += str[i + 1 + j];
          }
          
          ++i;
          i += numParams; */
          
/*          newStr += str[i];
          ++i;
          continue;*/
          
/*          if (jt->id.compare("area-0x1F3E-0x7FBC") == 0) {
            std::cerr << "here" << std::endl;
            std::cerr << "op: " << std::hex << (unsigned char)str[i] << std::endl;
            std::cerr << "start:  " << std::hex << i << std::endl;
          }*/
          
          int numParams = PidolTextScript::getOpArgsSize((unsigned char)str[i]);
          newStr += str[i++];
          for (int j = 0; j < numParams; j++) {
            newStr += str[i + j];
          }
          i += numParams;
          
/*          if (jt->id.compare("area-0x1F3E-0x7FBC") == 0) {
            std::cerr << "size: " << std::dec << numParams << std::endl;
            std::cerr << "finish: " << std::hex << i << std::endl;
            char c;
            std::cin >> c;
          }*/
          
          continue;
        }
        
        if (entry.compare(str.substr(i, entry.size())) == 0) {
          newStr += replacement;
          i += entry.size();
        }
        else {
          newStr += str[i];
          ++i;
        }
      }
      
      while (i < str.size()) newStr += str[i++];
      
      jt->str = newStr;
    }
  }
}

void generateCompressionDictionary(
    PidolScriptReader::NameToRegionMap& results,
    std::string outputDictFileName) {
  TBufStream dictOfs;
  for (int i = 0; i < maxDictionarySymbols; i++) {
//    cerr << i << endl;
    UseCountTable useCountTable;
    addRegionsToUseCountTable(results, useCountTable, 2, 3);
    EfficiencyTable efficiencyTable;
    buildEfficiencyTable(useCountTable, efficiencyTable);
    
//    std::cout << efficiencyTable.begin()->first << std::endl;
    
    // if no compressions are possible, give up
    if (efficiencyTable.empty()) break;  
    
    int symbol = i + textCharsEnd;
    applyDictionaryEntry(efficiencyTable.begin()->second,
                         results,
                         std::string() + (char)symbol);
    
    // debug
/*    TBufStream temp;
    temp.writeString(efficiencyTable.begin()->second);
    temp.seek(0);
//    binToDcb(temp, cout);
    std::cout << "\"";
    while (!temp.eof()) {
      std::cout << table.getEntry(temp.get());
    }
    std::cout << "\"" << std::endl; */
    
    dictOfs.writeString(efficiencyTable.begin()->second);
  }
  
//  dictOfs.save((outPrefix + "dictionary.bin").c_str());
  dictOfs.save(outputDictFileName.c_str());
}

// merge a set of NameToRegionMaps into a single NameToRegionMap
void mergeResultMaps(
    std::vector<PidolScriptReader::NameToRegionMap*>& allSrcPtrs,
    PidolScriptReader::NameToRegionMap& dst) {
  int targetOutputId = 0;
  for (std::vector<PidolScriptReader::NameToRegionMap*>::iterator it
        = allSrcPtrs.begin();
       it != allSrcPtrs.end();
       ++it) {
    PidolScriptReader::NameToRegionMap& src = **it;
    for (PidolScriptReader::NameToRegionMap::iterator jt = src.begin();
         jt != src.end();
         ++jt) {
      dst[TStringConversion::intToString(targetOutputId++)] = jt->second;
    }
  }
}

// undo the effect of mergeResultMaps(), applying any changes made to
// the merged maps back to the separate originals
void unmergeResultMaps(
    PidolScriptReader::NameToRegionMap& src,
    std::vector<PidolScriptReader::NameToRegionMap*>& allSrcPtrs) {
  int targetInputId = 0;
  for (std::vector<PidolScriptReader::NameToRegionMap*>::iterator it
        = allSrcPtrs.begin();
       it != allSrcPtrs.end();
       ++it) {
    PidolScriptReader::NameToRegionMap& dst = **it;
    for (PidolScriptReader::NameToRegionMap::iterator jt = dst.begin();
         jt != dst.end();
         ++jt) {
      jt->second = src[TStringConversion::intToString(targetInputId++)];
    }
  }
}

void exportGenericRegion(PidolScriptReader::ResultCollection& results,
                         std::string prefix) {
  for (PidolScriptReader::ResultCollection::iterator it = results.begin();
       it != results.end();
       ++it) {
    if (it->str.size() <= 0) continue;
    
    PidolScriptReader::ResultString str = *it;
    
    std::string outName = prefix + str.id + ".bin";
    TFileManip::createDirectoryForFile(outName);
    
    TBufStream ofs;
    ofs.writeString(str.str);
    ofs.save(outName.c_str());
  }
}

void exportGenericRegionMap(PidolScriptReader::NameToRegionMap& results,
                         std::string prefix) {
  for (auto it: results) {
    exportGenericRegion(it.second.strings, prefix);
  }
}

void exportRegionAdvSceneInclude(PidolScriptReader::ResultRegion& results,
                         std::string regionName, std::string prefix) {
  std::string fileName = prefix + regionName + ".inc";
  TFileManip::createDirectoryForFile(fileName);
  std::ofstream ofs(fileName.c_str());
  
  for (auto it: results.freeSpace.freeSpace_) {
    // size is reduced by 4 to leave space for end-of-bank content marker
    // and script start pointer
    ofs << ".unbackground " << it.first << " " << it.first + it.second - 1 - 4
      << std::endl;
  }
  
//  ofs << endl;
//  ofs << ".bank 0 slot 0" << endl;
//  ofs << "" << endl;
}

void exportAdvSceneIncludes(PidolScriptReader::NameToRegionMap& results,
                         std::string prefix) {
  for (auto it: results) {
    exportRegionAdvSceneInclude(it.second, it.first, prefix);
  }
}

void exportRegionVisualInclude(PidolScriptReader::ResultRegion& results,
                         std::string regionName, std::string prefix) {
  std::string fileName = prefix + regionName + ".inc";
  TFileManip::createDirectoryForFile(fileName);
  std::ofstream ofs(fileName.c_str());
  
  for (auto it: results.freeSpace.freeSpace_) {
    ofs << ".unbackground " << it.first << " " << it.first + it.second - 1
      << std::endl;
  }
  
  if (results.hasProperty("genSpriteTable_raw")) {
    ofs << ".define genSpriteTable $" << hex
      << TStringConversion::stringToInt(
          results.properties.at("genSpriteTable_raw"))
         + 0x4000
      << endl;
  }
  
  if (results.hasProperty("playCdTrack_raw")) {
    ofs << ".define playCdTrack $" << hex
      << TStringConversion::stringToInt(
          results.properties.at("playCdTrack_raw"))
         + 0x4000
      << endl;
  }
  
  if (results.hasProperty("cplayAdpcm_raw")) {
    ofs << ".define cplayAdpcm $" << hex
      << TStringConversion::stringToInt(
          results.properties.at("cplayAdpcm_raw"))
         + 0x4000
      << endl;
  }
  
  if (results.hasProperty("setSceneTimer_raw")) {
    ofs << ".define setSceneTimer $" << hex
      << TStringConversion::stringToInt(
          results.properties.at("setSceneTimer_raw"))
         + 0x4000
      << endl;
  }
  
  if (results.hasProperty("currentSpriteCount_ptr")) {
    ofs << ".define currentSpriteCount $" << hex
      << TStringConversion::stringToInt(
          results.properties.at("currentSpriteCount_ptr"))
      << endl;
  }
  
  if (results.hasProperty("doObjTimerSet1_raw")) {
    ofs << ".define doObjTimerSet1 $" << hex
      << TStringConversion::stringToInt(
          results.properties.at("doObjTimerSet1_raw"))
         + 0x4000
      << endl;
  }
  
  if (results.hasProperty("doObjTimerSet2_raw")) {
    ofs << ".define doObjTimerSet2 $" << hex
      << TStringConversion::stringToInt(
          results.properties.at("doObjTimerSet2_raw"))
         + 0x4000
      << endl;
  }
  
  if (results.hasProperty("sceneVramCopy_raw")) {
    ofs << ".define sceneVramCopy $" << hex
      << TStringConversion::stringToInt(
          results.properties.at("sceneVramCopy_raw"))
         + 0x4000
      << endl;
  }
  
  if (results.hasProperty("sceneTilemapCopy_raw")) {
    ofs << ".define sceneTilemapCopy $" << hex
      << TStringConversion::stringToInt(
          results.properties.at("sceneTilemapCopy_raw"))
         + 0x4000
      << endl;
  }
  
  if (results.hasProperty("fadeArrayBase")) {
    ofs << ".define fadeArrayBase $" << hex
      << TStringConversion::stringToInt(
          results.properties.at("fadeArrayBase"))
      << endl;
  }
  
  if (results.hasProperty("fadeOn")) {
    ofs << ".define fadeOn $" << hex
      << TStringConversion::stringToInt(
          results.properties.at("fadeOn"))
      << endl;
  }
  
  if (results.hasProperty("fadeBgBase")) {
    ofs << ".define fadeBgBase $" << hex
      << TStringConversion::stringToInt(
          results.properties.at("fadeBgBase"))
      << endl;
  }
  
  if (results.hasProperty("fadeSpriteBase")) {
    ofs << ".define fadeSpriteBase $" << hex
      << TStringConversion::stringToInt(
          results.properties.at("fadeSpriteBase"))
      << endl;
  }
  
  if (results.hasProperty("readControllers_raw")) {
    ofs << ".define readControllers $" << hex
      << TStringConversion::stringToInt(
          results.properties.at("readControllers_raw"))
         + 0x4000
      << endl;
  }
}

void exportVisualIncludes(PidolScriptReader::NameToRegionMap& results,
                         std::string prefix) {
  for (auto it: results) {
    exportRegionVisualInclude(it.second, it.first, prefix);
  }
}

void exportRegionCreditsInclude(PidolScriptReader::ResultRegion& results,
                         std::string regionName, std::string prefix) {
  std::string fileName = prefix + "credits_text.inc";
  TFileManip::createDirectoryForFile(fileName);
  std::ofstream ofs(fileName.c_str());
  
  for (auto it: results.freeSpace.freeSpace_) {
    int start = 0x10000 + it.first + 0x6000;
    int end = start + it.second + 0x6000 - 1;
    ofs << ".unbackground " << start << " " << end
      << std::endl;
  }
  
  for (auto& it: results.strings) {
    std::string labelName = it.id;
    std::string sectionName = "credits str "
      + it.id;
    
    ofs << ".bank 1 slot 0" << endl;
    ofs << ".section \"" << sectionName << "\" free" << endl;
    ofs << "  " << labelName << ":" << endl;
//    ofs << "  .incbin \"out/script/strings/" << it.id << ".bin\"" << endl;
//    ofs << binToDcb(it.str) << endl;
    {
      TBufStream ifs;
      ifs.writeString(it.str);
      ifs.put(0x00);
      ifs.seek(0);
      binToDcb(ifs, ofs);
    }
    ofs << ".ends" << endl;
    
    for (auto& jt: it.pointerRefs) {
      ofs << ".bank 2 slot 0" << endl;
      ofs << ".orga $"
        << TStringConversion::intToString(jt + 0xC000,
              TStringConversion::baseHex).substr(2, string::npos)
        << endl;
      ofs << ".section \"" << sectionName << " ref " << jt << "\" overwrite" << endl;
      ofs << "  .dw " << labelName << endl;
      ofs << ".ends" << endl;
    }
  }
}

void exportCreditsIncludes(PidolScriptReader::NameToRegionMap& results,
                         std::string prefix) {
  for (auto& it: results) {
    exportRegionCreditsInclude(it.second, it.first, prefix);
  }
}

void exportRegionBackUtilInclude(PidolScriptReader::ResultRegion& results,
                         std::string regionName, std::string prefix) {
  std::string fileName = prefix + "backutil.inc";
  TFileManip::createDirectoryForFile(fileName);
  std::ofstream ofs(fileName.c_str());
  
/*  for (auto it: results.freeSpace.freeSpace_) {
    int start = 0x10000 + it.first + 0x6000;
    int end = start + it.second + 0x6000 - 1;
    ofs << ".unbackground " << start << " " << end
      << std::endl;
  }*/
  
  for (auto& it: results.strings) {
    std::string labelName = it.id;
    std::string sectionName = "backutil str "
      + it.id;
    
    // HACK
    int origOffset = -1;
    for (int i = 0; i < labelName.size() - 1; i++) {
      if ((labelName[i] == '0') && (labelName[i + 1] == 'x')) {
        origOffset = TStringConversion::stringToInt(
          labelName.substr(i, std::string::npos));
        origOffset -= 0x4000;
        break;
      }
    }
    
    ofs << ".bank bank2 slot 3" << endl;
    ofs << ".section \"" << sectionName << "\" free" << endl;
    ofs << "  " << labelName << ":" << endl;
//    ofs << "  .incbin \"out/script/strings/" << it.id << ".bin\"" << endl;
//    ofs << binToDcb(it.str) << endl;
    {
      TBufStream ifs;
      ifs.writeString(it.str);
      ifs.put(0x00);
      ifs.seek(0);
      binToDcb(ifs, ofs);
    }
    ofs << ".ends" << endl;
    
    ofs << ".bank bank2 slot 3" << endl;
    ofs << ".orga $"
      << TStringConversion::intToString(origOffset + 0xC000,
            TStringConversion::baseHex).substr(2, string::npos)
      << endl;
    ofs << ".section \"" << sectionName << " ref " << origOffset << "\" overwrite" << endl;
    ofs << "  .dw " << labelName << endl;
    ofs << ".ends" << endl;
  }
}

void exportBackUtilIncludes(PidolScriptReader::NameToRegionMap& results,
                         std::string prefix) {
  for (auto& it: results) {
    exportRegionBackUtilInclude(it.second, it.first, prefix);
  }
}

// original table
/*const int newMenuColLayoutTable[] = {
  // 1-column menu
  0x00, 0x1C, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  // 2-column menu
  0x00, 0x0E, 0x1C, 0x00, 0x00, 0x00, 0x00, 0x00,
  // 3-column menu
  0x00, 0x08, 0x11, 0x1C, 0x00, 0x00, 0x00, 0x00,
  // 4-column menu
  0x00, 0x07, 0x0E, 0x15, 0x1C, 0x00, 0x00, 0x00,
  // 5-column menu
  0x00, 0x05, 0x0B, 0x10, 0x17, 0x1C, 0x00, 0x00,
};
const int numNewMenuColLayoutTableEntries
  = sizeof(newMenuColLayoutTable) / sizeof(int);*/

// new table
const int newMenuColLayoutTable[] = {
  // 1-column menu
  0x00, 0x1C, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  // 2-column menu
  0x00, 0x0E, 0x1C, 0x00, 0x00, 0x00, 0x00, 0x00,
  // 3-column menu
  // 0x40->0x48 (original text target: (14 * 5)  = 0x46
  // 0x88->0x90 (original text target: (14 * 10) = 0x8C)
  0x00, 0x08+0x1, 0x11+0x1, 0x1C, 0x00, 0x00, 0x00, 0x00,
  // 4-column menu (is this actually used? maybe for the settings menu?)
  0x00, 0x07, 0x0E, 0x15, 0x1C, 0x00, 0x00, 0x00,
  // 5-column menu (as above, is this actually used?)
  0x00, 0x05, 0x0B, 0x10, 0x17, 0x1C, 0x00, 0x00,
};
const int numNewMenuColLayoutTableEntries
  = sizeof(newMenuColLayoutTable) / sizeof(int);

void patchStdBlock(TStream& ofs, PidolScriptReader::ResultRegion& region,
                   std::string name = "") {
  for (auto entry: region.strings) {
    // claim space for new entry, failing if not enough available
    int newPos = region.freeSpace.claim(entry.str.size());
    if (newPos < 0) {
      throw TGenericException(T_SRCANDLINE,
                              "patchStdBlock()",
                              std::string("Region '")
                              + name
                              + "': no space for string '"
                              + entry.id
                              + "'");
    }
    
    // write new data
    ofs.seek(newPos);
    ofs.writeString(entry.str);
    
    // update references
    for (auto pointerRef: entry.pointerRefs) {
      ofs.seek(pointerRef);
      ofs.writeu16le(newPos);
      
      // update to use new opcode
      // (we have to distinguish modified pointers from original ones
      // so the script base bank can be set to a lower area for the hack)
      ofs.seek(pointerRef - 1);
      ofs.writeu8(0xFE);
    }
  }
  
  // update menu column layout if applicable
  if (region.hasProperty("menuColLayoutTable_raw")) {
    int menuColLayoutTable_raw
      = TStringConversion::stringToInt(
          region.properties.at("menuColLayoutTable_raw"));
    ofs.seek(menuColLayoutTable_raw);
    for (int i = 0; i < numNewMenuColLayoutTableEntries; i++) {
      ofs.writeu8(newMenuColLayoutTable[i]);
    }
  }
}


int main(int argc, char* argv[]) {
  if (argc < 3) {
    cout << "Private Eye Dol script builder" << endl;
    cout << "Usage: " << argv[0] << " [inprefix] [outprefix]"
      << endl;
    return 0;
  }
  
//  string infile(argv[1]);
  string inPrefix(argv[1]);
  string outPrefix(argv[2]);

//  table.readUtf8("table/pidol_en.tbl");
//  tableScene.readUtf8("table/pidol_scenes_en.tbl");
  table.readSjis("table/pidol_en.tbl");
  tableScene.readSjis("table/pidol_scenes_en.tbl");
  table8x8.readSjis("table/ascii.tbl");
  tableCredits.readSjis("table/pidol_credits_en.tbl");
  tableBackUtil.readSjis("table/pidol_backutil_en.tbl");
  
  //=====
  // read script
  //=====
  
  PidolScriptReader::NameToRegionMap scriptResults;
  {
    TBufStream ifs;
    ifs.open((inPrefix + "spec_main.txt").c_str());
    PidolScriptReader(ifs, scriptResults, table)();
  }
  
  PidolScriptReader::NameToRegionMap advSceneResults;
  {
    TBufStream ifs;
    ifs.open((inPrefix + "spec_advscene.txt").c_str());
    PidolScriptReader(ifs, advSceneResults, tableScene)();
  }
  
  PidolScriptReader::NameToRegionMap visualResults;
  {
    TBufStream ifs;
    ifs.open((inPrefix + "spec_visual.txt").c_str());
    PidolScriptReader(ifs, visualResults, tableScene)();
  }
  
  PidolScriptReader::NameToRegionMap miscResults;
  {
    TBufStream ifs;
    ifs.open((inPrefix + "spec_misc.txt").c_str());
    PidolScriptReader(ifs, miscResults, tableScene)();
  }
  
  PidolScriptReader::NameToRegionMap t8x8Results;
  {
    TBufStream ifs;
    ifs.open((inPrefix + "spec_8x8.txt").c_str());
    PidolScriptReader(ifs, t8x8Results, table8x8)();
  }
  
  PidolScriptReader::NameToRegionMap creditsResults;
  {
    TBufStream ifs;
    ifs.open((inPrefix + "spec_credits.txt").c_str());
    PidolScriptReader(ifs, creditsResults, tableScene)();
  }
  
  PidolScriptReader::NameToRegionMap creditsTextResults;
  {
    TBufStream ifs;
    ifs.open((inPrefix + "spec_creditstext.txt").c_str());
    PidolScriptReader(ifs, creditsTextResults, tableCredits)();
  }
  
  PidolScriptReader::NameToRegionMap backUtilResults;
  {
    TBufStream ifs;
    ifs.open((inPrefix + "spec_backutil.txt").c_str());
    PidolScriptReader(ifs, backUtilResults, tableBackUtil)();
  }
  
/*  PidolScriptReader::NameToRegionMap battleResults;
  {
    TBufStream ifs;
    ifs.open((inPrefix + "spec_battle.txt").c_str());
    PidolScriptReader(ifs, battleResults, table)();
  }
  
  PidolScriptReader::NameToRegionMap sceneResults;
  {
    TBufStream ifs;
    ifs.open((inPrefix + "spec_scene.txt").c_str());
    PidolScriptReader(ifs, sceneResults, tableScene)();
  }*/
  
//  generateCompressionDictionary(
//    scriptResults, outPrefix + "script_dictionary.bin");
  
  //=====
  // compress
  //=====
  
  {
    PidolScriptReader::NameToRegionMap allStrings;
    
    // FIXME: make separate tables for main/battle?
    // if it even matters
    std::vector<PidolScriptReader::NameToRegionMap*> allSrcPtrs;
    allSrcPtrs.push_back(&scriptResults);
//    allSrcPtrs.push_back(&battleResults);
    
    // merge everything into one giant map for compression
    mergeResultMaps(allSrcPtrs, allStrings);
    
    // compress
    generateCompressionDictionary(
      allStrings, outPrefix + "script_dictionary.bin");
    
    // restore results from merge back to individual containers
    unmergeResultMaps(allStrings, allSrcPtrs);
  }
  
  //=====
  // update blocks
  //=====
  
  for (auto entry: scriptResults) {
    std::string name = entry.first;
    PidolScriptReader::ResultRegion& region = entry.second;
    
    std::string filename;
    if (region.regionType == PidolScriptReader::regionType_area) {
      filename = std::string("out/base/area/") + name + ".bin";
    }
    else if (region.regionType == PidolScriptReader::regionType_adv) {
      filename = std::string("out/base/adv/") + name + ".bin";
    }
    
    if (!filename.empty()) {
      TBufStream ifs;
      ifs.open(filename.c_str());
      patchStdBlock(ifs, region, name);
      ifs.save(filename.c_str());
    }
  }
  
  //=====
  // export generic/hardcoded strings
  //=====
  
  exportGenericRegionMap(advSceneResults, "out/script/strings/");
  exportGenericRegionMap(visualResults, "out/script/strings/");
  exportGenericRegionMap(miscResults, "out/script/strings/");
  exportGenericRegionMap(t8x8Results, "out/script/strings/");
  exportGenericRegionMap(creditsResults, "out/script/strings/");
//  exportGenericRegionMap(creditsTextResults, "out/script/strings/");
  
  //=====
  // output auto-generated ASM includes for scenes
  //=====
  
  exportAdvSceneIncludes(advSceneResults, "asm/gen/");
  exportVisualIncludes(visualResults, "asm/gen/");
  
  //=====
  // output auto-generated ASM includes for credits
  //=====
  
  exportCreditsIncludes(creditsTextResults, "asm/gen/");
  
  //=====
  // output auto-generated ASM includes for backup utility
  //=====
  
  exportBackUtilIncludes(backUtilResults, "asm/gen/");
  
  //=====
  // update text blocks
  //=====
  
/*  {
  //  TIfstream ifs("pidol_02.iso");
    // oops i never made an fstream wrapper and don't want to bother now.
    // we need to read and write this, so let's just load the whole thing
    // into memory, because it's the year 2021 and we can probably afford
    // a few hundred megabytes of RAM
  //  ifs.open("pidol_02_build.iso");
    // actually, i guess what i did for the first game is probably better...
    TBufStream ifs;
    ifs.open("base/text_all_2E7A.bin");
    
    for (int i = 0; i < numTextBlocks; i++) {
      int unindexedBlockId = (i * 2);
      updateTextBlock(ifs, i, scriptResults[unindexedBlockId]);
    }
    
    ifs.save((outPrefix + "text_all_2E7A.bin").c_str());
  }*/
  
  //=====
  // update battle blocks
  //=====
  
/*  {
    TBufStream ifs;
    ifs.open("base/battleblock_all_206.bin");

    for (PidolScriptReader::NameToRegionMap::iterator it
          = battleResults.begin();
         it != battleResults.end();
         ++it) {
      // ignore the miscellaneous strings region
      if (it->first == -1) continue;
      
      // otherwise, region number is target block's sector number
      // within the overall text block
      updateBattleBlock(ifs, it->first, it->second);
    }
    
    ifs.save((outPrefix + "battleblock_all_206.bin").c_str());
  }*/
  
  //=====
  // save modified iso
  //=====
  
//  ifs.save("pidol_02_build.iso");
  
  return 0;
}
