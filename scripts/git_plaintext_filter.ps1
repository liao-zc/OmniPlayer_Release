param([Parameter(Mandatory=$true)][string]$Path)
$ErrorActionPreference = 'Stop'
$repository = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$fullPath = (Resolve-Path (Join-Path $repository $Path)).Path
if (-not $fullPath.StartsWith($repository, [StringComparison]::OrdinalIgnoreCase)) {
    throw 'Filter input must remain inside the repository.'
}
$bytes = [IO.File]::ReadAllBytes($fullPath)
if ($bytes.Length -ge 9 -and [Text.Encoding]::ASCII.GetString($bytes, 0, 9) -eq 'E-SafeNet') {
    throw "Refusing to stage encrypted text: $Path"
}
if ($bytes -contains 0) {
    throw "Refusing to stage binary content as text: $Path"
}
$strictUtf8 = [Text.UTF8Encoding]::new($false, $true)
[void]$strictUtf8.GetString($bytes)
$stdout = [Console]::OpenStandardOutput()
$stdout.Write($bytes, 0, $bytes.Length)
