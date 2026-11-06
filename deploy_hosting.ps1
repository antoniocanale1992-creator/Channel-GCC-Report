# Pokémon TCG Local Tracker - Firebase Hosting Deploy Script
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "   Deploying PWA to Firebase Hosting       " -ForegroundColor Yellow
Write-Host "==========================================" -ForegroundColor Cyan

# 1. Compilazione Flutter Web Release
Write-Host "`n[1/3] Compilazione Flutter Web Release..." -ForegroundColor Green
flutter build web --release
if ($LASTEXITCODE -ne 0) {
    Write-Host "Errore durante la compilazione web. Interruzione." -ForegroundColor Red
    exit 1
}

# 2. Controllo Firebase CLI
Write-Host "`n[2/3] Verifica Firebase CLI..." -ForegroundColor Green
$firebaseCmd = Get-Command "firebase" -ErrorAction SilentlyContinue

if (-not $firebaseCmd) {
    Write-Host "Firebase CLI non trovata nell'ambiente corrente." -ForegroundColor Yellow
    Write-Host "Per installare Firebase CLI su Windows:" -ForegroundColor Cyan
    Write-Host "  1. Tramite npm: npm install -g firebase-tools" -ForegroundColor White
    Write-Host "  2. Standalone binary: https://firebase.tools/bin/win/instant/latest" -ForegroundColor White
    Write-Host "  3. Tramite winget: winget install Google.FirebaseCLI" -ForegroundColor White
    Write-Host "`nDopo l'installazione, esegui:" -ForegroundColor Yellow
    Write-Host "  firebase login" -ForegroundColor White
    Write-Host "  firebase deploy --only hosting,firestore:rules" -ForegroundColor White
    exit 0
}

# 3. Deploy su Firebase Hosting e Firestore Rules
Write-Host "`n[3/3] Esecuzione deploy su Firebase (channel-gcc-report)..." -ForegroundColor Green
firebase deploy --only hosting,firestore:rules

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n==========================================" -ForegroundColor Cyan
    Write-Host "   DEPLOY COMPLETATO CON SUCCESSO!        " -ForegroundColor Green
    Write-Host "   PWA Live: https://channel-gcc-report.web.app" -ForegroundColor Cyan
    Write-Host "==========================================" -ForegroundColor Cyan
} else {
    Write-Host "`nDeploy fallito. Verifica di aver eseguito 'firebase login'." -ForegroundColor Red
}
