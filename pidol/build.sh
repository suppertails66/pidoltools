
echo "*******************************************************************************"
echo "Setting up environment..."
echo "*******************************************************************************"

set -o errexit

BASE_PWD=$PWD
PATH=".:$PATH"
INROM="pidol_02.iso"
OUTROM="pidol_02_build.iso"
WLADX="./wla-dx/binaries/wla-huc6280"
WLALINK="./wla-dx/binaries/wlalink"
DISCASTER="../discaster/discaster"

function remapPalette() {
  oldFile=$1
  palFile=$2
  newFile=$3
  
  convert "$oldFile" -dither None -remap "$palFile" PNG32:$newFile
}

function remapPaletteOverwrite() {
  newFile=$1
  palFile=$2
  
  remapPalette $newFile $palFile $newFile
}

#remapPalette "rsrc/grp/title_options.png" "rsrc/grp/orig/title_options.png" "test_remap.png"
# remapPaletteOverwrite "rsrc/grp/title_options.png" "rsrc/grp/orig/title_options.png"
# remapPaletteOverwrite "rsrc/grp/title_files_0.png" "rsrc/grp/orig/title_files_0_color.png"
# remapPaletteOverwrite "rsrc/grp/title_files_1.png" "rsrc/grp/orig/title_files_1_color.png"
# remapPaletteOverwrite "rsrc/grp/title_files_2.png" "rsrc/grp/orig/title_files_2_color.png"
# remapPaletteOverwrite "rsrc/grp/title_files_3.png" "rsrc/grp/orig/title_files_3_color.png"
# remapPaletteOverwrite "rsrc/grp/title_files_4.png" "rsrc/grp/orig/title_files_4_color.png"
# remapPaletteOverwrite "rsrc/grp/title_files_script.png" "rsrc/grp/orig/title_files_script.png"
# remapPaletteOverwrite "rsrc/grp/title_bonus_0-0.png" "rsrc/grp/orig/title_bonus_0-0.png"
# exit

mkdir -p out

echo "********************************************************************************"
echo "Building project tools..."
echo "********************************************************************************"

make blackt
make libpce
make

if [ ! -f $WLADX ]; then
  
  echo "********************************************************************************"
  echo "Building WLA-DX..."
  echo "********************************************************************************"
  
  cd wla-dx
    cmake -G "Unix Makefiles" .
    make
  cd $BASE_PWD
  
fi

echo "*******************************************************************************"
echo "Copying binaries..."
echo "*******************************************************************************"

cp -r base out
cp -r rsrc_raw out

cp "$INROM" "$OUTROM"

echo "*******************************************************************************"
echo "Building font..."
echo "*******************************************************************************"

numFontChars=96
#numLimitedFontChars=80
bytesPerFontChar=10

mkdir -p out/font
fontbuild "font/" "out/font/font.bin" "out/font/fontwidth.bin"
fontbuild "font/scene/" "out/font/font_scene.bin" "out/font/fontwidth_scene.bin"
fontbuild "font/narrow/" "out/font/font_narrow.bin" "out/font/fontwidth_narrow.bin"
fontbuild "font/mecos/" "out/font/font_mecos.bin" "out/font/fontwidth_mecos.bin"

echo "*******************************************************************************"
echo "Building script..."
echo "*******************************************************************************"

mkdir -p out/scripttxt
mkdir -p out/scriptwrap
mkdir -p out/script

pidol_scriptimport

pidol_scriptwrap "out/scripttxt/spec_main.txt" "out/scriptwrap/spec_main.txt"
pidol_scriptwrap "out/scripttxt/spec_advscene.txt" "out/scriptwrap/spec_advscene.txt" "table/pidol_scenes_en.tbl" "out/font/fontwidth_scene.bin" 0x20
pidol_scriptwrap "out/scripttxt/spec_visual.txt" "out/scriptwrap/spec_visual.txt" "table/pidol_scenes_en.tbl" "out/font/fontwidth_scene.bin" 0x20
pidol_scriptwrap "out/scripttxt/spec_misc.txt" "out/scriptwrap/spec_misc.txt" "table/pidol_scenes_en.tbl" "out/font/fontwidth_scene.bin" 0x20
pidol_scriptwrap "out/scripttxt/spec_8x8.txt" "out/scriptwrap/spec_8x8.txt" "table/ascii.tbl" "out/font/fontwidth_mecos.bin" 0x0 1
pidol_scriptwrap "out/scripttxt/spec_credits.txt" "out/scriptwrap/spec_credits.txt" "table/pidol_scenes_en.tbl" "out/font/fontwidth_scene.bin" 0x20
cp "out/scripttxt/spec_creditstext.txt" "out/scriptwrap/spec_creditstext.txt"
cp "out/scripttxt/spec_backutil.txt" "out/scriptwrap/spec_backutil.txt"
#pidol_scriptwrap "out/scripttxt/spec_creditstext.txt" "out/scriptwrap/spec_creditstext.txt" "table/pidol_credits_en.tbl" "out/font/fontwidth.bin" 0x20

pidol_scriptbuild "out/scriptwrap/" "out/script/"

echo "*******************************************************************************"
echo "Generating text images..."
echo "*******************************************************************************"

mkdir -p out/grp
mkdir -p out/maps

function renderStringMecos_WOB() {
  scrdat_render "font/mecos/" "font/mecos/table.tbl" "$2" "table/ascii.tbl" "$1.png"\
    --fgcolor 0xFF 0xFF 0xFF --bgcolor 0 0 0 -w 256 -h 224
}

function renderStringMecos_nobg() {
  scrdat_render "font/mecos/" "font/mecos/table.tbl" "$2" "table/ascii.tbl" "$1.png"\
    --fgcolor 0xFF 0xFF 0xFF -w 256 -h 224
}

function renderStringMecos_yellow() {
  scrdat_render "font/mecos/" "font/mecos/table.tbl" "$2" "table/ascii.tbl" "$1.png"\
    --fgcolor 0xFF 0xDA 0x00 -w 256 -h 224
}

function renderStringReport_bg() {
  scrdat_render "font/report_bold/" "font/report_bold/table.tbl" "$2" "table/ascii.tbl" "$1.png"\
    --fgcolor 0x00 0x00 0x00 --bgcolor 0xDA 0xDA 0xB6 -w 256 -h 176
}

function renderStringReport_nobg() {
  scrdat_render "font/report/" "font/report/table.tbl" "$2" "table/ascii.tbl" "$1.png"\
    --fgcolor 0x00 0x00 0x00 -w 256 -h 176
}

function renderStringReport2_bgbold() {
  scrdat_render "font/report_bold/" "font/report_bold/table.tbl" "$2" "table/ascii.tbl" "$1.png"\
    --fgcolor 0x24 0x24 0x48 --bgcolor 0xDA 0xDA 0xB6 -w 256 -h 176
}

function renderStringReport2_bg() {
  scrdat_render "font/report/" "font/report/table.tbl" "$2" "table/ascii.tbl" "$1.png"\
    --fgcolor 0x24 0x24 0x48 --bgcolor 0xDA 0xDA 0xB6 -w 256 -h 176
}

function renderStringReport2_nobg() {
  scrdat_render "font/report/" "font/report/table.tbl" "$2" "table/ascii.tbl" "$1.png"\
    --fgcolor 0x24 0x24 0x48 -w 256 -h 176
}

function renderStringCafe_white() {
  scrdat_render "font/report/" "font/report/table.tbl" "$2" "table/ascii.tbl" "$1.png"\
    --fgcolor 0xFF 0xFF 0xFF -w 128 -h 16
}

# "insert disk"
renderStringMecos_WOB "out/grp/case3_pc_0-0" "out/script/strings/case3-pc-4.bin"
renderStringMecos_yellow "out/grp/case3_pc_0-0_overlay" "out/script/strings/case3-pc-5.bin"
convert "out/grp/case3_pc_0-0.png"\
  "out/grp/case3_pc_0-0_overlay.png" -geometry +0+0 -composite\
  PNG32:out/grp/case3_pc_0-0.png

# startup messages
cp "rsrc/grp/orig/case3_pc_1-0.png" "out/grp/case3_pc_1-0.png"
# fake msg 1
renderStringMecos_WOB "out/grp/case3_pc_1-1" "out/script/strings/case3-pc-0.bin"
# fake msg 2
renderStringMecos_WOB "out/grp/case3_pc_1-2" "out/script/strings/case3-pc-1.bin"

# real msg 1
renderStringMecos_WOB "out/grp/case3_pc_2-0" "out/script/strings/case3-pc-2.bin"
cp "out/grp/case3_pc_2-0.png" "out/grp/case3_pc2_0-0.png"

# real msg 2
#renderStringMecos_WOB "out/grp/case3_pc_2-1" "out/script/strings/case3-pc-3.bin"
renderStringMecos_nobg "out/grp/case3_pc_2-1_overlay1" "out/script/strings/case3-pc-6.bin"
renderStringMecos_nobg "out/grp/case3_pc_2-1_overlay2" "out/script/strings/case3-pc-7.bin"
convert -size 256x224 xc:black\
  "out/grp/case3_pc_2-1_overlay1.png" -geometry +0+64 -composite\
  "out/grp/case3_pc_2-1_overlay2.png" -geometry +0+144 -composite\
  PNG32:out/grp/case3_pc_2-1.png
convert -size 256x224 xc:black\
  "out/grp/case3_pc_2-1_overlay1.png" -geometry +0+48 -composite\
  "out/grp/case3_pc_2-1_overlay2.png" -geometry +0+112 -composite\
  PNG32:out/grp/case3_pc2_0-1.png
# # TODO: there are two different versions of this message, one used in adv-0x34C2
# # and one in adv-0x36C2. in the latter, the second screen is shifted upward slightly
# # (presumably so the message window can fit over it),
# # but i'm leaving them identical for now
# cp "out/grp/case3_pc_2-1.png" "out/grp/case3_pc2_0-1.png"

renderStringReport_bg "out/grp/autopsy_0-0" "out/script/strings/autopsy-1.bin"
renderStringReport_nobg "out/grp/autopsy_0-0_overlay" "out/script/strings/autopsy-2.bin"
convert "out/grp/autopsy_0-0.png"\
  "out/grp/autopsy_0-0_overlay.png" -geometry +0+0 -composite\
  "rsrc/grp/autopsy_kubota.png" -geometry +120+144 -composite\
  "rsrc/grp/autopsy_ohtaki.png" -geometry +200+136 -composite\
  PNG32:out/grp/autopsy_0-0.png
  
renderStringReport_nobg "out/grp/cafe_0-0_menu" "out/script/strings/cafe-0.bin"
renderStringReport_nobg "out/grp/cafe_0-0_selector" "out/script/strings/cafe-1.bin"
convert "rsrc/grp/cafe_0-0.png"\
  "out/grp/cafe_0-0_menu.png" -geometry +24+32 -composite\
  "out/grp/cafe_0-0_selector.png" -geometry +144+16 -composite\
  PNG32:out/grp/cafe_0-0.png

#renderStringReport2_bg "out/grp/autopsy2_0-0" "out/script/strings/autopsy2-0.bin"
renderStringReport2_bgbold "out/grp/autopsy2_0-0" "out/script/strings/autopsy2-2.bin"
renderStringReport2_nobg "out/grp/autopsy2_0-0_overlay" "out/script/strings/autopsy2-3.bin"
convert "out/grp/autopsy2_0-0.png"\
  "out/grp/autopsy2_0-0_overlay.png" -geometry +0+0 -composite\
 "rsrc/grp/autopsy2_kubota.png" -geometry +120+128 -composite\
  PNG32:out/grp/autopsy2_0-0.png

renderStringReport2_bg "out/grp/autopsy2_1-0" "out/script/strings/autopsy2-1.bin"

rm -rf "out/font/cafe"
cp -r "font/cafe" "out/font"
renderStringCafe_white "out/font/cafe/sheet" "out/script/strings/cafe-2.bin"
fontbuild "out/font/cafe/" "out/font/font_cafe.bin" "out/font/fontwidth_cafe.bin" 8

echo "*******************************************************************************"
echo "Building graphics..."
echo "*******************************************************************************"

mkdir -p out/grp
mkdir -p out/maps

remapPalette "rsrc/grp/scene2b_title_0-0.png" "rsrc/grp/orig/scene2b_title_0-0.png" "out/grp/scene2b_title_0-0.png"
remapPalette "rsrc/grp/scene3_title_0-0.png" "rsrc/grp/orig/scene3_title_0-0.png" "out/grp/scene3_title_0-0.png"

remapPalette "rsrc/grp/intro_splash3.png" "rsrc/grp/orig/intro_splash3.png" "out/grp/intro_splash3.png"
remapPalette "rsrc/grp/intro_splash4.png" "rsrc/grp/orig/intro_splash4.png" "out/grp/intro_splash4.png"
remapPalette "rsrc/grp/intro_splash5.png" "rsrc/grp/orig/intro_splash5.png" "out/grp/intro_splash5.png"
remapPalette "rsrc/grp/intro_disclaimer.png" "rsrc/grp/orig/intro_disclaimer.png" "out/grp/intro_disclaimer.png"

remapPalette "rsrc/grp/syscard_error_0-0.png" "rsrc/grp/orig/syscard_error_0-0.png" "out/grp/syscard_error_0-0.png"

for file in tilemappers/*.txt; do
  tilemapper_pce "$file"
done;

datpatch "out/base/adv/adv-0x34C2.bin" "out/base/adv/adv-0x34C2.bin" "out/grp/case3_pc_0.bin" 0x2000
datpatch "out/base/adv/adv-0x34C2.bin" "out/base/adv/adv-0x34C2.bin" "out/maps/case3_pc_0-0.bin" 0x7E00

datpatch "out/base/adv/adv-0x34C2.bin" "out/base/adv/adv-0x34C2.bin" "out/grp/case3_pc_1.bin" 0x2300
datpatch "out/base/adv/adv-0x34C2.bin" "out/base/adv/adv-0x34C2.bin" "out/maps/case3_pc_1-0.bin" 0x8500
datpatch "out/base/adv/adv-0x34C2.bin" "out/base/adv/adv-0x34C2.bin" "out/maps/case3_pc_1-1.bin" 0x8C00
datpatch "out/base/adv/adv-0x34C2.bin" "out/base/adv/adv-0x34C2.bin" "out/maps/case3_pc_1-2.bin" 0x9300

datpatch "out/base/adv/adv-0x34C2.bin" "out/base/adv/adv-0x34C2.bin" "out/grp/case3_pc_2.bin" 0x4B00
datpatch "out/base/adv/adv-0x34C2.bin" "out/base/adv/adv-0x34C2.bin" "out/maps/case3_pc_2-0.bin" 0x9A00
datpatch "out/base/adv/adv-0x34C2.bin" "out/base/adv/adv-0x34C2.bin" "out/maps/case3_pc_2-1.bin" 0xA100

datpatch "out/base/adv/adv-0x36C2.bin" "out/base/adv/adv-0x36C2.bin" "out/grp/case3_pc2_0.bin" 0x2000
datpatch "out/base/adv/adv-0x36C2.bin" "out/base/adv/adv-0x36C2.bin" "out/maps/case3_pc2_0-0.bin" 0x4F00
datpatch "out/base/adv/adv-0x36C2.bin" "out/base/adv/adv-0x36C2.bin" "out/maps/case3_pc2_0-1.bin" 0x5600

pidol_puzzlebuild "rsrc/grp/puzzle.png" "rsrc/grp/puzzle_mask.png" "rsrc_raw/pal/puzzle_bg_line.pal" "out/grp/puzzle_grp.bin"
datpatch "out/base/adv/adv-0x3582.bin" "out/base/adv/adv-0x3582.bin" "out/grp/puzzle_grp.bin" 0x5200

datpatch "out/base/adv/adv-0x3502.bin" "out/base/adv/adv-0x3502.bin" "out/grp/autopsy_0.bin" 0x2000
datpatch "out/base/adv/adv-0x3502.bin" "out/base/adv/adv-0x3502.bin" "out/maps/autopsy_0-0.bin" 0x4B00

datpatch "out/base/advscene/advscene-0x3602.bin" "out/base/advscene/advscene-0x3602.bin" "out/grp/cafe_0.bin" 0x2000
datpatch "out/base/advscene/advscene-0x3602.bin" "out/base/advscene/advscene-0x3602.bin" "out/maps/cafe_0-0.bin" 0x3200

datpatch "out/base/adv/adv-0x37C2.bin" "out/base/adv/adv-0x37C2.bin" "out/grp/autopsy2_0.bin" 0x2000
datpatch "out/base/adv/adv-0x37C2.bin" "out/base/adv/adv-0x37C2.bin" "out/grp/autopsy2_1.bin" 0x4000
datpatch "out/base/adv/adv-0x37C2.bin" "out/base/adv/adv-0x37C2.bin" "out/maps/autopsy2_0-0.bin" 0x6A00
datpatch "out/base/adv/adv-0x37C2.bin" "out/base/adv/adv-0x37C2.bin" "out/maps/autopsy2_1-0.bin" 0x7000

remapPalette "rsrc/grp/scene1_title.png" "rsrc/grp/orig/scene1_title.png" "out/grp/scene1_title.png"
spritebuild_pce "out/grp/scene1_title.png" "rsrc/grp/scene1_title.txt" "rsrc_raw/pal/scene1_title_raw.pal" "out/grp/scene1_title_grp.bin"
pidol_spriteprep "out/grp/scene1_title_spr.bin"
pidol_spriteprep "out/grp/scene1_subtitle_spr.bin"
datpatch "out/base/adv/adv-0xBC6.bin" "out/base/adv/adv-0xBC6.bin" "out/grp/scene1_title_grp.bin" 0xC400

remapPalette "rsrc/grp/scene2a_title.png" "rsrc/grp/orig/scene2a_title.png" "out/grp/scene2a_title.png"
spritebuild_pce "out/grp/scene2a_title.png" "rsrc/grp/scene2a_title.txt" "rsrc_raw/pal/scene2a_title_raw.pal" "out/grp/scene2a_title_grp.bin"
pidol_spriteprep "out/grp/scene2a_title_spr.bin"
pidol_spriteprep "out/grp/scene2a_subtitle0_spr.bin"
pidol_spriteprep "out/grp/scene2a_subtitle1_spr.bin"
pidol_spriteprep "out/grp/scene2a_subtitle2_spr.bin"
pidol_spriteprep "out/grp/scene2a_subtitle3_spr.bin"
pidol_spriteprep "out/grp/scene2a_subtitle4_spr.bin"
datpatch "out/base/visual/visual-0x4E4E.bin" "out/base/visual/visual-0x4E4E.bin" "out/grp/scene2a_title_grp.bin" 0x2B700

datpatch "out/base/advscene/advscene-0x1FFE.bin" "out/base/advscene/advscene-0x1FFE.bin" "out/grp/scene2b_title_0.bin" 0x6800
datpatch "out/base/advscene/advscene-0x1FFE.bin" "out/base/advscene/advscene-0x1FFE.bin" "out/maps/scene2b_title_0-0.bin" 0x4000 0 0x700

datpatch "out/base/adv/adv-0x3742.bin" "out/base/adv/adv-0x3742.bin" "out/grp/scene3_title_0.bin" 0xF000
datpatch "out/base/adv/adv-0x3742.bin" "out/base/adv/adv-0x3742.bin" "out/maps/scene3_title_0-0.bin" 0xC000 0 0x700

spritebuild_pce "rsrc/grp/title_files.png" "rsrc/grp/title_files.txt" "rsrc_raw/pal/title_spr_raw.pal" "out/grp/title_files_grp.bin"
pidol_spriteprep_title "out/grp/title_files_0_spr.bin" "out/grp/title_files_0_off_spr.bin" -forcepal 0
pidol_spriteprep_title "out/grp/title_files_1_spr.bin" "out/grp/title_files_1_off_spr.bin" -forcepal 0
pidol_spriteprep_title "out/grp/title_files_2_spr.bin" "out/grp/title_files_2_off_spr.bin" -forcepal 0
pidol_spriteprep_title "out/grp/title_files_3_spr.bin" "out/grp/title_files_3_off_spr.bin" -forcepal 0
pidol_spriteprep_title "out/grp/title_files_4_spr.bin" "out/grp/title_files_4_off_spr.bin" -forcepal 0
pidol_spriteprep_title "out/grp/title_files_0_spr.bin"
pidol_spriteprep_title "out/grp/title_files_1_spr.bin"
pidol_spriteprep_title "out/grp/title_files_2_spr.bin"
pidol_spriteprep_title "out/grp/title_files_3_spr.bin"
pidol_spriteprep_title "out/grp/title_files_4_spr.bin"

spritebuild_pce "rsrc/grp/title_options.png" "rsrc/grp/title_options.txt" "rsrc_raw/pal/title_spr_raw.pal" "out/grp/title_options_grp.bin"
pidol_spriteprep_title "out/grp/title_options_0_spr.bin"
pidol_spriteprep_title "out/grp/title_options_1_spr.bin"
pidol_spriteprep_title "out/grp/title_options_2_spr.bin"

cat "out/grp/title_files_grp.bin" "out/grp/title_options_grp.bin" > "out/grp/title_files_grp_asm.bin"
datpatch "out/base/title_36.bin" "out/base/title_36.bin" "out/grp/title_files_grp_asm.bin" 0x16000

datpatch "out/base/title_36.bin" "out/base/title_36.bin" "out/grp/title_bonus_0.bin" 0x8400
datpatch "out/base/title_36.bin" "out/base/title_36.bin" "out/maps/title_bonus_0-0.bin" 0x1E000

spritebuild_pce "rsrc/grp/backutil_buttons.png" "rsrc/grp/backutil_buttons.txt" "rsrc_raw/pal/backutil_spr_raw.pal" "out/grp/backutil_buttons_grp.bin"
datpatch "out/base/title_36.bin" "out/base/title_36.bin" "out/grp/backutil_buttons_grp.bin" 0x6540

pidol_tilemapmerge "rsrc_raw/maps/intro_splash3.bin" "out/maps/intro_splash3.bin" 0x80 0x104 "out/maps/intro_splash3.bin"
pidol_tilemapmerge "rsrc_raw/maps/intro_splash4.bin" "out/maps/intro_splash4.bin" 0x80 0xE7 "out/maps/intro_splash4.bin"
pidol_tilemapmerge "rsrc_raw/maps/intro_splash5.bin" "out/maps/intro_splash5.bin" 0x80 0x89 "out/maps/intro_splash5.bin"

datpatch "out/base/visual/visual-0x544E.bin" "out/base/visual/visual-0x544E.bin" "out/maps/intro_splash3.bin" 0x2FA00
datpatch "out/base/visual/visual-0x544E.bin" "out/base/visual/visual-0x544E.bin" "out/maps/intro_splash4.bin" 0x30A00
datpatch "out/base/visual/visual-0x544E.bin" "out/base/visual/visual-0x544E.bin" "out/maps/intro_splash5.bin" 0x31400
datpatch "out/base/visual/visual-0x544E.bin" "out/base/visual/visual-0x544E.bin" "out/maps/intro_disclaimer.bin" 0x2D300

datpatch "out/base/visual/visual-0x544E.bin" "out/base/visual/visual-0x544E.bin" "out/grp/intro_splash3.bin" 0x34600
datpatch "out/base/visual/visual-0x544E.bin" "out/base/visual/visual-0x544E.bin" "out/grp/intro_splash4.bin" 0x35A00
datpatch "out/base/visual/visual-0x544E.bin" "out/base/visual/visual-0x544E.bin" "out/grp/intro_splash5.bin" 0x36700
#datpatch "out/base/visual/visual-0x544E.bin" "out/base/visual/visual-0x544E.bin" "out/grp/intro_disclaimer.bin" 0x37C00
#datpatch "out/base/visual/visual-0x544E.bin" "out/base/visual/visual-0x544E.bin" "out/grp/intro_disclaimer.bin" 0x3E000
datpatch "out/base/visual/visual-0x544E.bin" "out/base/visual/visual-0x544E.bin" "out/grp/intro_disclaimer.bin" 0x70A0 0x0 0xF60
datpatch "out/base/visual/visual-0x544E.bin" "out/base/visual/visual-0x544E.bin" "out/grp/intro_disclaimer.bin" 0x37400 0xF60

datpatch "out/base/boot_2.bin" "out/base/boot_2.bin" "out/maps/syscard_error_0-0.bin" 0x6B40
datpatch "out/base/boot_2.bin" "out/base/boot_2.bin" "out/grp/syscard_error_0.bin" 0x2000 0x0 0x49C0
datpatch "out/base/boot_2.bin" "out/base/boot_2.bin" "out/grp/syscard_error_0.bin" 0x7800 0x49C0

#datpatch "out/base/adv/adv-0x1FBE.bin" "out/base/adv/adv-0x1FBE.bin" "out/grp/case2b_map_0.bin" 0x2000 0x0 0x5740
datpatch "out/base/adv/adv-0x1FBE.bin" "out/base/adv/adv-0x1FBE.bin" "out/grp/case2b_map_0.bin" 0x2000 0x0 0x5800
datpatch "out/base/adv/adv-0x1FBE.bin" "out/base/adv/adv-0x1FBE.bin" "out/grp/case2b_map_0.bin" 0x1FE00 0x5800
datpatch "out/base/adv/adv-0x1FBE.bin" "out/base/adv/adv-0x1FBE.bin" "out/maps/case2b_map_0-0.bin" 0x1CE00

pidol_case2bmap_prep "out/maps/case2b_map_0-0.bin" "out/maps/case2b_map_0-0_patch_table.bin"
datpatch "out/base/area/area-0x1EBE.bin" "out/base/area/area-0x1EBE.bin" "out/maps/case2b_map_0-0_patch_table.bin" 0x1A49
datpatch "out/base/area/area-0x1EDE.bin" "out/base/area/area-0x1EDE.bin" "out/maps/case2b_map_0-0_patch_table.bin" 0x1A49
datpatch "out/base/area/area-0x1EFE.bin" "out/base/area/area-0x1EFE.bin" "out/maps/case2b_map_0-0_patch_table.bin" 0x1A49
datpatch "out/base/area/area-0x1F1E.bin" "out/base/area/area-0x1F1E.bin" "out/maps/case2b_map_0-0_patch_table.bin" 0x1A49
datpatch "out/base/area/area-0x1F3E.bin" "out/base/area/area-0x1F3E.bin" "out/maps/case2b_map_0-0_patch_table.bin" 0x1A49
datpatch "out/base/area/area-0x1F5E.bin" "out/base/area/area-0x1F5E.bin" "out/maps/case2b_map_0-0_patch_table.bin" 0x1A49
datpatch "out/base/area/area-0x1F9E.bin" "out/base/area/area-0x1F9E.bin" "out/maps/case2b_map_0-0_patch_table.bin" 0x1A49

echo "********************************************************************************"
echo "Applying ASM patches..."
echo "********************************************************************************"

function applyAsmPatch() {
  infile=$1
  asmname=$2
#  nolink=$3
  
#  if [ $nolink == "" ]; then
#    nolink=0
#  fi
  
  infile_base=$(basename $infile)
  infile_base_noext=$(basename $infile .bin)
  
  linkfile=${asmname}_link
  
  echo "******************************"
  echo "patching: $asmname"
  echo "******************************"
  
  # generate linkfile
  printf "[objects]\n${asmname}.o" >"asm/$linkfile"
  
  cp "$infile" "asm/$infile_base"
  
  cd asm
    # apply hacks
    ../$WLADX -I ".." -D ROMNAME_BASE="${infile_base_noext}" -D ROMNAME="${infile_base}" -D ROMNAME_GEN_INC="gen/${infile_base_noext}.inc" -o "$asmname.o" "$asmname.s"
    ../$WLALINK -v -S "$linkfile" "${infile_base}_build"
  cd $BASE_PWD
  
  mv -f "asm/${infile_base}_build" "out/base/${infile_base}"
  rm "asm/${infile_base}"
  
  rm asm/*.o
  
  # delete linkfile
  rm "asm/$linkfile"
}

# function applyAsmPatchScene() {
#   infile=$1
#   asmname=$2
#   infile_base=$(basename $infile)
#   
#   applyAsmPatch "$1" "$2"
#   mv "out/base/${infile_base}" "out/base/$asmname.bin"
# }

function applyAsmPatchScene() {
  infile=$1
  asmfile=$2
  infile_base=$(basename $infile)
  asmfile_base=$(basename $asmfile)
  asmfile_noext=$(basename $asmfile .s)
  
#  echo $infile $asmfile $infile_base $asmfile_base
  
  cp "$asmfile" "asm"
#  cp "$infile" "asm"
    applyAsmPatch "$infile" "$asmfile_noext"
  rm -f "asm/$asmfile_base"
#  mv -f "asm/$infile_base" "$infile"
  mv -f "out/base/$infile_base" "$infile"
}

# # we're expanding this file, and wla-dx won't accept .background commands
# # if the filesize doesn't match the rom map, so we have to pad it ourself
# datpad "out/base/scene_main_32.bin" 0x6000
# 
# applyAsmPatch "out/base/adv_2.bin" "adv"
# applyAsmPatch "out/base/scene_main_32.bin" "scene_main"
# applyAsmPatch "out/base/starbowl_CA.bin" "starbowl"
# applyAsmPatch "out/base/battle_10A.bin" "battle"
# 
# applyAsmPatchScene "base/scene_dummy.bin" "scene01"
# applyAsmPatchScene "base/scene_dummy.bin" "scene02"
# applyAsmPatchScene "base/scene_dummy.bin" "scene03"
# applyAsmPatchScene "base/scene_dummy.bin" "scene04"
# applyAsmPatchScene "base/scene_dummy.bin" "scene05"
# applyAsmPatchScene "base/scene_dummy.bin" "scene06"


# HACK: advscenes with both text and subtitles
cp "out/base/adv/adv-0x22FE.bin" "out/base/advscene/advscene-0x22FE.bin"
cp "out/base/adv/adv-0x3542.bin" "out/base/advscene/advscene-0x3542.bin"
cp "out/base/adv/adv-0x3982.bin" "out/base/advscene/advscene-0x3982.bin"

  #################
  # advscenes
  #################

  for file in asm/advscene/*.s; do
    infile_base=$(basename $file .s)
    infile=out/base/advscene/$infile_base.bin
    
  #  echo $file $infile_base $infile
    applyAsmPatchScene "$infile" "$file"
  done

# HACK
cp "out/base/advscene/advscene-0x22FE.bin" "out/base/adv/adv-0x22FE.bin"
cp "out/base/advscene/advscene-0x3542.bin" "out/base/adv/adv-0x3542.bin"
cp "out/base/advscene/advscene-0x3982.bin" "out/base/adv/adv-0x3982.bin"

#################
# visual scenes
#################

for file in asm/visual/*.s; do
  infile_base=$(basename $file .s)
  infile=out/base/visual/$infile_base.bin
  
  applyAsmPatchScene "$infile" "$file"
done

#################
# misc hacks
#################

applyAsmPatch "out/base/area/area-0x3202.bin" "area-0x3202"
mv "out/base/area-0x3202.bin" "out/base/area/area-0x3202.bin"

applyAsmPatch "out/base/area/area-0x356.bin" "area-0x356"
mv "out/base/area-0x356.bin" "out/base/area/area-0x356.bin"

applyAsmPatch "out/base/adv/adv-0xBC6.bin" "adv-0xBC6"
mv "out/base/adv-0xBC6.bin" "out/base/adv/adv-0xBC6.bin"

# HACK
mv -f "asm/visual-0x4E4E.sym" "temp.sym"
applyAsmPatch "out/base/visual/visual-0x4E4E.bin" "visual-0x4E4E_extra"
mv "out/base/visual-0x4E4E.bin" "out/base/visual/visual-0x4E4E.bin"
mv "asm/visual-0x4E4E.sym" "asm/visual-0x4E4E_extra.sym"
mv -f "temp.sym" "asm/visual-0x4E4E.sym"

applyAsmPatch "out/base/adv/adv-0x3742.bin" "adv-0x3742"
mv "out/base/adv-0x3742.bin" "out/base/adv/adv-0x3742.bin"

applyAsmPatch "out/base/title_36.bin" "title"

applyAsmPatch "out/base/boot_2.bin" "boot"

applyAsmPatch "out/base/adv/adv-0x1FBE.bin" "adv-0x1FBE"
mv "out/base/adv-0x1FBE.bin" "out/base/adv/adv-0x1FBE.bin"

#################
# kernel asm
#################

datsnip "out/base/kernel_D6.bin" 0x0 0x4000 "out/base/kernel_main.bin"
datsnip "out/base/kernel_D6.bin" 0x4000 0x2000 "out/base/kernel_gamescr.bin"
datsnip "out/base/kernel_D6.bin" 0x6000 0x2000 "out/base/kernel_extra1.bin"
datsnip "out/base/kernel_D6.bin" 0x8000 0x2000 "out/base/kernel_extra2.bin"
datpad_double "out/base/kernel_main.bin" 0x10000 0x4000
datpad_double "out/base/kernel_gamescr.bin" 0x10000 0x8000
datpad_double "out/base/kernel_extra1.bin" 0x10000 0x8000
datpad_double "out/base/kernel_extra2.bin" 0x10000 0x8000
cat "out/base/kernel_main.bin" "out/base/kernel_gamescr.bin" "out/base/kernel_extra1.bin" "out/base/kernel_extra2.bin" > "out/base/kernel_asm.bin"

applyAsmPatch "out/base/kernel_asm.bin" "kernel"

datpatch "out/base/kernel_D6.bin" "out/base/kernel_D6.bin" "out/base/kernel_asm.bin" 0x0 0x4000 0x4000
datpatch "out/base/kernel_D6.bin" "out/base/kernel_D6.bin" "out/base/kernel_asm.bin" 0x4000 0x18000 0x2000
datpatch "out/base/kernel_D6.bin" "out/base/kernel_D6.bin" "out/base/kernel_asm.bin" 0x6000 0x28000 0x2000
datpatch "out/base/kernel_D6.bin" "out/base/kernel_D6.bin" "out/base/kernel_asm.bin" 0x8000 0x38000 0x2000

#################
# credits asm
#################

datsnip "out/base/visual/visual-0x54CE.bin" 0x0 0x4000 "out/base/credits_main.bin"
datsnip "out/base/visual/visual-0x54CE.bin" 0x4000 0x2000 "out/base/credits_sub.bin"
datsnip "out/base/visual/visual-0x54CE.bin" 0xE000 0x2000 "out/base/credits_script.bin"
datpad_double "out/base/credits_main.bin" 0x10000 0x4000
datpad_double "out/base/credits_sub.bin" 0x10000 0xA000
datpad_double "out/base/credits_script.bin" 0x10000 0xC000
cat "out/base/credits_main.bin" "out/base/credits_sub.bin" "out/base/credits_script.bin" > "out/base/credits_asm.bin"

applyAsmPatch "out/base/credits_asm.bin" "credits"

datpatch "out/base/visual/visual-0x54CE.bin" "out/base/visual/visual-0x54CE.bin" "out/base/credits_asm.bin" 0x0 0x4000 0x4000
datpatch "out/base/visual/visual-0x54CE.bin" "out/base/visual/visual-0x54CE.bin" "out/base/credits_asm.bin" 0x4000 0x1A000 0x2000
datpatch "out/base/visual/visual-0x54CE.bin" "out/base/visual/visual-0x54CE.bin" "out/base/credits_asm.bin" 0xE000 0x2C000 0x2000

echo "********************************************************************************"
echo "Patching disc..."
echo "********************************************************************************"

pidol_patch "$OUTROM" "$OUTROM"

echo "*******************************************************************************"
echo "Success!"
echo "Output file:" $OUTROM
echo "*******************************************************************************"
