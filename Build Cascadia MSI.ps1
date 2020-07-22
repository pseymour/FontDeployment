Set-StrictMode -Version "latest"
Clear-Host

$latestReleaseJson = Invoke-WebRequest -Uri "https://api.github.com/repos/microsoft/cascadia-code/releases/latest" | ConvertFrom-Json
if ($null -ne $latestReleaseJson)
{
    Write-Host "latest release: `"$($latestReleaseJson.name)`""
    if (($null -ne $latestReleaseJson.assets) -and ($latestReleaseJson.assets.Count -gt 0))
    {
        for ([int]$i = 0; $i -lt $latestReleaseJson.assets.Count; $i++)
        {
            [string]$workingFolderPath = [System.IO.Path]::GetTempFileName()
            if (Test-Path -Path $workingFolderPath) { Remove-Item -Path $workingFolderPath -Recurse -Force }
            if (!(Test-Path -Path $workingFolderPath)) { New-Item -Path $workingFolderPath -ItemType "Directory" | Out-Null }
            <#
            [string]$workingFolderPath = "C:\Users\patrick.seymour\AppData\Local\Temp\tmp6401.tmp"
            #>
            Write-Host "working folder: `"$($workingFolderPath)`""

            [string]$outputFilePath = Join-Path $workingFolderPath $latestReleaseJson.assets[$i].name
            Invoke-WebRequest -Uri $latestReleaseJson.assets[$i].browser_download_url -ContentType $latestReleaseJson.assets[$i].content_type -OutFile $outputFilePath
            if (Test-Path -Path $outputFilePath)
            {
                Expand-Archive -Path $outputFilePath -DestinationPath $workingFolderPath
                if (Test-Path -Path (Join-Path $workingFolderPath "ttf"))
                {
                    & (Join-Path -Path $PSScriptRoot -ChildPath "Build Font MSI.ps1") -ProductManufacturer "Microsoft" -ProductName $latestReleaseJson.name -FontSourceFolder (Join-Path $workingFolderPath "ttf") -IconPath (Join-Path $PSScriptRoot "icons\ttf.ico") -OutputMSIPath (Join-Path $workingFolderPath "$($latestReleaseJson.name).msi")
                }
            }
        }
    }
}
