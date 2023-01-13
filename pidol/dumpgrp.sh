set -o errexit

mkdir -p rsrc/grp/orig
mkdir -p rsrc_raw/grp

make

# ./datsnip "base/adv/adv-0x34C2.bin" 0x2000 0x2C0 "rsrc_raw/grp/case3_pc_0.bin"
# ./datsnip "base/adv/adv-0x34C2.bin" 0x7E00 0x700 "rsrc_raw/grp/case3_pc_0-0.bin"
# ./grpunmap_pce "rsrc_raw/grp/case3_pc_0.bin" "rsrc_raw/grp/case3_pc_0-0.bin" 32 28 "rsrc/grp/orig/case3_pc_0-0.png" -v 0x2A0 -o 0 -p "rsrc_raw/pal/case3_pc_line.pal" -t
# 
# ./datsnip "base/adv/adv-0x34C2.bin" 0x2300 0x2760 "rsrc_raw/grp/case3_pc_1.bin"
# ./datsnip "base/adv/adv-0x34C2.bin" 0x8500 0x700 "rsrc_raw/grp/case3_pc_1-0.bin"
# ./datsnip "base/adv/adv-0x34C2.bin" 0x8C00 0x700 "rsrc_raw/grp/case3_pc_1-1.bin"
# ./datsnip "base/adv/adv-0x34C2.bin" 0x9300 0x700 "rsrc_raw/grp/case3_pc_1-2.bin"
# ./grpunmap_pce "rsrc_raw/grp/case3_pc_1.bin" "rsrc_raw/grp/case3_pc_1-0.bin" 32 28 "rsrc/grp/orig/case3_pc_1-0.png" -v 0x2A0 -o 0 -p "rsrc_raw/pal/case3_pc_line.pal" -t
# ./grpunmap_pce "rsrc_raw/grp/case3_pc_1.bin" "rsrc_raw/grp/case3_pc_1-1.bin" 32 28 "rsrc/grp/orig/case3_pc_1-1.png" -v 0x2A0 -o 0 -p "rsrc_raw/pal/case3_pc_line.pal" -t
# ./grpunmap_pce "rsrc_raw/grp/case3_pc_1.bin" "rsrc_raw/grp/case3_pc_1-2.bin" 32 28 "rsrc/grp/orig/case3_pc_1-2.png" -v 0x2A0 -o 0 -p "rsrc_raw/pal/case3_pc_line.pal" -t
# 
# ./datsnip "base/adv/adv-0x34C2.bin" 0x4B00 0x2CC0 "rsrc_raw/grp/case3_pc_2.bin"
# ./datsnip "base/adv/adv-0x34C2.bin" 0x9A00 0x700 "rsrc_raw/grp/case3_pc_2-0.bin"
# ./datsnip "base/adv/adv-0x34C2.bin" 0xA100 0x700 "rsrc_raw/grp/case3_pc_2-1.bin"
# ./grpunmap_pce "rsrc_raw/grp/case3_pc_2.bin" "rsrc_raw/grp/case3_pc_2-0.bin" 32 28 "rsrc/grp/orig/case3_pc_2-0.png" -v 0x2A0 -o 0 -p "rsrc_raw/pal/case3_pc_line.pal" -t
# ./grpunmap_pce "rsrc_raw/grp/case3_pc_2.bin" "rsrc_raw/grp/case3_pc_2-1.bin" 32 28 "rsrc/grp/orig/case3_pc_2-1.png" -v 0x2A0 -o 0 -p "rsrc_raw/pal/case3_pc_line.pal" -t
# 
# ./datsnip "base/adv/adv-0x36C2.bin" 0x2000 0x2CC0 "rsrc_raw/grp/case3_pc2_0.bin"
# ./datsnip "base/adv/adv-0x36C2.bin" 0x4F00 0x700 "rsrc_raw/grp/case3_pc2_0-0.bin"
# ./datsnip "base/adv/adv-0x36C2.bin" 0x5600 0x700 "rsrc_raw/grp/case3_pc2_0-1.bin"
# ./grpunmap_pce "rsrc_raw/grp/case3_pc2_0.bin" "rsrc_raw/grp/case3_pc2_0-0.bin" 32 28 "rsrc/grp/orig/case3_pc2_0-0.png" -v 0x180 -o 0 -p "rsrc_raw/pal/case3_pc2_line.pal" -t
# ./grpunmap_pce "rsrc_raw/grp/case3_pc2_0.bin" "rsrc_raw/grp/case3_pc2_0-1.bin" 32 28 "rsrc/grp/orig/case3_pc2_0-1.png" -v 0x180 -o 0 -p "rsrc_raw/pal/case3_pc2_line.pal" -t
# 
# ./datsnip "base/adv/adv-0x3502.bin" 0x2000 0x2560 "rsrc_raw/grp/autopsy_1.bin"
# ./datsnip "base/adv/adv-0x3502.bin" 0x4B00 0x700 "rsrc_raw/grp/autopsy_0-1.bin"
# ./grpunmap_pce "rsrc_raw/grp/autopsy_1.bin" "rsrc_raw/grp/autopsy_0-1.bin" 32 22 "rsrc/grp/orig/autopsy_0-1.png" -v 0x2A0 -o 0 -p "rsrc_raw/pal/autopsy_0.pal" -t
# 
# ./datsnip "base/advscene/advscene-0x3602.bin" 0x2000 0x10C0 "rsrc_raw/grp/cafe_0.bin"
# ./datsnip "base/advscene/advscene-0x3602.bin" 0x3200 0x500 "rsrc_raw/grp/cafe_0-0.bin"
# ./grpunmap_pce "rsrc_raw/grp/cafe_0.bin" "rsrc_raw/grp/cafe_0-0.bin" 32 20 "rsrc/grp/orig/cafe_0-0.png" -v 0x180 -o 0 -p "rsrc_raw/pal/cafe.pal" -t
# 
# ./datsnip "base/adv/adv-0x37C2.bin" 0x2000 0x1FC0 "rsrc_raw/grp/autopsy2_0.bin"
# ./datsnip "base/adv/adv-0x37C2.bin" 0x4000 0x2340 "rsrc_raw/grp/autopsy2_1.bin"
# ./datsnip "base/adv/adv-0x37C2.bin" 0x6A00 0x580 "rsrc_raw/grp/autopsy2_0-0.bin"
# ./datsnip "base/adv/adv-0x37C2.bin" 0x7000 0x580 "rsrc_raw/grp/autopsy2_1-0.bin"
# ./grpunmap_pce "rsrc_raw/grp/autopsy2_0.bin" "rsrc_raw/grp/autopsy2_0-0.bin" 32 22 "rsrc/grp/orig/autopsy2_0-0.png" -v 0x180 -o 0 -p "rsrc_raw/pal/autopsy2_0.pal" -t
# ./grpunmap_pce "rsrc_raw/grp/autopsy2_1.bin" "rsrc_raw/grp/autopsy2_1-0.bin" 32 22 "rsrc/grp/orig/autopsy2_1-0.png" -v 0x180 -o 0 -p "rsrc_raw/pal/autopsy2_0.pal" -t
# 
# ./datsnip "base/advscene/advscene-0x1FFE.bin" 0x2000 0xFC0 "rsrc_raw/grp/scene2b_title_0.bin"
# ./datsnip "base/advscene/advscene-0x1FFE.bin" 0x4000 0x700 "rsrc_raw/grp/scene2b_title_0-0.bin"
# ./grpunmap_pce "rsrc_raw/grp/scene2b_title_0.bin" "rsrc_raw/grp/scene2b_title_0-0.bin" 32 28 "rsrc/grp/orig/scene2b_title_0-0.png" -v 0x180 -o 0 -p "rsrc_raw/pal/scene2b_title_mod.pal" -t
# 
# ./datsnip "base/adv/adv-0x3742.bin" 0x6A00 0xA00 "rsrc_raw/grp/scene3_title_0.bin"
# ./datsnip "base/adv/adv-0x3742.bin" 0xC000 0x700 "rsrc_raw/grp/scene3_title_0-0.bin"
# ./grpunmap_pce "rsrc_raw/grp/scene3_title_0.bin" "rsrc_raw/grp/scene3_title_0-0.bin" 32 28 "rsrc/grp/orig/scene3_title_0-0.png" -v 0x180 -o 0 -p "rsrc_raw/pal/scene3_title_mod.pal" -t

# ./spritedmp_pce "base/title_36.bin" "test_titlespr.png" -s 0x1B440 -n 0x1C

# ./datsnip "base/title_36.bin" 0x1E800 0x1220 "rsrc_raw/grp/title_bonus_0.bin"
# ./datsnip "base/title_36.bin" 0x1E000 0x800 "rsrc_raw/grp/title_bonus_0-0.bin"
# ./grpunmap_pce "rsrc_raw/grp/title_bonus_0.bin" "rsrc_raw/grp/title_bonus_0-0.bin" 32 32 "rsrc/grp/orig/title_bonus_0-0.png" -v 0x500 -o 0 -p "rsrc_raw/pal/title_bonus_mod.pal" -t
# 
# ./datsnip "base/boot_2.bin" 0x2000 0x49E0 "rsrc_raw/grp/syscard_error_0.bin"
# ./datsnip "base/boot_2.bin" 0x6B40 0x700 "rsrc_raw/grp/syscard_error_0-0.bin"
# ./grpunmap_pce "rsrc_raw/grp/syscard_error_0.bin" "rsrc_raw/grp/syscard_error_0-0.bin" 32 28 "rsrc/grp/orig/syscard_error_0-0.png" -v 0x100 -o 0 -p "rsrc_raw/pal/syscard_error.pal" -t

./datsnip "base/adv/adv-0x1FBE.bin" 0x2000 0x5740 "rsrc_raw/grp/case2b_map_0.bin"
./datsnip "base/adv/adv-0x1FBE.bin" 0x1CE00 0x700 "rsrc_raw/grp/case2b_map_0-0.bin"
./grpunmap_pce "rsrc_raw/grp/case2b_map_0.bin" "rsrc_raw/grp/case2b_map_0-0.bin" 32 28 "rsrc/grp/orig/case2b_map_0-0.png" -v 0x180 -o 0 -p "rsrc_raw/pal/case2b_map_mod.pal" -t
