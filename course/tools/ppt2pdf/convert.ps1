<#
.SYNOPSIS
    Batch-convert .ppt / .pptx files to PDF using the local PowerPoint installation (COM automation).

.DESCRIPTION
    Recursively scans the target directory (default: the "course" folder, two levels up
    from this script) for .ppt and .pptx files and exports each one as a PDF in the
    SAME folder as the source file, using the same base filename.

.PARAMETER Path
    Root folder to scan recursively. Defaults to the "course" directory.

.PARAMETER Force
    Re-convert and overwrite even if a same-named .pdf already exists next to the source.

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\convert.ps1
    powershell -ExecutionPolicy Bypass -File .\convert.ps1 -Path "C:\path\to\course" -Force
#>

param(
    [string]$Path = (Join-Path $PSScriptRoot "..\.."),
    [switch]$Force
)

$Path = (Resolve-Path $Path).Path
$ppSaveAsPDF = 32  # PpSaveAsFileType.ppSaveAsPDF

Write-Host "Scanning for .ppt / .pptx files under: $Path"

$files = Get-ChildItem -Path $Path -Recurse -Include *.ppt, *.pptx -File |
Where-Object { $_.Name -notlike '~$*' }

if (-not $files) {
    Write-Host "No .ppt/.pptx files found."
    exit 0
}

$ppApp = New-Object -ComObject PowerPoint.Application

$converted = 0
$skipped = 0
$failed = 0

try {
    foreach ($file in $files) {
        $pdfPath = [System.IO.Path]::ChangeExtension($file.FullName, "pdf")

        if ((Test-Path $pdfPath) -and -not $Force) {
            Write-Host "Skip (already exists): $($file.Name)"
            $skipped++
            continue
        }

        Write-Host "Converting: $($file.FullName)"
        $pres = $null
        try {
            $pres = $ppApp.Presentations.Open($file.FullName, $true, $false, $false)
            $pres.SaveAs($pdfPath, $ppSaveAsPDF)
            $converted++
        }
        catch {
            Write-Warning "Failed to convert $($file.FullName): $_"
            $failed++
        }
        finally {
            if ($pres) { $pres.Close() }
        }
    }
}
finally {
    $ppApp.Quit()
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($ppApp) | Out-Null
}

Write-Host ""
Write-Host "Done. Converted: $converted, Skipped: $skipped, Failed: $failed"

#powershell -ExecutionPolicy Bypass -File "course\tools\ppt2pdf\convert.ps1" -Force
# powershell -ExecutionPolicy Bypass -File "course\tools\ppt2pdf\convert.ps1" -Path "course\CHP3"