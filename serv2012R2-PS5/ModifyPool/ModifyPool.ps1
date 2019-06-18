#Script for applying app pool settings

#map root dir
$RunDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

if($args -contains "Restore"){
   $ConfigPath = "$RunDir\BackupConfig.json"
}else{
   $ConfigPath = "$RunDir\config.json"
}

#Load config
$Config = (Get-Content $ConfigPath) -join "`n" | ConvertFrom-Json

Import-Module "WebAdministration" -ErrorAction Continue

Function PoolConfig ($pool){
  #Function to gather App Pool Operating Settings
   Return [pscustomobject]@{
      Name = $pool.Name
      MemLimit = if($pool.recycling.periodicRestart){
         $pool.recycling.periodicRestart.PrivateMemory
      }else{
         $null
      }
      CPULimit = if($pool.CPU){
         $pool.CPU.limit
      }else{
         0
      }
      ThrottleAction = if($pool.CPU){
         $pool.CPU.action
      }else{
         "NoAction"
      }
   }
}

Write-Host "Getting App Pool Data"
""
$AppPoolConfigPath = "/system.applicationHost/applicationPools"
$PoolData = (Get-Webconfiguration $AppPoolConfigPath).Collection

$Pools = @()

if($PoolData){
   ForEach($PoolConfig in $Config.Pools){
      Write-Host "Collecting Data for : $($PoolConfig.Name)"
      $AppPool = $PoolData | Where-Object {
         $_.Name -eq $PoolConfig.Name
      }
      if(!$AppPool){
         Write-Error "Unable to Locate App Pool : $($PoolConfig.Name)"
      
      }else{
         $CurrentConfig = PoolConfig -pool $AppPool

         if($args -contains "Apply" -or $args -contains "Restore"){
            if($args -contains "Restore"){Write-Host -ForegroundColor Yellow "Restoring Backup..."}
            if($args -contains "Apply"){Write-Host -ForegroundColor Cyan "Applying Updates..."}
            $PoolPath = "IIS:\AppPools\$($PoolConfig.Name)"
            if($PoolConfig.MemLimit -ne $CurrentConfig.MemLimit){
               Write-Host "Updating : Private Memory Limit [$($CurrentConfig.MemLimit) ==> $($PoolConfig.MemLimit)]"
               Set-ItemProperty $PoolPath -Name "recycling.periodicrestart.privateMemory" -Value $($PoolConfig.MemLimit)
            }
            if($PoolConfig.CPULimit -ne $CurrentConfig.CPULimit){
               Write-Host "Updating : CPU Limit [$($CurrentConfig.CPULimit) ==> $($PoolConfig.CPULimit)]"
               Set-ItemProperty $PoolPath -Name "cpu.limit" -Value $($PoolConfig.CPULimit)
            }
            if($PoolConfig.ThrottleAction -ne $CurrentConfig.ThrottleAction){
               Write-Host "Updating : Throttle Action [$($CurrentConfig.ThrottleAction) ==> $($PoolConfig.ThrottleAction)]"
               Set-ItemProperty $PoolPath -Name "cpu.action" -Value $($PoolConfig.ThrottleAction)
            }
         }
         $AppPool = Get-WebConfiguration "$AppPoolConfigPath/add[@name='$($AppPool.Name)']"
         $CurrentConfig = PoolConfig -pool $AppPool
         $Pools += $CurrentConfig
      }
   }
}else{
   Write-Error "Unable to get Pool data"
}
Write-Host -ForegroundColor Green "Current Config"
$Pools | Format-Table -AutoSize

if($args -contains "Backup"){
   $BackupConfig = $Config
   Write-Host "OverWriting in Mem Config..."
   $BackupConfig.Pools = $Pools
   Write-Host "Exporting to : $($RunDir)\BackupConfig.json"
   $BackupConfig | ConvertTo-Json -Depth 10 | Set-Content "$RunDir\BackupConfig.json" -Force
}