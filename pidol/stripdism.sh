set -o errexit

#mkdir -p script/orig

#make scriptdump
#./scriptdump "yuna_02.iso"

make blackt
make libpce
make dismstripper

./dismstripper dism.txt 29 dism_out.txt
