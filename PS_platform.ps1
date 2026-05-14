# script: setup-oh-my-posh.ps1
# Ejecutar en una sesión de PowerShell con privilegios de administrador.

# 0) Forzar TLS 1.2 para solucionar errores de descarga de módulos
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# 1) Instalar oh-my-posh via winget (Solo si no está instalado)
if (-not (Get-Command "oh-my-posh" -ErrorAction SilentlyContinue)) {
    Write-Host "Instalando oh-my-posh via winget..." -ForegroundColor Cyan
    winget install --id JanDeDobbeleer.OhMyPosh -e --silent --accept-source-agreements --accept-package-agreements
} else {
    Write-Host "Oh My Posh ya está instalado. Omitiendo..." -ForegroundColor Green
}

# 2) Instalar módulo Terminal-Icons para añadir íconos y colores (Con verificación)
if (-not (Get-Module -ListAvailable -Name Terminal-Icons)) {
    Write-Host "Instalando módulo Terminal-Icons..." -ForegroundColor Cyan
    Install-Module -Name Terminal-Icons -Scope CurrentUser -Force -AllowClobber -SkipPublisherCheck -ErrorAction Stop
} else {
    Write-Host "El módulo Terminal-Icons ya está instalado. Omitiendo..." -ForegroundColor Green
}

# 3) Asegurar que exista PSReadLine (Con verificación)
if (-not (Get-Module -ListAvailable -Name PSReadLine)) {
    Write-Host "Instalando módulo PSReadLine..." -ForegroundColor Cyan
    Install-Module -Name PSReadLine -Scope CurrentUser -Force -AllowClobber -ErrorAction Stop
} else {
    Write-Host "El módulo PSReadLine ya está instalado. Omitiendo..." -ForegroundColor Green
}

# 4) Crear o actualizar $PROFILE (Asegurando que la carpeta contenedora exista)
$profilePath = $PROFILE
$profileDir = Split-Path -Parent $profilePath

if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
}

if (-not (Test-Path $profilePath)) {
    New-Item -ItemType File -Path $profilePath -Force | Out-Null
    Write-Host "Se creó el profile en $profilePath" -ForegroundColor Green
} else {
    Write-Host "Usando profile existente: $profilePath" -ForegroundColor Green
}

# 5) Contenido recomendado para $PROFILE
$profileContent = @'
# Inicializar oh-my-posh
oh-my-posh init pwsh --config "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/pure.omp.json" | Invoke-Expression

# Importar Terminal-Icons (Maneja automáticamente colores e íconos en dir/ls/gci)
Import-Module Terminal-Icons

# Historial predictivo en modo lista
Import-Module PSReadLine
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -HistoryNoDuplicates:$true
'@

# 6) Escribir el profile
$profileContent | Set-Content -Path $profilePath -Encoding UTF8
Write-Host "Perfil actualizado: $profilePath" -ForegroundColor Green

Write-Host "Instalación y configuración completadas. Cierra y abre PowerShell para aplicar los cambios." -ForegroundColor Yellow

