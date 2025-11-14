# setup.ps1
[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

$configPath = Join-Path $PSScriptRoot 'delphi.config.json'
$examplePath = Join-Path $PSScriptRoot 'delphi.config.example.json'

# Check of example bestaat
if (!(Test-Path $examplePath)) {
    Write-Error "delphi.config.example.json niet gevonden!"
    exit 1
}

# Check of config al bestaat
if ((Test-Path $configPath) -and !$Force) {
    Write-Host 'delphi.config.json bestaat al. Gebruik -Force om te overschrijven.' -ForegroundColor Yellow
    exit 0
}

# Kopieer example naar config
Copy-Item $examplePath $configPath
Write-Host 'delphi.config.json aangemaakt van example.' -ForegroundColor Green

# Probeer automatisch te detecteren
Write-Host $configPath
$fileContent = Get-Content $configPath
Write-Host $fileContent
$config = $fileContent | ConvertFrom-Json

# Zoek Delphi installatie
$delphiRoots = @(
    "c:\Program Files (x86)\Embarcadero\Studio",
    "c:\dev\embarcadero\studio"
)

$foundDelphi = $false
foreach ($root in $delphiRoots) {
    if (Test-Path $root) {
        # Zoek hoogste versie
        $versions = Get-ChildItem $root -Directory | 
                    Where-Object { $_.Name -match '^\d+\.\d+$' } |
                    Sort-Object Name -Descending
        
        if ($versions) {
            $latestVersion = $versions[0]
            $dcc32Path = Join-Path $latestVersion.FullName "bin\dcc32.exe"
            
            if (Test-Path $dcc32Path) {
                Write-Host "Delphi gevonden: $dcc32Path" -ForegroundColor Cyan
                $config.dcc32 = $dcc32Path
                
                # Update andere paths
                $versionPath = $latestVersion.FullName
                $config.basePaths.lib = Join-Path $versionPath "lib\Win32"
                $config.basePaths.include = Join-Path $versionPath "include"
                
                $foundDelphi = $true
                break
            }
        }
    }
}

# Zoek gebruiker specifieke paths
$userDocs = [Environment]::GetFolderPath('MyDocuments')
$embarcaderoUserPath = Join-Path $userDocs "Embarcadero\Studio"

if (Test-Path $embarcaderoUserPath) {
    $versions = Get-ChildItem $embarcaderoUserPath -Directory |
                Where-Object { $_.Name -match '^\d+\.\d+$' } |
                Sort-Object Name -Descending
    
    if ($versions) {
        $latestUserVersion = $versions[0].FullName
        $config.basePaths.imports = Join-Path $latestUserVersion "Imports"
        Write-Host "User paths gevonden: $latestUserVersion" -ForegroundColor Cyan
    }
}

# Public documents paths
$publicDocs = [Environment]::GetFolderPath('CommonDocuments')
$embarcaderoPublicPath = Join-Path $publicDocs "Embarcadero\Studio"

if (Test-Path $embarcaderoPublicPath) {
    $versions = Get-ChildItem $embarcaderoPublicPath -Directory |
                Where-Object { $_.Name -match '^\d+\.\d+$' } |
                Sort-Object Name -Descending
    
    if ($versions) {
        $latestPublicVersion = $versions[0].FullName
        $config.basePaths.bpl = Join-Path $latestPublicVersion "Bpl"
        $config.basePaths.dcp = Join-Path $latestPublicVersion "Dcp"
        $config.basePaths.hpp = Join-Path $latestPublicVersion "hpp"
        Write-Host "Public paths gevonden: $latestPublicVersion" -ForegroundColor Cyan
    }
}

# Sla gewijzigde config op
$config | ConvertTo-Json -Depth 10 | Set-Content $configPath

Write-Host ''
if ($foundDelphi) {
    Write-Host '✓ Setup voltooid met auto-detectie' -ForegroundColor Green
} else {
    Write-Host '⚠ Delphi niet automatisch gevonden' -ForegroundColor Yellow
}

Write-Host ''
Write-Host 'Controleer en pas aan waar nodig:' -ForegroundColor White
Write-Host '  - delphi.config.json' -ForegroundColor Gray
Write-Host ''
Write-Host 'Vooral de projectPaths sectie moet je handmatig aanpassen:' -ForegroundColor White
Write-Host '  - spring4d' -ForegroundColor Gray
Write-Host '  - jcl' -ForegroundColor Gray
Write-Host '  - devexpress' -ForegroundColor Gray
Write-Host '  - etc.' -ForegroundColor Gray
Write-Host ''
Write-Host 'Voer daarna uit: .\build.ps1' -ForegroundColor Cyan