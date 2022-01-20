#Define PCSX2 path, repo url and version needed
$runFolder = Split-Path $MyInvocation.MyCommand.Path -Parent
$githubUrl = 'https://api.github.com/repos/PCSX2/pcsx2/releases'
$releaseType = '*' + '64bit-AVX2.7z'

function DownloadAndExtractNewVersion {
    param ([string]$DownloadUrl, [string]$Version)
    
    #Define paths
    $tempDirectory = $runFolder + '\latest'
    $archivePath = $tempDirectory + '\pcsx2.7z'
    $latestBuildDirectory = $tempDirectory + '\pcsx2latest'
    $latestVersionFilePath = $latestBuildDirectory + '\version.ini'
    
    #Create temp folder for new version
    New-Item -Path $tempDirectory -ItemType 'directory'

    #Download and extract PCSX2
    Invoke-WebRequest $DownloadUrl -OutFile $archivePath
    Expand-7Zip -ArchiveFileName $archivePath -TargetPath $latestBuildDirectory

    #Write version to file
    Set-Content -Path $latestVersionFilePath -Value $Version

    #Copy/Overwrite what is in the emulator folder
    Copy-Item -Path ($latestBuildDirectory + '\*') -Destination $runFolder -Force -Recurse -PassThru

    #Delete downloaded PCSX2 files when done to prep for next version
    Remove-Item -Path $tempDirectory -recurse
}

#Entry point
$releases = Invoke-WebRequest $githubUrl | ConvertFrom-Json

#Get latest version name
$newVersion = $releases[0].tag_name

#Get download url
$downloadUrl = ($releases[0].assets | Where-Object { $_.name -like $releaseType }).browser_download_url

#Get current version present, if any
if (Test-Path ($runFolder + '\version.ini')) {
    $currentVersion = Get-Content -Path ($runFolder + '\version.ini')
}

#Compare version names; if our version is not the most recent one, then download it
if ($currentVersion -ne $newVersion) {
    DownloadAndExtractNewVersion -DownloadUrl $downloadUrl -Version $newVersion
    Write-Host 'PCSX2 updated'
    Write-Host 'Prevously installed version version: '$currentVersion 
    Write-Host 'Current version: '$newVersion 
}
else {
    Write-Host 'PCSX2 already up to date'
    Write-Host 'Current version: '$currentVersion 
}

Read-Host