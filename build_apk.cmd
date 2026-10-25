@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"

REM ============================================================
REM  Zhiji Energy Consumption - Release APK Builder
REM  Produces a single-ABI (arm64-v8a) signed release APK.
REM  Requires: Flutter on PATH, android/key.properties, .jks
REM
REM  IMPORTANT - versionCode warning:
REM    --split-per-abi rewrites versionCode as: base*1000 + abi
REM      armeabi-v7a = 1003, arm64-v8a = 2003, x86_64 = 4003
REM    A universal APK would be 3 -> Android treats it as a DOWNGRADE
REM    and refuses to install over a split build (user must uninstall,
REM    and uninstalling deletes the local database).
REM    => NEVER publish the universal APK. Only dist\...arm64....apk
REM ============================================================

set FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
set APK_DIR=build\app\outputs\flutter-apk
set SRC_APK=%APK_DIR%\app-arm64-v8a-release.apk
set DIST=dist

REM pubspec.yaml is the single source of truth for the version.
set VERSION_LINE=
set BUILD_NO=
for /f "tokens=2 delims=:" %%v in ('findstr /b /c:"version:" pubspec.yaml') do set VERSION_LINE=%%v
for /f "tokens=1,2 delims=+" %%a in ("!VERSION_LINE: =!") do (
  set VERSION=%%a
  set BUILD_NO=%%b
)
if "!VERSION!"=="" set VERSION=unknown
if "!BUILD_NO!"=="" set BUILD_NO=0
set OUT_NAME=zhiji_oil_arm64_v!VERSION!-!BUILD_NO!.apk

echo ============================================
echo   Zhiji Energy - Release APK Builder
echo   version !VERSION! (build !BUILD_NO!)
echo ============================================
echo.

echo [1/5] flutter pub get
call flutter pub get
if errorlevel 1 goto failed

echo.
echo [2/5] flutter analyze
call flutter analyze
if errorlevel 1 goto failed

echo.
echo [3/5] flutter test
call flutter test
if errorlevel 1 goto failed

echo.
echo [4/5] Building release APK (split per abi)
call flutter build apk --release --split-per-abi
if errorlevel 1 goto failed

REM File name rule: only lowercase letters, digits, '_', '-', '.' are allowed.
REM Never use '+' (it is a URL-reserved character meaning space).
REM Universal APK is dangerous (versionCode 3 < 2003 = downgrade). Remove it.
if exist "%APK_DIR%\app-release.apk" del /q "%APK_DIR%\app-release.apk"

echo.
echo [5/5] Copying output
if not exist "%SRC_APK%" goto noapk
if not exist "%DIST%" mkdir "%DIST%"
copy /y "%SRC_APK%" "%DIST%\%OUT_NAME%" >nul

REM checksum alongside the apk (PowerShell is far more reliable than parsing certutil)
REM SHA256 via certutil (cmd-native; PowerShell inside delayed-expansion blocks is unreliable)
set SHA=
for /f "skip=1 delims=" %%h in ('certutil -hashfile "!DIST!\!OUT_NAME!" SHA256 2^>nul') do (
  if not defined SHA (
    set SHA=%%h
    > "!DIST!\!OUT_NAME!.sha256" echo %%h
  )
)

echo.
echo ============================================
echo   DONE
echo ============================================
echo.
echo Produced:
dir /b "%DIST%\*.apk"
echo.
echo   %OUT_NAME%
for %%F in ("%DIST%\%OUT_NAME%") do echo   %%~zF bytes
echo.
echo SHA256 (also written to %OUT_NAME%.sha256):
echo   !SHA!
echo.
echo NOTE: publish the arm64 file ONLY. Never ship app-release.apk.
echo.
start "" "%DIST%"
pause
exit /b 0

:noapk
echo.
echo ERROR: APK not found at %SRC_APK%
pause
exit /b 1

:failed
echo.
echo ============================================
echo   BUILD FAILED - see messages above
echo ============================================
pause
exit /b 1
