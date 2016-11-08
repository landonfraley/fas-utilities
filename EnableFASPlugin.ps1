param (
    [Parameter(Mandatory=$true)][string]$StoreVirtualPath
)

Set-ExecutionPolicy Bypass -Scope process
Write-Host "Importing StoreFront Modules"
Get-Module "Citrix.StoreFront.*" -ListAvailable | Import-Module

Write-Host "Updating plugin for $StoreVirtualPath"
$store = Get-STFStoreService -VirtualPath $StoreVirtualPath
$auth = Get-STFAuthenticationService -StoreService $store
Set-STFClaimsFactoryNames -AuthenticationService $auth -ClaimsFactoryName "FASClaimsFactory"
Set-STFStoreLaunchOptions -StoreService $store -VdaLogonDataProvider "FASLogonDataProvider"

Write-Host "Complete."
