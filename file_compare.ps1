$folderPath = "PUT YOUR FULL FOLDER PATH HERE IE C:\USER\WHATEVER"

# Get all files in the folder
$files = Get-ChildItem -Path $folderPath -File

# Group files by their base name (ignoring extensions)
$groupedFiles = $files | Group-Object { [System.IO.Path]::GetFileNameWithoutExtension($_.Name) }

foreach ($group in $groupedFiles) {
    # If there are multiple files with the same base name
    if ($group.Count -gt 1) {
        # Sort files by size (ascending) and keep the smallest one
        $filesToKeep = $group.Group | Sort-Object Length | Select-Object -First 1

        # Delete the larger files
        $filesToDelete = $group.Group | Where-Object { $_ -ne $filesToKeep }
        foreach ($file in $filesToDelete) {
            Write-Output "Deleting: $($file.FullName)"
            Remove-Item -Path $file.FullName -Force
        }
    }
}

Write-Output "Cleanup complete!"