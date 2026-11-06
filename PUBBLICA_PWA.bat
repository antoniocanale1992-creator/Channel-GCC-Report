@echo off
title Deploy PWA Pokemon TCG Tracker
color 0b
echo ========================================================
echo        PUBBLICAZIONE PWA SU FIREBASE HOSTING
echo ========================================================
echo.
cd /d "c:\Users\anton\Desktop\Local GCC Pokemon"

:: Assicura che le variabili d'ambiente includano Firebase CLI
set "PATH=%PATH%;%LOCALAPPDATA%\Microsoft\WinGet\Packages;%LOCALAPPDATA%\Microsoft\WindowsApps"

echo [1/2] Accesso a Firebase con il tuo account Google...
echo Premi Y e Invio se richiesto. Si aprira il tuo browser predefinito.
echo.
call firebase login

echo.
echo [2/2] Deploy su Firebase Hosting (channel-gcc-report)...
call firebase deploy --only hosting,firestore:rules

echo.
echo ========================================================
echo   DEPLOY COMPLETATO!
echo   La tua PWA e live su: https://channel-gcc-report.web.app
echo ========================================================
echo.
pause
