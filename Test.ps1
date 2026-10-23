param([switch]$WithUI)
$ErrorActionPreference = 'Stop'
$godotPath = 'C:\Program Files (x86)\Godot\Godot.exe'
$artifactPath = Join-Path $PSScriptRoot 'artifacts'
New-Item -ItemType Directory -Path $artifactPath -Force | Out-Null
Set-Content -LiteralPath (Join-Path $artifactPath '.gdignore') -Value ''
$env:APPDATA = Join-Path $artifactPath 'test-appdata'
New-Item -ItemType Directory -Path $env:APPDATA -Force | Out-Null

function Invoke-GodotCheck([string]$Name, [string]$Arguments) {
    $outputPath = Join-Path $artifactPath "$Name.log"
    $errorPath = Join-Path $artifactPath "$Name-errors.log"
    $process = Start-Process -FilePath $godotPath -ArgumentList $Arguments -WorkingDirectory $PSScriptRoot -WindowStyle Hidden -Wait -PassThru -RedirectStandardOutput $outputPath -RedirectStandardError $errorPath
    Get-Content -LiteralPath $outputPath
    $errors = Get-Content -LiteralPath $errorPath -Raw
    $actionableErrors = $errors -replace '(?m)^ERROR: Failed to read the root certificate store\.\r?\n   at: get_system_ca_certificates[^\r\n]*(\r?\n)?', ''
    if ($process.ExitCode -ne 0 -or $actionableErrors -match '(?m)^ERROR:|SCRIPT ERROR|FAIL /|Failed to load script') {
        Write-Output $errors
        throw "$Name failed (exit $($process.ExitCode))."
    }
    if ($errors -match 'Failed to read the root certificate store') {
        Write-Output 'Godot reported an OS certificate-store warning; the offline checks completed.'
    }
}

Invoke-GodotCheck 'import' '--headless --path . --editor --import --quit'
Invoke-GodotCheck 'rules' '--headless --path . --script res://tests/test_rules.gd'
Invoke-GodotCheck 'workshop' '--headless --path . --script res://tests/test_workshop.gd'
Invoke-GodotCheck 'animation' '--headless --path . --script res://tests/test_teamster_animation.gd'
Invoke-GodotCheck 'variants' '--headless --path . --script res://tests/test_teamster_variants.gd'
if ($WithUI) {
    Invoke-GodotCheck 'workshop-ui' '--path . --script res://tests/test_workshop_ui.gd'
    Invoke-GodotCheck 'ui' '--path . --script res://tests/test_ui.gd'
    Invoke-GodotCheck 'art-tests' '--path . --script res://tests/test_art.gd'
    Invoke-GodotCheck 'ova-rendering' '--path . --script res://tests/test_ova_rendering.gd'
}
    Invoke-GodotCheck 'wet-lighting' '--path . --script res://tests/test_wet_lighting.gd'
