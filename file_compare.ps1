# Get the folder path where this script is located
$folderPath = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Output "Processing folder: $folderPath"
Write-Output ""

# Get all files in the folder
$files = Get-ChildItem -Path $folderPath -File

if ($files.Count -eq 0) {
    Write-Output "No files found in the folder."
    Read-Host "Press Enter to exit"
    exit
}

Write-Output "Found $($files.Count) files to analyze..."
Write-Output ""

# Group files by their base name (ignoring extensions)
$groupedFiles = $files | Group-Object { [System.IO.Path]::GetFileNameWithoutExtension($_.Name) }

$deletedCount = 0
$processedGroups = 0
$totalSizeBeforeCleanup = 0
$totalSizeAfterCleanup = 0

foreach ($group in $groupedFiles) {
    # If there are multiple files with the same base name
    if ($group.Count -gt 1) {
        $processedGroups++
        
        # Sort files by size (ascending) and keep the smallest one
        $sortedFiles = $group.Group | Sort-Object Length
        $filesToKeep = $sortedFiles | Select-Object -First 1
        $largestFile = $sortedFiles | Select-Object -Last 1
        $filesToDelete = $group.Group | Where-Object { $_ -ne $filesToKeep }
        
        # Add the largest file from this group to the "before" total
        $totalSizeBeforeCleanup += $largestFile.Length
        
        # Add the kept file to the "after" total
        $totalSizeAfterCleanup += $filesToKeep.Length
        
        Write-Output "Processing: $($group.Name) - keeping smallest of $($group.Count) files"
        
        # Delete the larger files
        foreach ($file in $filesToDelete) {
            Remove-Item -Path $file.FullName -Force
            $deletedCount++
        }
    }
}

Write-Output "Cleanup complete!"
Write-Output "Processed $processedGroups groups with duplicates"
Write-Output "Deleted $deletedCount files"
Write-Output ""
Write-Output "COMPRESSION EFFICIENCY SUMMARY:"
Write-Output "Total size using largest files: $([math]::Round($totalSizeBeforeCleanup/1MB, 2)) MB"
Write-Output "Total size using smallest files: $([math]::Round($totalSizeAfterCleanup/1MB, 2)) MB"
$totalSpaceSaved = $totalSizeBeforeCleanup - $totalSizeAfterCleanup
Write-Output "Space saved: $([math]::Round($totalSpaceSaved/1MB, 2)) MB"
if ($totalSizeBeforeCleanup -gt 0) {
    $percentageSaved = ($totalSpaceSaved / $totalSizeBeforeCleanup) * 100
    Write-Output "Compression efficiency: $([math]::Round($percentageSaved, 1))% space saved"
}
if ($totalSpaceSaved -gt 1024) {
    Write-Output "Space saved: $([math]::Round($totalSpaceSaved/1GB, 2)) GB"
}
Write-Output ""
Write-Output "Script location: $folderPath"

# Pause so user can see results
Read-Host "Press Enter to exit"
