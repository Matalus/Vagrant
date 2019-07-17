REM bootstrap script to call chocolatey to install multiple packages

REM disable confirmations for package install
chocolatey feature enable -n=allowGlobalConfirmation

choco install powershell-core
choco install powershell
choco install nodejs 
choco install vscode 
choco install vscode-powershell
choco install notepadplusplus
choco install googlechrome
choco install git
choco install putty
choco install awstools.powershell

REM Reenable confirmations
chocolatey feature disable -n=allowGlobalConfirmation