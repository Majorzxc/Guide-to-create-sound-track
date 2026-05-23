#!/bin/bash

echo "========================================"
echo "  RPG Music Pack Builder (Linux/macOS)"
echo "========================================"
echo ""

# Проверяем наличие ffmpeg
if ! command -v ffmpeg &> /dev/null; then
    echo "[ОШИБКА] ffmpeg не найден."
    echo "         Ubuntu/Debian: sudo apt install ffmpeg"
    echo "         macOS:         brew install ffmpeg"
    exit 1
fi

# Проверяем наличие папки input
if [ ! -d "input" ]; then
    mkdir input
    echo "[INFO] Создана папка input/ — положи туда MP3/WAV файлы и запусти снова."
    exit 0
fi

# Проверяем что в input есть файлы
shopt -s nullglob
INPUT_FILES=(input/*.mp3 input/*.wav input/*.flac)
if [ ${#INPUT_FILES[@]} -eq 0 ]; then
    echo "[ОШИБКА] В папке input/ нет файлов MP3/WAV/FLAC."
    exit 1
fi

# Создаём структуру пака
PACK_DIR="my_pack"
SOUNDS_DIR="$PACK_DIR/assets/minecraft/sounds/my_music"

rm -rf "$PACK_DIR"
mkdir -p "$SOUNDS_DIR"

# Создаём pack.mcmeta
cat > "$PACK_DIR/pack.mcmeta" << 'EOF'
{
  "pack": {
    "pack_format": 34,
    "description": "RPG Music Pack"
  }
}
EOF

# Конвертируем файлы и собираем sounds.json
SOUNDS_JSON="{"
FIRST=1

for INPUT_FILE in "${INPUT_FILES[@]}"; do
    FILENAME=$(basename "$INPUT_FILE")
    NAME="${FILENAME%.*}"

    echo "[КОНВЕРТАЦИЯ] $INPUT_FILE -> my_music/$NAME.ogg"
    ffmpeg -i "$INPUT_FILE" -vn -c:a libvorbis -ar 44100 -ac 2 -q:a 4 \
        "$SOUNDS_DIR/$NAME.ogg" -y -loglevel error

    if [ $FIRST -eq 0 ]; then
        SOUNDS_JSON="$SOUNDS_JSON,"
    fi
    FIRST=0

    SOUNDS_JSON="$SOUNDS_JSON
  \"my_music.$NAME\": {
    \"sounds\": [{ \"name\": \"my_music/$NAME\", \"stream\": true }],
    \"category\": \"record\"
  }"
done

SOUNDS_JSON="$SOUNDS_JSON
}"

echo "$SOUNDS_JSON" > "$PACK_DIR/assets/minecraft/sounds.json"

# Упаковываем в ZIP
rm -f my_pack.zip
echo ""
echo "[УПАКОВКА] Создаём my_pack.zip..."
cd "$PACK_DIR" && zip -r ../my_pack.zip . -x "*.DS_Store" && cd ..

# Считаем SHA1
echo ""
echo "[SHA1] Хэш для server.properties:"
if command -v sha1sum &> /dev/null; then
    sha1sum my_pack.zip | awk '{print $1}'
else
    shasum -a 1 my_pack.zip | awk '{print $1}'
fi

echo ""
echo "[ГОТОВО] Файл my_pack.zip создан."
echo "Загрузи его на публичный хостинг и вставь ссылку + SHA1 в server.properties"
