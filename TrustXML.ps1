Set-ExecutionPolicy Bypass -Scope process

Write-Host "Adding Citrix Broker Admin commands"
Add-PSSnapin Citrix.Broker.Admin.V2

Write-Host "Configuring site to trust XML requests"
Set-BrokerSite -TrustRequestsSentToTheXmlServicePort $true

Write-Host "Complete."
