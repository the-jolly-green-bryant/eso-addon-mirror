Add-Type -AssemblyName System.IO.Compression.FileSystem
$z = [System.IO.Compression.ZipFile]::OpenRead('c:\Users\ppinto.LABWEB\DungeonTrialTracker.zip')
$z.Entries | ForEach-Object { Write-Host $_.FullName }
$z.Dispose()
