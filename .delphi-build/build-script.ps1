# build.ps1
[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('Debug', 'Release')]
    [string]$Configuration = 'Debug',
    
    [Parameter(Mandatory=$false)]
    [string]$Project = 'Hypothesis4D.UnitTests.dpr',
    
    [Parameter(Mandatory=$false)]
    [switch]$Clean
)

$ErrorActionPreference = 'Stop'

# Config laden
$configPath = Join-Path $PSScriptRoot 'delphi.config.json'
if (!(Test-Path $configPath)) {
    Write-Error "delphi.config.json niet gevonden. Voer eerst setup.ps1 uit."
    exit 1
}

$config = Get-Content $configPath | ConvertFrom-Json

# Compiler path valideren
if (!(Test-Path $config.dcc32)) {
    Write-Error "dcc32.exe niet gevonden op: $($config.dcc32)"
    exit 1
}

# Output directory
$currentDir = Get-Location
$outputDir = Join-Path $currentDir "Win32\$Configuration"
if ($Clean -and (Test-Path $outputDir)) {
    Write-Host "Cleaning $outputDir..." -ForegroundColor Yellow
    Remove-Item $outputDir -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $outputDir | Out-Null

# Build search paths
function Build-PathList {
    param([string[]]$paths, [string]$suffix = '')
    $result = @()
    foreach ($path in $paths) {
        if ($suffix) {
            $fullPath = Join-Path $path $suffix
        } else {
            $fullPath = $path
        }
        if (Test-Path $fullPath) {
            $result += $fullPath
        } else {
            Write-Warning "Path niet gevonden: $fullPath"
        }
    }
    return $result -join ';'
}

# Basis paths samenstellen
$libPath = Join-Path $config.basePaths.lib $Configuration.ToLower()
$commonPaths = @(
    $libPath,
    $config.basePaths.imports,
    (Join-Path $config.basePaths.imports 'Win32'),
    $config.basePaths.dcp,
    $config.basePaths.include
)

# Project paths toevoegen
$projectDebugPaths = @()
$projectReleasePaths = @()

foreach ($prop in $config.projectPaths.PSObject.Properties) {
    $basePath = $prop.Value
    
    if ($prop.Name -eq "jcl") {
        $projectDebugPaths += Join-Path $basePath "lib\d29\win32\debug"
        $projectReleasePaths += Join-Path $basePath "lib\d29\win32"
    } elseif ($prop.Name -eq "devexpress") {
        $projectDebugPaths += $basePath 
        $projectReleasePaths += $basePath 
    } else {
        $projectDebugPaths += Join-Path $basePath "Win32\Debug"
        $projectReleasePaths += Join-Path $basePath "Win32\Release"
    }
}

# Conditionally add debug or release paths
if ($Configuration -eq 'Debug') {
    $searchPaths = $commonPaths + $projectDebugPaths
} else {
    $searchPaths = $commonPaths + $projectReleasePaths
}

$unitPath = Build-PathList $searchPaths
$includePath = $unitPath
$objPath = $unitPath
$resPath = $unitPath

# Compiler argumenten
$compilerArgs = @(
    '-$O-'  # Optimization off (voor Debug)
    '-$W+'  # Stack frames on
    '-$R+'  # Range checking
    '-$Q+'  # Overflow checking
    '--no-config'
    '-M'    # Make modified
    '-Q'    # Quiet compile
    "-TX.exe"
    "-AGenerics.Collections=System.Generics.Collections;Generics.Defaults=System.Generics.Defaults;WinTypes=Winapi.Windows;WinProcs=Winapi.Windows;DbiTypes=BDE;DbiProcs=BDE;DbiErrs=BDE"
    "-DDEBUG"
    "-E$outputDir"
    "-I$includePath"
    "-LE$($config.basePaths.bpl)"
    "-LN$($config.basePaths.dcp)"
    "-NU$outputDir"
    "-NSWinapi;System.Win;Data.Win;Datasnap.Win;Web.Win;Soap.Win;Xml.Win;Bde;System;Xml;Data;Datasnap;Web;Soap;"
    "-O$objPath"
    "-R$resPath"
    "-U$unitPath"
    '-V'    # Debug info in EXE
    '-VN'   # Debug info in separate TDS
    "-NB$($config.basePaths.dcp)"
    "-NH$($config.basePaths.hpp)\Win32"
    "-NO$outputDir"
    $Project
)

# Release specifieke aanpassingen
if ($Configuration -eq 'Release') {
    $compilerArgs = $compilerArgs | Where-Object { $_ -notmatch '^\-\$[ORQ]' }
    $compilerArgs = @('-$O+', '-$R-', '-$Q-') + $compilerArgs
    $compilerArgs = $compilerArgs | Where-Object { $_ -ne '-DDEBUG' }
}

# Build uitvoeren
Write-Host "Building $Project ($Configuration)..." -ForegroundColor Cyan
Write-Host "Output: $outputDir" -ForegroundColor Gray

$startTime = Get-Date
& $config.dcc32 $compilerArgs

if ($LASTEXITCODE -eq 0) {
    $duration = (Get-Date) - $startTime
    Write-Host "`nBuild succeeded in $([math]::Round($duration.TotalSeconds, 1))s" -ForegroundColor Green
    exit 0
} else {
    Write-Host "`nBuild failed with exit code $LASTEXITCODE" -ForegroundColor Red
    exit $LASTEXITCODE
}