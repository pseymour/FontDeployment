param
(
    [Parameter(Mandatory = $true)]
    [String]$ProductManufacturer,
    [Parameter(Mandatory = $true)]
    [String]$ProductName,
    [Parameter(Mandatory = $false)]
    [Version]$ProductVersion = [Version]::new(1,0,0,0),
    [Parameter(Mandatory = $false)]
    [Guid]$UpgradeCode = (New-Guid),
    [Parameter(Mandatory = $true)]
    [String]$FontSourceFolder,
    [String]$IconPath = (Join-Path $PSScriptRoot "icons\font folder.ico"),
    [Parameter(Mandatory = $true)]
    [String]$OutputMSIPath,
    [Parameter(Mandatory = $false)]
    [Switch]$KeepTempFiles
)

Set-StrictMode -Version "latest"

[string]$heatTransform = Join-Path $PSScriptRoot "heat-transform.xslt"

[string]$outputWxsPath = [string]::Empty
do
{
    $outputWxsPath = [System.IO.Path]::GetTempFileName()
    if (Test-Path -Path $outputWxsPath) { Remove-Item -Path $outputWxsPath -Recurse -Force }
    $outputWxsPath = [System.IO.Path]::ChangeExtension($outputWxsPath, "wxs")
} while (Test-Path -Path $outputWxsPath)
Write-Verbose "output .wxs path : `"$($outputWxsPath)`""

[string]$outputWixObjPath = [string]::Empty
do
{
    $outputWixObjPath = [System.IO.Path]::GetTempFileName()
    if (Test-Path -Path $outputWixObjPath) { Remove-Item -Path $outputWixObjPath -Recurse -Force }
    $outputWixObjPath = [System.IO.Path]::ChangeExtension($outputWixObjPath, "wixobj")
} while (Test-Path -Path $outputWixObjPath)
Write-Verbose "output .wixobj path : `"$($outputWixObjPath)`""

[Version]$latestWixVersion = [Version]::new(0,0,0)
[string]$installRoot = [string]::Empty

Get-ChildItem -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows Installer XML" |
ForEach-Object {
    [Microsoft.Win32.RegistryKey]$subkey = $_
    if ($subkey.GetValueNames() -contains "ProductVersion")
    {
        [Version]$productVersionValue = [Version]::new($subkey.GetValue("ProductVersion", "0.0"))
        if ($productVersionValue -gt $latestWixVersion)
        {
            $latestWixVersion = $productVersionValue
            $installRoot = $subkey.GetValue("InstallRoot", [string]::Empty)
        }
    }
    $subkey.Close()
}

if (Test-Path -Path $installRoot)
{
    [string]$heatPath = Join-Path $installRoot "heat.exe"
    [string]$candlePath = Join-Path $installRoot "candle.exe"
    [string]$lightPath = Join-Path $installRoot "light.exe"
    
    if (Test-Path -Path $heatPath)
    {
        & $heatPath dir $FontSourceFolder -cg ($ProductName -replace "[\s]", [string]::Empty) -nologo -t $heatTransform -gg -template product -out $outputWxsPath -srd
        if (Test-Path -Path $outputWxsPath)
        {
            [xml]$wxsDocument = Get-Content -Path $outputWxsPath
            [hashtable]$productAttributes = @{
                "Manufacturer" = $ProductManufacturer;
                "Name" = $ProductName;
                "Version" = $ProductVersion;
                "UpgradeCode" = $UpgradeCode.ToString("B").ToUpperInvariant();
            }
            $productAttributes.Keys |
            ForEach-Object {
                if ($wxsDocument.Wix.Product.HasAttribute($_))
                {
                    $wxsDocument.Wix.Product.SetAttribute($_, $productAttributes[$_])
                }
            }

            if ($wxsDocument.Wix.Product.Icon.HasAttribute("SourceFile"))
            {
                $wxsDocument.Wix.Product.Icon.SetAttribute("SourceFile", $IconPath)
            }

            $wxsDocument.Save($outputWxsPath)
        }

        & $candlePath -nologo $outputWxsPath -out $outputWixObjPath
        & $lightPath -nologo -out $OutputMSIPath -b $FontSourceFolder $outputWixObjPath
    }
}

if ((Test-Path -Path $outputWxsPath) -and (-not $KeepTempFiles)) { Remove-Item -Path $outputWxsPath -ErrorAction SilentlyContinue }
if ((Test-Path -Path $outputWixObjPath) -and (-not $KeepTempFiles)) { Remove-Item -Path $outputWixObjPath -ErrorAction SilentlyContinue }
