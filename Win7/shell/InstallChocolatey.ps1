#bootstrap script to install Chocolately Package Manager

#Install for Chocolatey
$ChocoInstallPath = "$env:SystemDrive\ProgramData\Chocolatey\bin"

#Checks is Chocolately is already installed and downloads / installs if not
if (!(Test-Path $ChocoInstallPath)) {
    Invoke-Expression ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
}