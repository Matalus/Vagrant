#Get New Computer Name
$ComputerName = $Env:COMPUTERNAME
$SID = (Get-WmiObject Win32_UserAccount)[0].SID

Write-Host -ForegroundColor White "ComputerName : $($ComputerName) : SID $($SID)"

