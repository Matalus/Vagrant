REM bootstrap script to call chocolatey to install multiple packages
REM add comments to packages you don't need

REM disable confirmations for package install
chocolatey feature enable -n=allowGlobalConfirmation

choco install dotnet4.7.2
choco install dotnetcore-windowshosting
choco install dotnetcore
choco install powershell
:: choco install jre8
:: choco install nodejs 
:: choco install vscode 
:: choco install vscode-powershell
choco install notepadplusplus
choco install googlechrome
:: choco install git
:: choco install putty
:: choco install awstools.powershell

REM Reenable confirmations
chocolatey feature disable -n=allowGlobalConfirmation