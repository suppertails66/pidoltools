
set -o errexit

tempFontFile=".fontrender_temp"


function outlineSolidPixels() {
#  convert "$1" \( +clone -channel A -morphology EdgeOut Diamond:1 -negate -threshold 15% -negate +channel +level-colors \#000024 \) -compose DstOver -composite "$2"
  convert "$1" \( +clone -channel A -morphology EdgeOut Square:1 -negate -threshold 15% -negate +channel +level-colors \#000024 \) -compose DstOver -composite "$2"
}

function renderString() {
  printf "$2" > $tempFontFile
  
#  ./fontrender "font/12px_outline/" "$tempFontFile" "font/12px_outline/table.tbl" "$1.png"
#  ./fontrender "font/" "$tempFontFile" "font/table.tbl" "$1.png"
  ./fontrender "font/" "$tempFontFile" "font/table.tbl" "$1.png"
}

function renderStringNarrow() {
  printf "$2" > $tempFontFile
  
#  ./fontrender "font/12px_outline/" "$tempFontFile" "font/12px_outline/table.tbl" "$1.png"
#  ./fontrender "font/" "$tempFontFile" "font/table.tbl" "$1.png"
  ./fontrender "font/12px/" "$tempFontFile" "font/12px/table.tbl" "$1.png"
  outlineSolidPixels "$1.png" "$1.png"
}

function renderStringScene() {
  printf "$2" > $tempFontFile
  
#  ./fontrender "font/12px_outline/" "$tempFontFile" "font/12px_outline/table.tbl" "$1.png"
#  ./fontrender "font/" "$tempFontFile" "font/table.tbl" "$1.png"
  ./fontrender "font/scene/" "$tempFontFile" "font/scene/table.tbl" "$1.png"
}

function renderStringMecosPre() {
  ./scrdat_render "font/mecos/" "font/mecos/table.tbl" "$2" "table/ascii.tbl" "$1.png" --fgcolor 255 255 255 --bgcolor 0 0 0 -w 256 -h 224
}

function renderStringReportPre() {
  ./scrdat_render "font/report/" "font/report/table.tbl" "$2" "table/ascii.tbl" "$1.png" --fgcolor 0x00 0x00 0x00 --bgcolor 0xDA 0xDA 0xB6 -w 256 -h 176
}



make blackt && make fontrender && make scrdat_render

# renderString render1 "In the vicinity of Lyra"
# renderString render2 "Black Hole"
# renderString render3 "GNC-01089"

# renderString render1 "Cardia Star System"
# renderString render2 "Artificial Planet Flint"

# renderString render1 "Planter System"
# renderString render2 "Planet Mariana"

# renderString render1 "Capé System"
# #renderString render2 "Planet Luries"
# renderString render2 "Planet Loureezus"

# renderString render1 "Tian Star Sector"
# renderString render2 "Planet Balmood"

# renderString render1 "The Eastern Outer Arm of the Milky Way"
# renderString render2 "The Dark Nebula"

# renderStringNarrow render1 "Executive Producer"
# renderStringNarrow render2 "Yuji Kudo"
# renderStringNarrow render3 "Original Work/Character Design"
# renderStringNarrow render4 "Mika Akitaka"
# renderStringNarrow render5 "Producer"
# # 和気　正則
# renderStringNarrow render6 "Masanori Wake"
# # 小林　正樹
# renderStringNarrow render7 "Masaki Kobayashi"
# # oh, someone actually put all the credits, in english, on mobygames.
# # who the hell has all this time on their hands!?
# # well, it's as good as anything.
# # actually, maybe not, given that they mistranslated
# # "automobile club" as "bicycle club" (jidousha vs. jitensha).
# # but hey, at least that means they were actually reading the text
# # instead of just jamming it into google!
# # 構成・脚本
# renderStringNarrow render8 "Setting/Scenario"
# # あかほり さとる
# renderStringNarrow render9 "Satoru Akahori"
# renderStringNarrow render10 "Yuna Kagurazaka"
# renderStringNarrow render11 "Chisa Yokoyama"
# renderStringNarrow render12 "Yuri Cube"
# renderStringNarrow render13 "Miki Takahashi"
# renderStringNarrow render14 "Guest Character Design"
# renderStringNarrow render15 "Michitaka Kikuchi"
# renderStringNarrow render16 "Kousuke Fujishima"
# renderStringNarrow render17 "Liavelt von Neuestein"
# renderStringNarrow render18 "Yumi Toma"
# renderStringNarrow render19 "Elner"
# renderStringNarrow render20 "Yuriko Yamamoto"
# renderStringNarrow render21 "Erika Kosaka"
# renderStringNarrow render22 "Akiko Yajima"
# renderStringNarrow render23 "Princess Mirage"
# renderStringNarrow render24 "Yuko Mizutani"

# 番組中お見苦しい点があったことをお詫びいたします。
# it's literally "we apologize that there was an unseemly occurence during the program",
# but that's not how you interrupt a broadcast around here
#renderString render1 "We are experiencing technical difficulties. Please stand by."
# renderStringScene render1 "We are experiencing"
# renderStringScene render2 "technical difficulties."
# renderStringScene render3 "Please stand by."

# renderStringNarrow render1 "Marnias Fleet -- Flagship"
# renderStringNarrow render2 "Ende Perium"
#renderStringNarrow render1 "Fleet Commander"
#renderStringNarrow render2 "Princess Ryudia"

# renderString render1 "Navi: {When you'd like to investigate a"
# renderString render2 "place that interests you, stand in front of"
# renderString render3 "it and press Button I.}"

# renderString render1 "Tachibana Ayaka: An actress in the same"
# renderString render2 "office as me. 14 years old. A little"
# renderString render3 "childish, but cute too!"

#renderString render1 "Don't go running around on your own too much!"

# renderString render1 "Sasaki: {Frustrated that his research"
# renderString render2 "wasn't proceeding at all, he escalated his"
# renderString render3 "deeds to more depraved depths.}"

# renderStringMecosPre render1 "out/script/strings/case3-pc-0.bin"
# renderStringMecosPre render2 "out/script/strings/case3-pc-1.bin"
# renderStringMecosPre render3 "out/script/strings/case3-pc-2.bin"
# renderStringMecosPre render4 "out/script/strings/case3-pc-3.bin"
# renderStringReportPre render1 "out/script/strings/autopsy-0.bin"

renderString render1 "Parking Garage"

rm -f $tempFontFile