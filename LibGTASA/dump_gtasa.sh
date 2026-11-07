
#!/data/data/com.termux/files/usr/bin/bash

set +e

LIB="${1:-libGTASA.so}"
OUT="libGTASA_dump"

if [ ! -f "$LIB" ]; then
    echo "[ERROR] File tidak ditemukan: $LIB"
    exit 1
fi

mkdir -p "$OUT"

echo "===================================="
echo " GTA SA LIBRARY DUMP"
echo "===================================="

echo "[1/10] Informasi file..."
file "$LIB" > "$OUT/01_file_info.txt"
sha256sum "$LIB" > "$OUT/02_sha256.txt"
md5sum "$LIB" > "$OUT/03_md5.txt"

echo "[2/10] ELF header..."
readelf -hW "$LIB" > "$OUT/04_elf_header.txt"

echo "[3/10] Seluruh metadata ELF..."
readelf -aW "$LIB" > "$OUT/05_elf_all.txt"

echo "[4/10] Section headers..."
readelf -SW "$LIB" > "$OUT/06_sections.txt"

echo "[5/10] Program headers..."
readelf -lW "$LIB" > "$OUT/07_segments.txt"

echo "[6/10] Dynamic symbols..."
readelf --dyn-syms -W "$LIB" > "$OUT/08_dynamic_symbols.txt"

echo "[7/10] Relocations..."
readelf -rW "$LIB" > "$OUT/09_relocations.txt"

echo "[8/10] Semua strings..."
strings -a -t x -n 4 "$LIB" > "$OUT/10_strings.txt"

echo "[9/10] Disassembly ARM/Thumb..."
llvm-objdump -d -C "$LIB" > "$OUT/11_disassembly.txt"

echo "[10/10] Dump seluruh section..."
llvm-objdump -s "$LIB" > "$OUT/12_sections_hex.txt"

echo "[EXTRA] Exported symbols..."
nm -D -C "$LIB" > "$OUT/13_nm_dynamic.txt"

echo "[EXTRA] Library information..."
{
    echo "File: $LIB"
    echo "Size:"
    du -h "$LIB"
    echo
    echo "SHA256:"
    sha256sum "$LIB"
    echo
    echo "Architecture:"
    file "$LIB"
} > "$OUT/14_summary.txt"

echo
echo "Dump selesai."
echo "Lokasi: $OUT"

echo
echo "Membuat arsip..."
tar -czf libGTASA_dump.tar.gz "$OUT"

echo
echo "Ukuran arsip:"
du -h libGTASA_dump.tar.gz

echo
echo "Membagi arsip menjadi bagian 45 MiB..."
split -b 45M -d -a 3 \
    libGTASA_dump.tar.gz \
    libGTASA_dump.part_

echo
echo "Selesai!"
ls -lh libGTASA_dump.part_*

