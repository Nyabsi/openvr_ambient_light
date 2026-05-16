param(
    [Parameter(Mandatory=$true)][string]$InputPath,
    [Parameter(Mandatory=$true)][string]$OutputPath,
    [Parameter(Mandatory=$true)][string]$Name
)

if (-not $InputPath -or -not (Test-Path $InputPath)) {
    throw "Invalid input path: '$InputPath'"
}

$bytes = [System.IO.File]::ReadAllBytes($InputPath)

$sb = [System.Text.StringBuilder]::new()
[void]$sb.AppendLine("#pragma once")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("static const unsigned char g_$Name[] = {")

$perLine = 16
for ($i = 0; $i -lt $bytes.Length; $i += $perLine) {
    $end   = [Math]::Min($i + $perLine, $bytes.Length) - 1
    $chunk = $bytes[$i..$end] | ForEach-Object { "0x{0:x2}" -f $_ }
    [void]$sb.Append("    ")
    [void]$sb.Append(($chunk -join ", "))
    if ($end -lt $bytes.Length - 1) { [void]$sb.Append(",") }
    [void]$sb.AppendLine()
}

[void]$sb.AppendLine("};")
[void]$sb.AppendLine("static const unsigned int g_${Name}_size = $($bytes.Length);")

$outDir = Split-Path -Parent $OutputPath
if ($outDir -and -not (Test-Path $outDir)) {
    New-Item -ItemType Directory -Path $outDir -Force | Out-Null
}
Set-Content -Encoding ASCII -Path $OutputPath -Value $sb.ToString() -NoNewline