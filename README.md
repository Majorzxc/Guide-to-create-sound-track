# 🎵 RPG Music Pack — Инструкция

Руководство по созданию кастомного ресурс-пака с музыкой для Minecraft-сервера и подключению плагина **RPGMusics**.

## Стек

| Компонент | Версия |
|---|---|
| Minecraft | 1.21.4 |
| Ядро | Purpur / Paper |
| Java | 21 |
| WorldEdit | 7.3.19 |
| WorldGuard | 7.0.13 |
| WGRegionEvents | 1.7.4 |
| RPGMusics | 1.0.2 |

---

## Шаг 1 — Конвертация аудио в OGG

Minecraft принимает только формат **OGG Vorbis**. Важно исключить видеопоток (обложку альбома) флагом `-vn`, иначе звук не воспроизведётся.

```bash
ffmpeg -i твой_файл.mp3 -vn -c:a libvorbis -ar 44100 -ac 2 -q:a 4 track.ogg
```

Или используй готовый скрипт из папки `scripts/` (см. ниже).

---

## Шаг 2 — Структура ресурс-пака

```
my_pack/
├── pack.mcmeta
└── assets/
    └── minecraft/
        ├── sounds.json
        └── sounds/
            └── my_music/
                └── track.ogg
```

---

## Шаг 3 — pack.mcmeta

```json
{
  "pack": {
    "pack_format": 34,
    "description": "My Music Pack"
  }
}
```

> `pack_format: 34` — для Minecraft 1.21.4. Для других версий: 1.20.4 → 22, 1.20.1 → 15.

---

## Шаг 4 — sounds.json

```json
{
  "my_music.track": {
    "sounds": [
      {
        "name": "my_music/track",
        "stream": true
      }
    ],
    "category": "record"
  }
}
```

**Важные детали:**
- `"stream": true` — обязательно для треков длиннее 5 секунд, иначе файл целиком загружается в память
- `"category": "record"` — категория «Музыкальные блоки» в настройках звука клиента
- Для нескольких треков просто добавляй новые записи в JSON

---

## Шаг 5 — Упаковка в ZIP

Выдели **содержимое** папки `my_pack/` и запакуй в ZIP. Именно содержимое, не саму папку — иначе структура путей сломается.

Или используй скрипт `scripts/build_pack.bat` / `scripts/build_pack.sh`.

---

## Шаг 6 — Подключение к серверу

Загрузи ZIP на публичный хостинг (GitHub public repo, [mc-packs.net](https://mc-packs.net) и т.д.).

Получи SHA1 хэш файла:

```bash
# Windows
certutil -hashfile my_pack.zip SHA1

# Linux / macOS
sha1sum my_pack.zip
```

Пропиши в `server.properties`:

```properties
resource-pack=https://прямая_ссылка/my_pack.zip
resource-pack-sha1=сюда_хэш
```

> ⚠️ GitHub raw-ссылки (`/blob/`) не работают. Используй GitHub Releases или attachments для прямых ссылок.

---

## Шаг 7 — Настройка плагина RPGMusics

Открой `plugins/RpgMusics/regions.yml`:

```yaml
название_записи:
  region-name: имя_региона_worldguard
  region-world: world
  music: "minecraft:my_music.track"
  loop-time: 2065
  volume: 1
  pitch: 1
```

**Параметры:**

| Поле | Описание |
|---|---|
| `region-name` | Имя региона из WorldGuard (`/rg define имя`) |
| `region-world` | Имя мира (обычно `world`) |
| `music` | Имя звука с префиксом `minecraft:` и точкой вместо слеша |
| `loop-time` | Длина трека в тиках (секунды × 20) |
| `volume` | Громкость (0.0 — 1.0) |
| `pitch` | Высота тона (1.0 = нормальный) |

Перезапусти сервер — при входе в регион заиграет музыка.

---

## Шаг 8 — Проверка

Проверить звук вручную (от имени консоли или оператора):

```
execute at ИМЯ_ИГРОКА run playsound minecraft:my_music.track record ИМЯ_ИГРОКА ~ ~ ~
```

Остановить звук:

```
stopsound ИМЯ_ИГРОКА record
```

---

## Частые проблемы

| Проблема | Причина | Решение |
|---|---|---|
| Звук не воспроизводится | OGG содержит видеопоток (обложку) | Конвертировать с флагом `-vn` |
| Пак не загружается | Закрытый репозиторий GitHub | Сделать репозиторий публичным |
| «Не удалось загрузить пак» | Неверный SHA1 или недоступная ссылка | Пересчитать хэш, проверить ссылку |
| WorldGuard не запускается | Несовместимая версия WorldEdit | Использовать WorldEdit 7.3.x для Java 21 |
| `The sound is too far away` | playsound играет в 0 0 0 | Использовать `execute at ИГРОК run playsound ...` |
