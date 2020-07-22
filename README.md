# Font Deployment

This is a collection of scripts for deploying fonts on Windows. The user specifies a folder containing font files, and the script generates a Windows Installer (MSI) file
to deploy those fonts.

The scripts rely on the WiX Toolset (https://wixtoolset.org/).

* `Build Font MSI.ps1` is a generalized script for making an MSI to install the fonts in a given folder.
* `Build Cascadia MSI.ps1` is a script specifically for Microsoft's Cascadia Code font (https://github.com/microsoft/cascadia-code).
The script downloads the latest release and builds an MSI for it.
