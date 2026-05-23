@echo off
chcp 65001 >nul
echo ========================================
echo   RPG Music Pack Builder (Windows)
echo ========================================
echo.

:: Проверяем наличие ffmpeg
where ffmpeg >nul 2>&1
if %errorlevel% neq 0 (
    echo [ОШИБКА] ffmpeg не найден. Скачай с https://ffmpeg.org/download.html
    echo         и добавь в PATH.
    pause
    exit /b 1
)

:: Проверяем наличие папки input
if not exist "input" (
    mkdir input
    echo [INFO] Создана папка input\ — положи туда MP3/WAV файлы и запусти снова.
    pause
    exit /b 0
)

:: Создаём структуру пака
set PACK_DIR=my_pack
set SOUNDS_DIR=%PACK_DIR%\assets\minecraft\sounds\my_music

if exist "%PACK_DIR%" rmdir /s /q "%PACK_DIR%"
mkdir "%SOUNDS_DIR%"

:: Создаём pack.mcmeta
echo { > "%PACK_DIR%\pack.mcmeta"
echo   "pack": { >> "%PACK_DIR%\pack.mcmeta"
echo     "pack_format": 34, >> "%PACK_DIR%\pack.mcmeta"
echo     "description": "RPG Music Pack" >> "%PACK_DIR%\pack.mcmeta"
echo   } >> "%PACK_DIR%\pack.mcmeta"
echo } >> "%PACK_DIR%\pack.mcmeta"

:: Создаём sounds.json (начало)
echo { > "%PACK_DIR%\assets\minecraft\sounds.json"

:: Конвертируем все файлы из input\
set FIRST=1
set SOUNDS_JSON_ENTRIES=

for %%f in (input\*.mp3 input\*.wav input\*.flac) do (
    set "FILENAME=%%~nf"
    echo [КОНВЕРТАЦИЯ] %%f -^> my_music/%%~nf.ogg
    ffmpeg -i "%%f" -vn -c:a libvorbis -ar 44100 -ac 2 -q:a 4 "%SOUNDS_DIR%\%%~nf.ogg" -y -loglevel error

    if %FIRST%==0 (
        echo , >> "%PACK_DIR%\assets\minecraft\sounds.json"
    )
    set FIRST=0

    echo   "my_music.%%~nf": { >> "%PACK_DIR%\assets\minecraft\sounds.json"
    echo     "sounds": [{ "name": "my_music/%%~nf", "stream": true }], >> "%PACK_DIR%\assets\minecraft\sounds.json"
    echo     "category": "record" >> "%PACK_DIR%\assets\minecraft\sounds.json"
    echo   } >> "%PACK_DIR%\assets\minecraft\sounds.json"
)

echo } >> "%PACK_DIR%\assets\minecraft\sounds.json"

:: Упаковываем в ZIP
if exist "my_pack.zip" del "my_pack.zip"
echo.
echo [УПАКОВКА] Создаём my_pack.zip...

:: Используем PowerShell для упаковки
powershell -Command "Compress-Archive -Path '%PACK_DIR%\*' -DestinationPath 'my_pack.zip'"

:: Считаем SHA1
echo.
echo [SHA1] Хэш для server.properties:
certutil -hashfile my_pack.zip SHA1 | findstr /v "SHA1\|CertUtil"

echo.
echo [ГОТОВО] Файл my_pack.zip создан.
echo Загрузи его на публичный хостинг и вставь ссылку + SHA1 в server.properties
echo.
pause
