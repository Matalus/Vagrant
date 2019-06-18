
#Script for Automating the taking of Dumps

$ErrorActionPreference = "Stop"

#Define Root Dir
$RunDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

$DmpDir = "$RunDir\dmp"
$DmpComplete = "$RunDir\dmpComplete"

"############ Dump Butler (take better dumps) ###################"
"++++++++++++ Created by : Matt Hamende +++++++++++++++++++++++++"

@"
_____                      1
|   D    1        0           1     1   0
|   |
|   |          0     1           0   0  1 0
\___|            _
  ||  _______  -( (-       1   0       0
  |_'(-------)  '-'        0     1 1      0
     |       /                0        1
_____,-\__..__|_____
"@
""
"############ Dump Butler (take better dumps) ###################"
""
$ProcDumpDir = "$RunDir\ProcDump"

#Test for ProcDump Executables

$ProcDmp32 = "$ProcDumpDir\ProcDump.exe"
$ProcDmp64 = "$ProcDumpDir\ProcDump64.exe"

$test32 = Test-Path $ProcDmp32
$test64 = Test-Path $ProcDmp64

if (!$test32 -or !$test64) {
   Write-Error "Missing ProcDump files in $ProcDumpDir`nPlease add these files and try again"
}


#Load config
$Config = (Get-Content "$RunDir\Config.json") -join "`n" | ConvertFrom-Json

Function GetPoolData () {
   $Worker = Get-Process -Name "w3wp" -ErrorAction SilentlyContinue
   $Columns = @(
      @{
         N = "AppPool";
         E = {
            (Get-WmiObject Win32_Process -Filter "ProcessID=$($_.ID)").GetOwner().User
         }
      },
      "ProcessName",
      "ID",
      @{
         N = "WorkingSet(MB)";
         E = {
            "{0:n2}" -f ($_.WS / 1GB)
         }
      },
      @{
         N = "CPU";
         E = {
            "{0:n2}" -f $_.CPU
         }
      }
      "StartTime"
   )
   if ($Worker) {
      Return $Worker | Select-Object $Columns
   }
   else {
      $Null
   }
}

$CpuCrit = 0
$MemCrit = 0

$PoolData = GetPoolData

Write-Host -ForegroundColor Yellow "Memory Threshold = $($Config.MemLimit)"
Write-Host -ForegroundColor Yellow "CPU    Threshold = $($Config.CPULimit)"

$PoolData | Format-Table -AutoSize
$DmpQueue = @()

#apply filter if present
if ($Config.TargetPools.Count -ge 1) {
   $PoolData = $PoolData | Where-Object {
      $_.AppPool -in $Config.TargetPools
   }
}

Write-Host -ForegroundColor Cyan "Evaulating Thresholds..."
ForEach ($pool in $PoolData) {
   #check for mem limit reached
   $membit = 0
   if ($Pool.'WorkingSet(MB)' -ge $Config.MemLimit) {
      $MemCrit++
      $membit = 1
      Write-Host -ForegroundColor Red "Memory Limit Exceeded [Theshold: $($Config.MemLimit)MB | Actual: $($pool.'WorkingSet(MB)')%]" 
      $DmpQueue += $pool 
   }
   
   #check for CPU limit reached
   if ($pool.CPU -ge $Config.CPULimit) {
      $CpuCrit++
      Write-Host -ForegroundColor Red "CPU Limit Exceeded [Theshold: $($Config.CPULimit)% | Actual: $($pool.CPU)%]" 
      if ($membit -eq 0) {
         $DmpQueue += $pool
      }
   }
}

if ($DmpQueue.Count -ge 1) {
   Write-Host -ForegroundColor Yellow "The Following App Pools Exceed Their Compute Limits and will be dumped"
   $DmpQueue | Format-Table -AutoSize

   ForEach ($Pool in $DmpQueue) {
      "Dumping : $($pool.AppPool) : PID: $($Pool.ID)"
      $ProcParams = @{
         FilePath     = $ProcDmp64
         ArgumentList = "-ma $($Pool.ID) $DmpDir\"
         Wait         = $true      
      }
      $Expression = "$($ProcParams.FilePath) $($ProcParams.ArgumentList)"
      "Executing : $Expression"
      Invoke-Expression $Expression
      #Start-Process $ProcParams

      [array]$payload = Get-ChildItem $DmpDir -Filter *.dmp
      "Found: $($payload.count) dumps"
      if ($payload) {
         $file = $payload[0]
         "Renaming $file"
         $Newname = "$($file.Directory)\$($env:COMPUTERNAME)_$($Pool.AppPool.Replace(" ","_"))_$($file.Name)"
         "to: $NewName"
         Rename-Item "$($file.FullName)" -newname $Newname

         if (Test-Path $Newname) {
            "Moving $NewName --- TO --- $($DmpComplete)"
            Move-Item $Newname -Destination $DmpComplete -Force
         }

      }
   }
}
else {
   Write-Host -ForegroundColor Green "No App Pools Exceed Compute Limits"
}



