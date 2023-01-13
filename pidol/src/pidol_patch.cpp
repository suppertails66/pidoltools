#include "pce/PcePalette.h"
#include "pidol/PidolScriptReader.h"
#include "pidol/PidolLineWrapper.h"
#include "util/TBufStream.h"
#include "util/TIfstream.h"
#include "util/TOfstream.h"
#include "util/TGraphic.h"
#include "util/TStringConversion.h"
#include "util/TPngConversion.h"
#include "util/TFileManip.h"
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

void patchFile(TBufStream& ofs,
               std::string filename,
               int offset,
               int sizeLimit = -1) {
  if (!TFileManip::fileExists(filename)) {
    throw TGenericException(T_SRCANDLINE,
                            "patchFile()",
                            std::string("File does not exist: ")
                              + filename);
  }
  
  std::cout << "patching '" << filename << "' to "
    << TStringConversion::intToString(offset,
        TStringConversion::baseHex)
    << std::endl;
  
  TBufStream ifs;
  ifs.open(filename.c_str());
  
  if (sizeLimit == -1) sizeLimit = ifs.size();
  
  ofs.seek(offset);
  ofs.writeFrom(ifs, sizeLimit);
}

void patchFileBySector(TBufStream& ofs,
               std::string filename,
               int sectorNum,
               int sizeLimit = -1) {
  patchFile(ofs, filename, sectorNum * sectorSize, sizeLimit);
}

int getFileNameSectorNum(std::string filename) {
  int hyphenPos = filename.size() - 1;
  for ( ; hyphenPos >= 0; hyphenPos--) {
    if (filename[hyphenPos] == '-') break;
  }
  
  if (hyphenPos < 0) return -1;
  
  std::string valueStr = filename.substr(hyphenPos + 1, std::string::npos);
  return TStringConversion::stringToInt(valueStr);
}

int main(int argc, char* argv[]) {
  if (argc < 3) {
    cout << "Private Eye Dol ISO patcher" << endl;
    cout << "Usage: " << argv[0]
      << " <infile> <outfile>" << endl;
  }
  
  string infile(argv[1]);
  string outfile(argv[2]);

  // patching modified files to the ISO one by one resulted in
  // ridiculous disk I/O, so i've turned the original shell script
  // into this dedicated program to speed it up
  
  TBufStream ofs;
  ofs.open(infile.c_str());
  
  //=======================
  // area modules
  //=======================
  
  {
    TFileManip::FileInfoCollection dirListing;
    TFileManip::getDirectoryListing("out/base/area", dirListing);
    for (auto entry: dirListing) {
//      TBufStream ifs;
//      ifs.open(entry.path());
//      int dstSector = getFileNameSectorNum(entry.name());
      patchFileBySector(
        ofs, entry.path(), getFileNameSectorNum(entry.name()), 0x10000);
    }
  }
  
  //=======================
  // adv modules
  //=======================
  
  {
    TFileManip::FileInfoCollection dirListing;
    TFileManip::getDirectoryListing("out/base/adv", dirListing);
    for (auto entry: dirListing) {
      patchFileBySector(
        ofs, entry.path(), getFileNameSectorNum(entry.name()), 0x20000);
    }
  }
  
  //=======================
  // adv scene modules
  //=======================
  
  {
    TFileManip::FileInfoCollection dirListing;
    TFileManip::getDirectoryListing("out/base/advscene", dirListing);
    for (auto entry: dirListing) {
      patchFileBySector(
        ofs, entry.path(), getFileNameSectorNum(entry.name()), 0x20000);
    }
  }
  
  //=======================
  // visual scene modules
  //=======================
  
  {
    TFileManip::FileInfoCollection dirListing;
    TFileManip::getDirectoryListing("out/base/visual", dirListing);
    for (auto entry: dirListing) {
      patchFileBySector(
        ofs, entry.path(), getFileNameSectorNum(entry.name()), 0x40000);
    }
  }
  
  //=======================
  // kernel
  //=======================
  
  patchFileBySector(
    ofs, "out/base/kernel_D6.bin", 0xD6, 0xA000);
  
  //=======================
  // title
  //=======================
  
  patchFileBySector(
    ofs, "out/base/title_36.bin", 0x36, 0x40000);
  
  //=======================
  // boot
  //=======================
  
  patchFileBySector(
    ofs, "out/base/boot_2.bin", 0x2, 0xA000);
  
  
  
  //=======================
  // VISUAL SCENE DEBUG
  //=======================
  
/*  int startupVisualSceneSectorNum = 0x54CE;
  
  // visual scene to show on new game
  ofs.seek((0x2D6 * 0x800) + 0x406E + 1);
  ofs.writeu16le(startupVisualSceneSectorNum);*/
  
  // visual scene to show at startup
//  ofs.seek(0x2094);
//  ofs.writeu8((startupVisualSceneSectorNum >> 16) & 0xFF);
//  ofs.seek(0x2098);
//  ofs.writeu8((startupVisualSceneSectorNum >> 8) & 0xFF);
//  ofs.seek(0x209C);
//  ofs.writeu8((startupVisualSceneSectorNum) & 0xFF);
  
  //=======================
  // ADV SCENE DEBUG
  //=======================
  
/*  int newGameAdvSceneSectorNum = 0xCC6;
  
  ofs.seek(0x16F08A);
  ofs.writeu16le(newGameAdvSceneSectorNum);*/
  
  
  
  
  
  
  
  
  
/*  patchFileBySector(
    ofs, "out/base/adv_2.bin", 0x2, 0x6000);
  // overwrite unneeded debug executable with scene subtitle data
  patchFileBySector(
    ofs, "out/base/scene01.bin", 0x22 + (2 * 0), 0x1000);
  patchFileBySector(
    ofs, "out/base/scene02.bin", 0x22 + (2 * 1), 0x1000);
  patchFileBySector(
    ofs, "out/base/scene03.bin", 0x22 + (2 * 2), 0x1000);
  patchFileBySector(
    ofs, "out/base/scene04.bin", 0x22 + (2 * 3), 0x1000);
  patchFileBySector(
    ofs, "out/base/scene05.bin", 0x22 + (2 * 4), 0x1000);
  patchFileBySector(
    ofs, "out/base/scene06.bin", 0x22 + (2 * 5), 0x1000);
  // scene_main has been expanded for this hack;
  // the expanded version overwrites the old, broken adv executable
  patchFileBySector(
    ofs, "out/base/scene_main_32.bin", 0x2E1A, 0x6000);
  patchFileBySector(
    ofs, "out/base/starbowl_CA.bin", 0xCA, 0x3800);
  patchFileBySector(
    ofs, "out/base/battle_10A.bin", 0x10A, 0x5000);
  patchFileBySector(
    ofs, "out/script/battleblock_all_206.bin", 0x206, 0x2A4000);
  patchFileBySector(
    ofs, "out/script/text_all_2E7A.bin", 0x2E7A, 0xC8000);
  
  //=====================
  // star bowl subtitles
  //=====================
  
  // overwrite script module 8, which is a blank filler module
  patchFileBySector(ofs, "out/grp/starbowl0.bin",
            0x2EBA + (0 * 2), 0x1000);
  patchFileBySector(ofs, "out/grp/starbowl1.bin",
            0x2EBA + (1 * 2), 0x1000);
  patchFileBySector(ofs, "out/grp/starbowl2.bin",
            0x2EBA + (2 * 2), 0x1000);
  patchFileBySector(ofs, "out/grp/starbowl3.bin",
            0x2EBA + (3 * 2), 0x1000);
  
  //=====================
  // dark queen subtitles
  //=====================
  
  // overwrite script module 7, which is a blank filler module
  patchFileBySector(ofs, "out/grp/darkqueen0.bin",
            0x2EB2 + (0 * 2), 0x1000);
  patchFileBySector(ofs, "out/grp/darkqueen1.bin",
            0x2EB2 + (1 * 2), 0x1000);
  patchFileBySector(ofs, "out/grp/darkqueen2.bin",
            0x2EB2 + (2 * 2), 0x1000);
  patchFileBySector(ofs, "out/grp/darkqueen3.bin",
            0x2EB2 + (3 * 2), 0x1000);
  
  //=====================
  // graphics
  //=====================
  
  patchFileBySector(ofs, "out/rsrc_raw/grp/carderror.bin",
            0x1818A);
  patchFile(ofs, "out/rsrc_raw/grp/logo_ch5.bin",
            0x98B5AD6);
  patchFile(ofs, "out/rsrc_raw/grp/concert.bin",
            0x30D625A);
    // ?
    patchFile(ofs, "out/rsrc_raw/grp/concert.bin",
              0x92E8228);
  patchFile(ofs, "out/rsrc_raw/grp/quiz.bin",
            0x4DB4286);
    // ?
    patchFile(ofs, "out/rsrc_raw/grp/quiz.bin",
              0x5DB4286);
  patchFile(ofs, "out/rsrc_raw/grp/ice.bin",
            0x4D4FA28);
    patchFile(ofs, "out/rsrc_raw/grp/ice.bin",
              0x5D4FA28);
  patchFile(ofs, "out/rsrc_raw/grp/ice2.bin",
            0x4D5CA28);
    patchFile(ofs, "out/rsrc_raw/grp/ice2.bin",
              0x5D5CA28);
  patchFile(ofs, "out/rsrc_raw/grp/ice3.bin",
            0x4AE2228);
    patchFile(ofs, "out/rsrc_raw/grp/ice3.bin",
              0x5AE2228);
  patchFile(ofs, "out/rsrc_raw/grp/ice4.bin",
            0x4AEAA28);
    patchFile(ofs, "out/rsrc_raw/grp/ice4.bin",
              0x5AEAA28);
  patchFile(ofs, "out/rsrc_raw/grp/ice5.bin",
            0x4D76421);
    patchFile(ofs, "out/rsrc_raw/grp/ice5.bin",
              0x5D76421);
  patchFile(ofs, "out/rsrc_raw/grp/bathsign.bin",
            0x7978AE5);
    patchFile(ofs, "out/rsrc_raw/grp/bathsign.bin",
              0x7996AE5);
  patchFile(ofs, "out/rsrc_raw/grp/bathsign2.bin",
            0x7ACED30);
  patchFile(ofs, "out/rsrc_raw/grp/hatopoppo.bin",
            0x31A3228);
    patchFile(ofs, "out/rsrc_raw/grp/hatopoppo.bin",
              0x3954A28);
  
  patchFile(ofs, "out/rsrc_raw/grp/battle_empty.bin",
            0x91400);
  
  patchFile(ofs, "out/rsrc_raw/grp/elline_name.bin",
            0x9EA00);
    patchFile(ofs, "out/rsrc_raw/grp/elline_name.bin",
              0xAEA00);
    patchFile(ofs, "out/rsrc_raw/grp/elline_name.bin",
              0xBEA00);
  
  patchFile(ofs, "out/rsrc_raw/grp/finisher.bin",
            0xA1400);
    patchFile(ofs, "out/rsrc_raw/grp/finisher.bin",
              0xB1400);
    patchFile(ofs, "out/rsrc_raw/grp/finisher.bin",
              0xC1400);
  
  patchFile(ofs, "out/rsrc_raw/grp/anderope_intro.bin",
            0x9A6646E);
  
  patchFile(ofs, "out/rsrc_raw/grp/spaceduck_label.bin",
            0x55400);
  
  //=====================
  // adv interface vram
  //=====================
  
//  patchFile(ofs, "out/rsrc_raw/grp/interface_vram_raw.bin",
//            0x18531C0 - 0x19C0);
  patchFile(ofs, "out/rsrc_raw/grp/interface_vram_raw.bin",
            0x1851800);
  patchFile(ofs, "out/rsrc_raw/grp/interface_vram_raw.bin",
            0x3851800);
  patchFile(ofs, "out/rsrc_raw/grp/interface_vram_raw.bin",
            0x5851800);
  patchFile(ofs, "out/rsrc_raw/grp/interface_vram_raw.bin",
            0x7851800);
  patchFile(ofs, "out/rsrc_raw/grp/interface_vram_raw.bin",
            0x9051800);
  patchFile(ofs, "out/rsrc_raw/grp/interface_vram_raw.bin",
            0x9851800);
  
  //=====================
  // adv graphics
  //=====================
  
//  patchFileBySector(ofs, "out/rsrc_raw/advgrp/TIT.GRP",
//            0x30C4);
  // title screen (i think only the first one is used but w/e)
  patchFile(ofs, "out/rsrc_raw/advgrp/TIT.GRP",
            0x1862000);
  patchFile(ofs, "out/rsrc_raw/advgrp/TIT.GRP",
            0x3862000);
  patchFile(ofs, "out/rsrc_raw/advgrp/TIT.GRP",
            0x5862000);
  patchFile(ofs, "out/rsrc_raw/advgrp/TIT.GRP",
            0x7862000);
  patchFile(ofs, "out/rsrc_raw/advgrp/TIT.GRP",
            0x9862000);
  
  patchFile(ofs, "out/grp/tv_grp.bin",
            0x18E5AC5);
    patchFile(ofs, "out/grp/tv_grp.bin",
              0x30D3DC4);
    patchFile(ofs, "out/grp/tv_grp.bin",
              0x90E5AC5);
  patchFile(ofs, "out/grp/tv_spr.bin",
            0x18E1A2A);
    patchFile(ofs, "out/grp/tv_spr.bin",
              0x30CFD29);
    patchFile(ofs, "out/grp/tv_spr.bin",
              0x90E1A3B);
  
  patchFile(ofs, "out/grp/newschool_grp.bin",
            0x1A3232B+0x1900);
    patchFile(ofs, "out/grp/newschool_grp.bin",
              0x923232B+0x1900);
//  patchFile(ofs, "out/grp/newschool_spr.bin",
//            0x1A36605);
//    patchFile(ofs, "out/grp/newschool_spr.bin",
//              0x9236605);
  patchFile(ofs, "out/grp/newschool_spr.bin",
            0x1A366A6);
    patchFile(ofs, "out/grp/newschool_spr.bin",
              0x92366A6);
  
  patchFile(ofs, "out/grp/gon_grp.bin",
            0x78BFA9D+0xC00);
    patchFile(ofs, "out/grp/gon_grp.bin",
              0x78F4A99+0xC00);
  patchFile(ofs, "out/grp/gon_spr.bin",
            0x78C3AE2);
    patchFile(ofs, "out/grp/gon_spr.bin",
              0x78F8ADE);
  
  patchFile(ofs, "out/rsrc_raw/grp/doka.bin",
            0x1ACF2A0);
    patchFile(ofs, "out/rsrc_raw/grp/doka.bin",
              0x92CF2A0);
  
  patchFile(ofs, "out/rsrc_raw/grp/broadcast.bin",
            0x1AD9B36);
    patchFile(ofs, "out/rsrc_raw/grp/broadcast.bin",
              0x92D9B36);
  
  patchFile(ofs, "out/grp/continued.bin",
            0x1C0D623);
    patchFile(ofs, "out/grp/continued.bin",
              0x940D623);
  
  patchFile(ofs, "out/rsrc_raw/grp/diagram.bin",
            0x1D74A80);
    patchFile(ofs, "out/rsrc_raw/grp/diagram.bin",
              0x9574A5B);
  
  patchFile(ofs, "out/rsrc_raw/grp/windmtn.bin",
            0x4DDFA28);
    patchFile(ofs, "out/rsrc_raw/grp/windmtn.bin",
              0x5DDFA28);
    patchFile(ofs, "out/rsrc_raw/grp/windmtn.bin",
              0x72CDC50);
  
  patchFile(ofs, "out/rsrc_raw/grp/ferriswheel.bin",
            0x49ABA28);
    patchFile(ofs, "out/rsrc_raw/grp/ferriswheel.bin",
              0x59ABA28);
  
  //=====================
  // intro sub overlays
  //=====================
  
  patchFile(ofs, "out/rsrc_raw/grp/intro_subgrp1_cmp.bin",
            0x40050C);
  patchFile(ofs, "out/rsrc_raw/grp/intro_subgrp1_def_cmp.bin",
            0x3FFCCD);
  
  patchFile(ofs, "out/rsrc_raw/grp/intro_subgrp2_cmp.bin",
            0x429F66);
  patchFile(ofs, "out/rsrc_raw/grp/intro_subgrp2_def_cmp.bin",
            0x429C48);
  
  //=====================
  // eyecatches
  //=====================
  
  patchFile(ofs, "out/grp/logo_eyecatch_grp.bin",
            0x18C4353);
  patchFile(ofs, "out/grp/logo_eyecatch_grp.bin",
            0x38C2353);
  patchFile(ofs, "out/grp/logo_eyecatch_grp.bin",
            0x496D353);
  patchFile(ofs, "out/grp/logo_eyecatch_grp.bin",
            0x58B3353);
  patchFile(ofs, "out/grp/logo_eyecatch_grp.bin",
            0x5DDEE25);
  // ch. 3 special eyecatch 1 (leaving ice planet)
  patchFile(ofs, "out/grp/logo_eyecatch2_grp.bin",
            0x72FC789 - 0x600);
  // ch. 3 special eyecatch 2 (after space duck)
//  patchFile(ofs, "out/grp/logo_eyecatch_grp.bin",
//            0x7303789);
  patchFile(ofs, "out/grp/logo_eyecatch2_grp.bin",
            0x72FDF89 + (0x2900 * 2));
  patchFile(ofs, "out/grp/logo_eyecatch_grp.bin",
            0x78B3353);
  patchFile(ofs, "out/grp/logo_eyecatch_grp.bin",
            0x7A4DB53);
  patchFile(ofs, "out/grp/logo_eyecatch_grp.bin",
            0x8846B53);
  patchFile(ofs, "out/grp/logo_eyecatch_grp.bin",
            0x9C66353);
  patchFile(ofs, "out/grp/logo_eyecatch_grp.bin",
            0x9E19353);*/
  
  ofs.save(outfile.c_str());
  
  return 0;
}

