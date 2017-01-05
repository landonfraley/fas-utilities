<#
.SYNOPSIS

Configures the StoreFront store, specified by the StoreVirtualPath, with the default LogonDataProvider and CredentialPlugin.

.DESCRIPTION

Based on commands from Citrix Documentation, http://docs.citrix.com/en-us/xenapp-and-xendesktop/7-12/secure/federated-authentication-service.html, the script will change the LogonDataProvider and CredentialPlugin for the StoreFront store associated with the IIS Virtual Path (StoreVirtualPath) passed to the script (back to the default username/password mechanism).

.PARAMETER StoreVirtualPath

The IIS Virtual Path for the StoreFront store being updated, includes the leading '/'.

.EXAMPLE

DisableFASPlugin.ps1 "/Citrix/Store"
#>
param (
    [Parameter(Mandatory=$true)][string]$StoreVirtualPath
)

Set-ExecutionPolicy Bypass -Scope process
Write-Host "Importing StoreFront Modules"
Get-Module "Citrix.StoreFront.*" -ListAvailable | Import-Module

Write-Host "Updating StoreFront Auth plugin for $StoreVirtualPath"
$store = Get-STFStoreService -VirtualPath $StoreVirtualPath
$auth = Get-STFAuthenticationService -StoreService $store
Set-STFClaimsFactoryNames -AuthenticationService $auth -ClaimsFactoryName "standardClaimsFactory"
Set-STFStoreLaunchOptions -StoreService $store -VdaLogonDataProvider ""

Write-Host "Complete."
