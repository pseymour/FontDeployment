Set-StrictMode -Version "latest"

$latestReleaseJson = Invoke-WebRequest -UseBasicParsing -Uri "https://api.github.com/repos/microsoft/cascadia-code/releases/latest" | ConvertFrom-Json
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

            [string]$outputFilePath = Join-Path $workingFolderPath $latestReleaseJson.assets[$i].name
            Invoke-WebRequest -Uri $latestReleaseJson.assets[$i].browser_download_url -ContentType $latestReleaseJson.assets[$i].content_type -OutFile $outputFilePath
            if (Test-Path -Path $outputFilePath)
            {
                Expand-Archive -Path $outputFilePath -DestinationPath $workingFolderPath
                [string]$versionString = $latestReleaseJson.tag_name
                $versionString = $versionString -replace "[^0-9\.]", [string]::Empty
                [int[]]$versionParts = @(1,0,0,0)
                [string[]]$splitVersionString = @($versionString -split "\.")
                for ([int]$i = ($versionParts.Length - 1); $i -ge ($versionParts.Length - $splitVersionString.Length); $i--)
                {
                    $versionParts[$i] = $splitVersionString[($i - $versionParts.Length)]
                }
                $versionString = $versionParts -join "."
                [Version]$fontVersion = $null
                if (![Version]::TryParse($versionString, [ref] $fontVersion))
                {
                    Write-Error $versionString
                }

                if (Test-Path -Path (Join-Path $workingFolderPath "ttf"))
                {
                    & (Join-Path -Path $PSScriptRoot -ChildPath "Build Font MSI.ps1") -ProductManufacturer "Microsoft" -ProductName $latestReleaseJson.name -ProductVersion $fontVersion -UpgradeCode "{F6F91FFC-0807-4CBD-B027-77460BEBABA5}" -FontSourceFolder (Join-Path $workingFolderPath "ttf") -IconPath (Join-Path $PSScriptRoot "icons\ttf.ico") -OutputMSIPath (Join-Path $workingFolderPath "$($latestReleaseJson.name).msi")
                }
            }
        }
    }
}
