#Script to deploy test sites

Import-Module WebAdministration

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
    $SiteName = "TestSite$($enum).com"

    $SiteParams = @{
        Name = $SiteName
        Port = $port
        HostHeader = $SiteName
        PhysicalPath = "$($contentPath)\$($SiteName)"
        Force = $true
    }

    
    #Create site dir
    if(!(Test-Path $($SiteParams.PhysicalPath))){
        "Creating Directory : $($SiteParams.PhysicalPath)"
        New-Item -ItemType Directory $SiteParams.PhysicalPath
    }

    #create site
    "Creating Site : $($SiteName)"
    New-WebSite @SiteParams

    #Create App Pool
    "Creating App Pool : $($SiteName)"
    New-WebAppPool $SiteName -Force

    #Create Site Binding
    "Binding Site to : $port"
    New-Item IIS:\Sites\$SiteName -physicalPath $SiteFolderPath -bindings @{protocol="http";bindingInformation=":$($port):"+$SiteName} -Force

    #Assign Pool
    "Assigning Site to pool: $SiteName"
    Set-ItemProperty IIS:\Sites\$SiteName -name applicationPool -value $SiteName -Force

    #setting Pool to AR
    Set-ItemProperty IIS:\AppPools\$SiteName -name startMode -value "AlwaysRunning" -Force

    #Add test content
    $homePath = "$($SiteParams.PhysicalPath)\Default.htm"
    "Creating default.htm : $homePath"
    "<h1>Hello IIS</h1>" | Set-Content $homePath -Force

    #Deploy CPU Test
    Get-Content .\CPUTest.aspx | Set-Content "$($SiteParams.PhysicalPath)\cputest.aspx" -Force


    #Deploy Virtual Directory
    "Creating Virtual Directory"
    New-WebVirtualDirectory -Site $SiteName -Name "App$enum" -PhysicalPath $SiteParams.PhysicalPath -Force

    #Convert to Web App
    "Converting to Web App"
    ConvertTo-WebApplication "IIS:\Sites\$SiteName\App$enum" -ApplicationPool $SiteName -Force

    $Port++
}