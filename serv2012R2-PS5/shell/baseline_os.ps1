#verify new SID and set Computername
$ComputerName = "MATTBOX"

$SID = (Get-WmiObject Win32_UserAccount)[0].SID

Write-Host "SID : $($SID)"

Write-Host "Setting New Computer Name"
Rename-Computer -NewName $ComputerName -Force

Write-Host "Setting Execution Policy - Bypass"
Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\PowerShell" -Name ExecutionPolicy -Value ByPass -Force
