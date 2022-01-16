#Define PCSX2 path
$runFolder = Split-Path $MyInvocation.MyCommand.Path -Parent
$buildbotUrl = 'https://buildbot.orphis.net/pcsx2/'

function DownloadAndExtractNewVersion {
    param (
        [string]$DownloadUrl,
        [string]$Version
    )
    
    #Define paths
    $latestBuildPath = $runFolder + '\latest'
    $archivePath = $latestBuildPath + '\pcsx2.7z'
    $latestVersionFilePath = $latestBuildPath + '\pcsx2latest\version.ini'
    $portablePath = $latestBuildPath + '\pcsx2latest\portable.ini'
    
    #Create temp folder for new version
    New-Item -Path $latestBuildPath -ItemType 'directory'

    #Download PCSX2
    Invoke-WebRequest $DownloadUrl -OutFile $archivePath

    #Extract downloaded archive to latest folder
    Expand-7Zip -ArchiveFileName $archivePath -TargetPath $latestBuildPath

    #Rename extracted folder
    Get-ChildItem $latestBuildPath -Exclude pcsx2.7z | Rename-Item -NewName 'pcsx2latest'
    
    #Write version to file
    Set-Content -Path $latestVersionFilePath -Value $Version

    #Overwrite portable.ini contents
    Set-Content -Path $portablePath -Value 'RunWizard=0'

    #Copy/Overwrite what is in the emulator folder
    Copy-Item -Path ($latestBuildPath + '\pcsx2latest\*') -Destination $runFolder -Force -Recurse -PassThru

    #Delete downloaded PCSX2 files when done to prep for next version
    Remove-Item -Path $latestBuildPath -recurse
}

#Entry point
(Invoke-WebRequest $buildbotUrl).Content.Split("`n") | Where-Object { $_ -match '>download<' } | Select-Object -f 1 | ForEach-Object {
    #Get latest version name
    $newVersion = $_.split('"')[1]

    #Get current version present, if any
    if (Test-Path ($runFolder + '\version.ini')) {
        $currentVersion = Get-Content -Path ($runFolder + '\version.ini')
    }

    #Compare version names; if our version is not the most recent one, then download it
    if ($currentVersion -ne $newVersion) {
        $downloadUrl = 'https://buildbot.orphis.net' + $_.split("'")[1].replace('amp;', '')
        DownloadAndExtractNewVersion -DownloadUrl $downloadUrl -Version $newVersion
        Write-Host 'PCSX2 updated'
    }
    else {
        Write-Host 'PCSX2 already up to date'
    }
}

Read-Host