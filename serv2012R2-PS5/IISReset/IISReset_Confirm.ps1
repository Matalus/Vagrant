#Script for Restarting IIS and verifiying events

#Set Root Dir
$RunDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

#declare path vars
$iisReset = "$($env:homedrive)\windows\system32\iisreset.exe"
$iisArgs = "/restart"

#number of attempts
$attempts = 3
$Interval = 15 #minutes to search back in logs



#function for querying winevents
Function VerifyIISReset ($Interval){
    #Define IIS WinEvents
    $Events = @(3201,3202)
    $Provider = "Microsoft-Windows-IIS-IISReset"

    $SuccessCount = $false

    $Logs = @()
    ForEach($Event in $Events){
        
        $Filter = @{
            LogName     ="System"
            ID          = $Event
            ProviderName = $Provider
            StartTime   = (Get-Date).AddMinutes(-$Interval)
            EndTime     = (Get-Date)
        }
        #params
        $Params = @{
            FilterHashtable = $Filter
            ErrorAction    = "SilentlyContinue"
        }

        Try{
            $Log = Get-WinEvent @Params
        }Catch{}
        
        if(!$Log){
            Write-Host "Unable to find Event : $($Event)"
        }else{
            Write-Host "Found: `n   EventID: $($Log[0].ID)`n   Time: $($Log[0].TimeCreated) `n   Message: $($Log[0].Message)"
            $Logs += $Log
        }
    }

    $FailCount = 0
    #check for both logs
    ForEach($ID in $Events){
        #return fail if log doesn't exist
        if($ID -notin $Logs.ID){
            $FailCount++
        }
    }

    if($FailCount -eq 0){
        Write-Host "Found all Qualifying Events"
        Return $true
    }else{
        Return $false
    }
}

#set success default to false
$success = $false

#Define proc splat array
$ProcParams = @{
    FilePath        = $iisReset
    ArgumentList    = $iisArgs
    Wait            = $true
    NoNewWindow     = $true
}

While(!$success -and $attempts -gt 0){

    Write-Host "Attempting IISReset | Attempts Remaining: $($Attempts)"

    #remove 1 attempt
    $attempts--

    #clear errors
    $Error.Clear()

    #attempt to restart IIS
    Try{
        Start-Process @ProcParams
    }Catch{
        Write-Error $_
    }

    $success = VerifyIISReset -Interval $Interval
}

if($success){
    Write-Host "IIS has been successfully reset"
}else{
    Write-Error "IIS has failed to reset"
}
