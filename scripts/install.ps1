# One-shot ComfyUI installer: portable build + custom nodes + models from manifest.json
param(
    [Parameter(Mandatory)][string]$InstallDir,
    [string]$Manifest = (Join-Path $PSScriptRoot "manifest.json"),
    [string]$SevenZip = (Join-Path $PSScriptRoot "7zr.exe")
)
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

function Step($m) { Write-Host "`n==> $m" -ForegroundColor Cyan }
function Download($url, $out) {
    Invoke-WebRequest -Uri $url -OutFile $out -UseBasicParsing
}

$m = Get-Content $Manifest -Raw | ConvertFrom-Json
$tmp = Join-Path $env:TEMP "comfyaio"
New-Item -ItemType Directory -Force $tmp, $InstallDir | Out-Null

# 1. ComfyUI portable
$root = Join-Path $InstallDir "ComfyUI_windows_portable"
if (-not (Test-Path (Join-Path $root "ComfyUI\main.py"))) {
    Step "Downloading ComfyUI portable (large, please wait)"
    $archive = Join-Path $tmp "comfyui.7z"
    Download $m.comfyui.portable_url $archive
    Step "Extracting"
    & $SevenZip x $archive "-o$InstallDir" -y | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "7z extraction failed" }
}
$py = Join-Path $root "python_embeded\python.exe"
$nodes = Join-Path $root "ComfyUI\custom_nodes"

# 2. Custom nodes (zip download, no git needed)
foreach ($n in $m.custom_nodes) {
    $dest = Join-Path $nodes $n.name
    if (Test-Path $dest) { Write-Host "skip $($n.name) (exists)"; continue }
    Step "Installing node $($n.name)"
    $zip = Join-Path $tmp "$($n.name).zip"
    Download "https://github.com/$($n.repo)/archive/HEAD.zip" $zip
    $ex = Join-Path $tmp "x_$($n.name)"
    if (Test-Path $ex) { Remove-Item $ex -Recurse -Force }
    Expand-Archive $zip $ex -Force
    Move-Item (Get-ChildItem $ex -Directory | Select-Object -First 1).FullName $dest
    $req = Join-Path $dest "requirements.txt"
    if (Test-Path $req) {
        & $py -s -m pip install -r $req --no-warn-script-location
        if ($LASTEXITCODE -ne 0) { Write-Warning "requirements failed for $($n.name)" }
    }
    $inst = Join-Path $dest "install.py"
    if (Test-Path $inst) { & $py -s $inst }
}

# 3. Models  { "url": "...", "dest": "models/checkpoints/x.safetensors" }
foreach ($mo in $m.models) {
    $out = Join-Path $root ("ComfyUI\" + ($mo.dest -replace '/', '\'))
    if (Test-Path $out) { continue }
    Step "Downloading model $($mo.dest)"
    New-Item -ItemType Directory -Force (Split-Path $out) | Out-Null
    try { Download $mo.url $out } catch { Write-Warning "Model failed (skipped): $($mo.dest) - $_"; Remove-Item $out -ErrorAction SilentlyContinue }
}

# 4. Workflows
foreach ($w in $m.workflows) {
    $dir = Join-Path $root "ComfyUI\user\default\workflows"
    New-Item -ItemType Directory -Force $dir | Out-Null
    Download $w.url (Join-Path $dir $w.name)
}

Step "Done. Run run_nvidia_gpu.bat in $root"
