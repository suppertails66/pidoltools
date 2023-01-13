set -o errexit

mkdir -p baseblanked/area/txt
mkdir -p baseblanked/adv/txt

make

for file in baseblanked/area/*.bin; do
  base=$(basename $file .bin)
  out=baseblanked/area/txt/${base}.txt
  
  echo $base
  ./tblconv "table/pidol_raw.tbl" "$file" "$out"
done

for file in baseblanked/adv/*.bin; do
  base=$(basename $file .bin)
  out=baseblanked/adv/txt/${base}.txt
  
  echo $base
  ./tblconv "table/pidol_raw.tbl" "$file" "$out"
done


