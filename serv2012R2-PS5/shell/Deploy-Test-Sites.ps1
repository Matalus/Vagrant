#Script to deploy test sites


#import Admin Module
Import-Module WebAdministration -ErrorAction SilentlyContinue

$RunDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

#Stop and Delete all Existing Sites
$Sites = Get-WebSite 
$Sites | Stop-WebSite -ErrorAction SilentlyContinue
$Sites | Remove-WebSite -ErrorAction SilentlyContinue

#Delete all App Pools
Remove-WebAppPool *


#create content dir if not exist
$contentPath = "c:\dfs\TESTCLUSTER\content"
if(!(test-path $contentPath)){
    "Creating Content Directory"
    new-item -ItemType Directory $contentPath -Force
}

#Enum sites
$Count = 1..5
$port = 80


ForEach($site in $Count){
    #Site params

    $enum = "{0:d2}" -f $site
    $SiteName = "TestSite$($enum).org"

    #Create App Pool
    "Creating App Pool : $($SiteName)"
    $null = New-WebAppPool $SiteName -Force
    #setting Pool to AR
    Set-ItemProperty IIS:\AppPools\$SiteName -name startMode -value "AlwaysRunning" -Force

    $SiteParams = @{
        Name = $SiteName
        Port = $port
        HostHeader = $SiteName
        PhysicalPath = "$($contentPath)\$($SiteName)"
        ApplicationPool = $SiteName
        Force = $true
    }

    
    #Create site dir
    if(!(Test-Path $($SiteParams.PhysicalPath))){
        "Creating Directory : $($SiteParams.PhysicalPath)"
        $nulls = New-Item -ItemType Directory $SiteParams.PhysicalPath
    }


    #create site
    "Creating Site : $($SiteName)"
    $null = New-WebSite @SiteParams

    #Set preload
    Set-ItemProperty "IIS:\Sites\$SiteName" -Name "applicationDefaults.preloadEnabled" -Value $true -Force

    #Create Self signed cert
    $CertExist = Get-ChildItem Cert:\LocalMachine\My | Where-Object{
        $_.Subject -match $SiteName
    }
    if(!$CertExist){
        "Creating Cert for: $SiteName"
        $CertExist = New-SelfSignedCertificate -DnsName $SiteName -CertStoreLocation "Cert:\LocalMachine\My"
    }

    #Create Site Binding
    "Binding Site to : $port"
    $BindParams = @{
        Name       = $SiteName
        Port       = 443
        Protocol   = "https"
        HostHeader = $SiteName
        SSLFlags   = 1

    }

    $null = New-WebBinding @BindParams
    $BindExist = Get-WebBinding -Name $SiteName -Protocol "https" -Port 443 -ErrorAction SilentlyContinue

    #Bind Cert
    Write-Host "Binding Cert: $($CertExist[0].Subject) |  $($CertExist[0].Thumbprint)"
    $BindExist.AddSslCertificate($CertExist[0].Thumbprint, "my")

    #Deploy Content to each test site
    Write-Host "Copying Content Files"
    Get-ChildItem "$RunDir\TestSite" | Copy-Item -Destination $SiteParams.PhysicalPath -Force

    #Deploy Virtual Directory
    "Creating Virtual Directory"
    $null = New-WebVirtualDirectory -Site $SiteName -Name "App$enum" -PhysicalPath $SiteParams.PhysicalPath -Force

    #Convert to Web App
    "Converting to Web App"
    $null = ConvertTo-WebApplication "IIS:\Sites\$SiteName\App$enum" -ApplicationPool $SiteName -Force

    Write-Host ""
}

"Deploying Host File"
Copy-Item "$RunDir\Hosts" -Destination "c:\windows\System32\drivers\etc" -Force