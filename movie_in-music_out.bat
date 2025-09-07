@echo off
setlocal enabledelayedexpansion

set "FFMPEG=%~dp0ffmpeg.exe"
set "FFPROBE=%~dp0ffprobe.exe"

:: Check if a file was dragged and dropped
if "%~1"=="" (
    echo No file was dragged and dropped.
    echo Please drag a video file onto this batch file.
    pause
    exit /b
)

:: Check if ffmpeg.exe and ffprobe.exe exist in the same folder
if not exist "%FFMPEG%" (
    echo ffmpeg.exe not found in the same folder as this batch file.
    pause
    exit /b
)
if not exist "%FFPROBE%" (
    echo ffprobe.exe not found in the same folder as this batch file.
    pause
    exit /b
)

:: Get the input file
set "input_file=%~1"
for %%X in ("!input_file!") do set "base=%%~nX"
set "outfile=!base!.mp3"

:: Get duration of the input file
for /f "usebackq tokens=* delims=" %%A in (`
    "%FFPROBE%" -v error -show_entries format^=duration -of default^=noprint_wrappers^=1:nokey^=1 "!input_file!"
`) do set "audiodur=%%A"

for /f "tokens=1 delims=." %%B in ("!audiodur!") do set "audiodur_rounded=%%B"

if !audiodur_rounded! gtr 100000 (
    set /a audiodur_rounded=!audiodur_rounded!/1000
)

echo Duration: !audiodur_rounded! seconds

:: Run ffmpeg to extract audio to MP3
echo Extracting audio to MP3...
"%FFMPEG%" -i "!input_file!" -vn -acodec mp3 -ab 192k "!outfile!"
if %ERRORLEVEL% neq 0 (
    echo Failed to extract audio from "!input_file!".
    pause
    exit /b
)

echo(
echo Finished! Output saved as: "!outfile!"
pause
endlocal