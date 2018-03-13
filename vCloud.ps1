$ConfigFile = "./Config.json"
$Configs = Get-Content -Raw -Path $ConfigFile -ErrorAction Continue | ConvertFrom-Json -ErrorAction Continue

if (!($Configs)) {
    Throw "Import JSON Config Failed"
    }

$VcdHost = $Configs.Base.VcdHost
$BasicAuth = $Configs.Base.BasicAuth

#region: Login
$Uri = "https://$VcdHost/api/sessions"
$Authorization = 'Basic {0}' -f $BasicAuth
$Headers =  @{'accept' = 'application/vnd.vmware.vcloud.session+xml;version=27.0'; 'Authorization' = $Authorization}
$ResponseHeaders = $null
$Login = Invoke-RestMethod -uri $Uri -Method Post -Headers $Headers -ResponseHeadersVariable 'ResponseHeaders'
#endregion

#region: Get vApps
$Uri = "https://$VcdHost/api/query?type=vApp"
$Headers =  @{'accept' = 'application/*+xml;version=27.0'; 'x-vcloud-authorization' = [String]$ResponseHeaders.'x-vcloud-authorization'}
[XML]$vApps = Invoke-RestMethod -uri $Uri -Method Get -Headers $Headers
#endregion

#region: Get VMs
$Uri = "https://$VcdHost/api/query?type=vm"
$Headers =  @{'accept' = 'application/*+xml;version=27.0'; 'x-vcloud-authorization' = [String]$ResponseHeaders.'x-vcloud-authorization'}
[XML]$VMs = Invoke-RestMethod -uri $Uri -Method Get -Headers $Headers
#endregion

#region: Get orgNetworks
$Uri = "https://$VcdHost/api/query?type=orgNetwork"
$Headers =  @{'accept' = 'application/*+xml;version=27.0'; 'x-vcloud-authorization' = [String]$ResponseHeaders.'x-vcloud-authorization'}
[XML]$orgNetworks = Invoke-RestMethod -uri $Uri -Method Get -Headers $Headers
#endregion

#region: Output
## Simple Stats
$vAppsTotal = $vApps.QueryResultRecords.VAppRecord.Count
$body="vCloudStats vAppCountTotal=$vAppsTotal"
Write-Host $body
$VMsTotal = ($VMs.QueryResultRecords.VMRecord | Where-Object {$_.isVAppTemplate -ne "true"}).Count
$body="vCloudStats VMCountTotal=$VMsTotal"
Write-Host $body
$VMsPoweredOff = ($VMs.QueryResultRecords.VMRecord | Where-Object {$_.isVAppTemplate -ne "true" -and  $_.status -eq "POWERED_OFF"}).Count
$body="vCloudStats VMCountPoweredOff=$VMsPoweredOff"
Write-Host $body
$orgNetworksTotal = $orgNetworks.QueryResultRecords.OrgNetworkRecord.Count
$body="vCloudStats orgNetworkCountTotal=$orgNetworksTotal"
Write-Host $body

## vApp Details
foreach ($item in $vApps.QueryResultRecords.VAppRecord) {
    $body = "vCloudStats,vApp=$($item.name),status=$($item.status) numberOfVMs=$($item.numberOfVMs),numberOfCpus=$($item.numberOfCpus),cpuAllocationInMhz=$($item.cpuAllocationInMhz),memoryAllocationMB=$($item.memoryAllocationMB),storageKB=$($item.storageKB)"
        Write-Host $body
}
## orgNetwork Details
foreach ($item in $orgNetworks.QueryResultRecords.OrgNetworkRecord) {
    $Uri = [string]$item.href + "/allocatedAddresses"
    $Headers =  @{'accept' = 'application/*+xml;version=27.0'; 'x-vcloud-authorization' = [String]$ResponseHeaders.'x-vcloud-authorization'}
    [XML]$orgNetworkAllocated = Invoke-RestMethod -uri $Uri -Method Get -Headers $Headers
    $AllocatedIpAddressesTotal = $orgNetworkAllocated.AllocatedIpAddresses.IpAddress.Count
    $body = "vCloudStats,orgNetwork=$($item.name),gateway=$($item.gateway) AllocatedIpAddressesTotal=$AllocatedIpAddressesTotal"
        Write-Host $body
}
#endregion

#region: Logout
$Uri = "https://$VcdHost/api/session"
$Headers =  @{'accept' = 'application/vnd.vmware.vcloud.session+xml;version=27.0'; 'x-vcloud-authorization' = [String]$ResponseHeaders.'x-vcloud-authorization'}
$Logout = Invoke-RestMethod -uri $Uri -Method Delete -Headers $Headers
#endregion

#region: Cleanup Confidential Data
Clear-Variable -Name BasicAuth, VcdHost, Authorization, Login, ResponseHeaders
#endregion