<#
  Builds typescript-language-server.exe from launcher.cs.

  WHY
  npm installs the TypeScript language server as an extensionless sh script plus
  .cmd and .ps1 wrappers. It never ships a .exe. Tools that spawn language servers
  without a shell resolve only .exe on Windows, so a bare-name spawn cannot find
  it. This builds a real PE .exe that execs node with the parent stdio passed
  through as inherited handles.

  USAGE
    powershell -ExecutionPolicy Bypass -File lsp/build.ps1 [-OutDir <dir>]

  Without -OutDir, the .exe lands next to this script. Pass the global npm
  directory to install it where a no-shell spawn will find it. Safe to re-run at
  any time. Only needed on Windows.
#>

param(
  [string]$OutDir = ""
)

$ErrorActionPreference = "Stop"

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$src = Join-Path $here "launcher.cs"

if (-not (Test-Path $src)) { throw "launcher source not found: $src" }

if ([string]::IsNullOrWhiteSpace($OutDir)) { $OutDir = $here }
$out = Join-Path $OutDir "typescript-language-server.exe"

$csc = Get-ChildItem "C:\Windows\Microsoft.NET\Framework64" -Filter "csc.exe" -Recurse -ErrorAction SilentlyContinue |
  Sort-Object FullName -Descending | Select-Object -First 1
if (-not $csc) { throw "csc.exe not found under C:\Windows\Microsoft.NET\Framework64" }

Write-Host "compiling with $($csc.FullName)"
& $csc.FullName /target:exe /nologo /optimize+ /out:$out $src
if ($LASTEXITCODE -ne 0) { throw "csc failed with exit $LASTEXITCODE" }
if (-not (Test-Path $out)) { throw "build produced no output at $out" }

Write-Host ("built {0} ({1} bytes)" -f $out, (Get-Item $out).Length)

$bytes = [System.IO.File]::ReadAllBytes($out)[0..1]
if ("$([char]$bytes[0])$([char]$bytes[1])" -ne "MZ") { throw "output is not a PE binary" }
Write-Host "PE header OK"
Write-Host "done"
