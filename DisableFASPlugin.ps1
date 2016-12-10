param (
    [Parameter(Mandatory=$true)][string]$StoreVirtualPath
)

Set-ExecutionPolicy Bypass -Scope process
Write-Host "Importing StoreFront Modules"
Get-Module "Citrix.StoreFront.*" -ListAvailable | Import-Module

$store = Get-STFStoreService -VirtualPath $StoreVirtualPath
$auth = Get-STFAuthenticationService -StoreService $store
Set-STFClaimsFactoryNames -AuthenticationService $auth -ClaimsFactoryName "standardClaimsFactory"
Set-STFStoreLaunchOptions -StoreService $store -VdaLogonDataProvider ""
