<#
.SYNOPSIS

Configures the StoreFront store, specified by the StoreVirtualPath, with the FAS LogonDataProvider and CredentialPlugin.

.DESCRIPTION

Based on commands from Citrix Documentation, http://docs.citrix.com/en-us/xenapp-and-xendesktop/7-12/secure/federated-authentication-service.html, the script will update the LogonDataProvider and CredentialPlugin for the StoreFront store associated with the IIS Virtual Path (StoreVirtualPath) passed to the script.

.PARAMETER StoreVirtualPath

The IIS Virtual Path for the StoreFront store being updated, includes the leading '/'.

.EXAMPLE
EnableFASPlugin.ps1 "/Citrix/Store"

#>
param (
    [Parameter(Mandatory=$true)][string]$StoreVirtualPath
)

Set-ExecutionPolicy Bypass -Scope process
Write-Host "Importing StoreFront Modules"
Get-Module "Citrix.StoreFront.*" -ListAvailable | Import-Module

Write-Host "Updating LogonDataProvider/CredentialPlugin for $StoreVirtualPath"
$store = Get-STFStoreService -VirtualPath $StoreVirtualPath
$auth = Get-STFAuthenticationService -StoreService $store
Set-STFClaimsFactoryNames -AuthenticationService $auth -ClaimsFactoryName "FASClaimsFactory"
Set-STFStoreLaunchOptions -StoreService $store -VdaLogonDataProvider "FASLogonDataProvider"

Write-Host "Complete."
