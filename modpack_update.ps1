param(
    [string]$ZipUrl = "https://github.com/ruxxzebre/scaling-winner/archive/refs/heads/main.zip",
    [string]$Destination = ""
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

function Write-Status {
    param([string]$Message)
    Write-Output $Message
}

$defaultDestination = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }
if ([string]::IsNullOrWhiteSpace($Destination)) {
    $Destination = $defaultDestination
}

$destPath = (Resolve-Path $Destination).Path
if (-not (Test-Path $destPath)) {
    throw "Destination path not found: $Destination"
}

$tempRoot = Join-Path $env:TEMP ("pd2-modpack-" + [guid]::NewGuid())
$zipPath = Join-Path $tempRoot "modpack.zip"
$extractPath = Join-Path $tempRoot "extract"
$backupRoot = Join-Path $tempRoot "backup"

New-Item -ItemType Directory -Path $extractPath -Force | Out-Null
New-Item -ItemType Directory -Path $backupRoot -Force | Out-Null

try {
    Write-Status "Downloading modpack zip..."
    $curl = Get-Command curl.exe -ErrorAction SilentlyContinue
    if ($curl) {
        & $curl.Source -L --fail --retry 3 --retry-delay 2 -o $zipPath $ZipUrl
        if ($LASTEXITCODE -ne 0) {
            throw "curl failed with exit code $LASTEXITCODE"
        }
    } else {
        Invoke-WebRequest -Uri $ZipUrl -OutFile $zipPath -UseBasicParsing
    }

    Write-Status "Extracting zip..."
    Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force

    $rootDir = Get-ChildItem -Path $extractPath | Where-Object { $_.PSIsContainer } | Select-Object -First 1
    if (-not $rootDir) {
        throw "Unexpected zip layout: no root folder found."
    }

    $sourceRoot = $rootDir.FullName
    $preserveRelPaths = @(
        "mods\\saves",
        "mods\\logs",
        "mods\\downloads"
    )

    foreach ($rel in $preserveRelPaths) {
        $src = Join-Path $destPath $rel
        if (Test-Path $src) {
            $backupParent = Join-Path $backupRoot (Split-Path $rel -Parent)
            New-Item -ItemType Directory -Path $backupParent -Force | Out-Null
            Copy-Item -Path $src -Destination $backupParent -Recurse -Force
        }
    }

    $srcMods = Join-Path $sourceRoot "mods"
    $destMods = Join-Path $destPath "mods"
    if (Test-Path $destMods) {
        $preserveNames = @("saves", "logs", "downloads")
        Get-ChildItem -Path $destMods -Force | ForEach-Object {
            if ($preserveNames -contains $_.Name) {
                return
            }
            Remove-Item -Path $_.FullName -Recurse -Force
        }
    } else {
        New-Item -ItemType Directory -Path $destMods -Force | Out-Null
    }

    if (Test-Path $srcMods) {
        Copy-Item -Path (Join-Path $srcMods "*") -Destination $destMods -Recurse -Force
    }

    $srcOverrides = Join-Path $sourceRoot "assets\\mod_overrides"
    if (Test-Path $srcOverrides) {
        $destOverrides = Join-Path $destPath "assets\\mod_overrides"
        if (Test-Path $destOverrides) {
            Remove-Item -Path $destOverrides -Recurse -Force
        }
        $destAssets = Join-Path $destPath "assets"
        New-Item -ItemType Directory -Path $destAssets -Force | Out-Null
        Copy-Item -Path $srcOverrides -Destination $destAssets -Recurse -Force
    }

    $rootFiles = @(
        "WSOCK32.dll",
        "README.md",
        ".gitignore",
        ".luarc.json"
    )
    foreach ($file in $rootFiles) {
        $srcFile = Join-Path $sourceRoot $file
        if (Test-Path $srcFile) {
            Copy-Item -Path $srcFile -Destination (Join-Path $destPath $file) -Force
        }
    }

    foreach ($rel in $preserveRelPaths) {
        $backupPath = Join-Path $backupRoot $rel
        if (Test-Path $backupPath) {
            $restoreParent = Join-Path $destPath (Split-Path $rel -Parent)
            New-Item -ItemType Directory -Path $restoreParent -Force | Out-Null
            Copy-Item -Path $backupPath -Destination $restoreParent -Recurse -Force
        }
    }

    $cachePath = Join-Path $destPath "mods\\ModpackUpdater\\version_cache.json"
    $cacheDir = Split-Path $cachePath -Parent
    if (Test-Path $cacheDir) {
        $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        $cache = @{
            version = "zip"
            commit = "Updated via zip"
            date = $timestamp
            cached_at = $timestamp
        }
        $cache | ConvertTo-Json -Depth 3 | Set-Content -Path $cachePath -Encoding ASCII
    }

    Write-Status "Update complete. Restart the game to apply changes."
} finally {
    if (Test-Path $tempRoot) {
        Remove-Item -Path $tempRoot -Recurse -Force
    }
}
