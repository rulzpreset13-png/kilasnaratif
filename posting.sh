#!/data/data/com.termux/files/usr/bin/bash

echo "======================================"
echo "   KILASNARATIF - POSTING OTOMATIS"
echo "======================================"
echo ""

# 1. Input Judul
read -p "Judul berita: " JUDUL
if [ -z "$JUDUL" ]; then
  echo "❌ Judul tidak boleh kosong!"
  exit 1
fi

# 2. Input Kategori
echo ""
echo "Pilih kategori:"
echo "1) Trending"
echo "2) Teknologi"
echo "3) Olahraga"
echo "4) Viral"
echo "5) Hiburan"
read -p "Nomor kategori (1-5): " KATNUM

case $KATNUM in
  1) KATEGORI="Trending"; BADGE="trending" ;;
  2) KATEGORI="Teknologi"; BADGE="teknologi" ;;
  3) KATEGORI="Olahraga"; BADGE="olahraga" ;;
  4) KATEGORI="Viral"; BADGE="viral" ;;
  5) KATEGORI="Hiburan"; BADGE="hiburan" ;;
  *) KATEGORI="Viral"; BADGE="viral" ;;
esac

# 3. Deskripsi singkat
echo ""
read -p "Deskripsi singkat (untuk halaman depan): " DESKRIPSI

# 4. Isi berita
echo ""
echo "Ketik isi berita. Ketik 'SELESAI' di baris baru kalau sudah selesai:"
echo ""
ISI=""
while IFS= read -r line; do
  if [ "$line" = "SELESAI" ]; then
    break
  fi
  if [ -z "$ISI" ]; then
    ISI="$line"
  else
    ISI="$ISI

$line"
  fi
done

# 5. Cari nomor berita berikutnya
NOMOR=$(ls berita*.html 2>/dev/null | grep -oE '[0-9]+' | sort -n | tail -1)
if [ -z "$NOMOR" ]; then
  NOMOR=1
else
  NOMOR=$((NOMOR + 1))
fi

FILE="berita${NOMOR}.html"
echo ""
echo "📝 Membuat file: $FILE"

# 6. Buat file HTML berita
cat > "$FILE" <<EOF
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${JUDUL}</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Arial, sans-serif; background: #f1f5f9; margin: 0; padding: 15px; color: #1e293b; }
        header { background: #0f172a; color: #fff; padding: 18px 20px; display: flex; justify-content: space-between; align-items: center; border-radius: 8px; margin-bottom: 20px; }
        header .brand-right { font-size: 18px; font-weight: 700; }
        header .brand-right span { color: #f43f5e; }
        header a { color: #94a3b8; text-decoration: none; font-size: 14px; font-weight: 600; }
        .container { max-width: 720px; margin: 0 auto; background: #fff; padding: 24px; border-radius: 14px; box-shadow: 0 2px 12px rgba(0,0,0,0.06); border-left: 4px solid #f43f5e; }
        .badge { display: inline-block; padding: 4px 10px; border-radius: 6px; font-size: 11px; font-weight: 700; color: #fff; margin-bottom: 12px; text-transform: uppercase; background: #f43f5e; }
        h1 { color: #0f172a; font-size: 24px; margin-bottom: 8px; line-height: 1.35; }
        .meta { color: #94a3b8; font-size: 13px; margin-bottom: 20px; border-bottom: 1px solid #e2e8f0; padding-bottom: 12px; }
        p { line-height: 1.8; margin-bottom: 16px; font-weight: 500; color: #334155; }
        footer { text-align: center; margin-top: 30px; color: #94a3b8; font-size: 13px; }
    </style>
</head>
<body>
    <header>
        <div class="brand-right">Kilas<span>Naratif</span></div>
        <a href="index.html">&larr; Home</a>
    </header>

    <div class="container">
        <span class="badge">${KATEGORI}</span>
        <h1>${JUDUL}</h1>
        <p class="meta">Ditulis oleh: Redaksi KilasNaratif | $(date +"%-d %B %Y")</p>
        <p>${ISI}</p>
    </div>

    <footer>
        &copy; 2026 KilasNaratif. Semua hak dilindungi.
    </footer>
</body>
</html>
EOF

echo "✅ File $FILE berhasil dibuat!"

# 7. Update index.html - tambah berita baru di paling atas
echo "📄 Update halaman depan..."

# Buat entry baru
ENTRY="        <div class=\"berita\">
            <span class=\"badge ${BADGE}\">${KATEGORI}</span>
            <h2><a href=\"${FILE}\">${JUDUL}</a></h2>
            <p>${DESKRIPSI}</p>
        </div>
"

# Sisipkan entry baru setelah <div class="container">
awk -v entry="$ENTRY" '{print} /<div class="container">/ {print entry}' index.html > index_new.html
mv index_new.html index.html

echo "✅ Halaman depan berhasil diupdate!"

# 8. Push ke GitHub
echo ""
echo "🚀 Upload ke GitHub..."
git add .
git commit -m "Posting berita baru: ${JUDUL}"
git push

echo ""
echo "======================================"
echo "🎉 SELESAI! Berita sudah online!"
echo "======================================"
echo "Buka: https://rulzpreset13-png.github.io/kilasnaratif/${FILE}"
