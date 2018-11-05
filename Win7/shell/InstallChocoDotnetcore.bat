REM bootstrap script to call chocolatey to install multiple packages

REM SET Context to Choco Install Directory
IF DEFINED ChocolateyInstall (
   ECHO Changing Directory to: "%ChocolateyInstall%"
   CD %ChocolateyInstall%
) ELSE (
   ECHO ChocolateyInstall is not defined trying default
   CD C:\ProgramData\Chocolatey
)

REM disable confirmations for package install
choco feature enable -n=allowGlobalConfirmation

choco install dotnetcore

REM Reenable confirmations
choco feature disable -n=allowGlobalConfirmation