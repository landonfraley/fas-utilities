# fas-utilities
Useful scripts for configuring the Federated Authentication Service in XenDesktop and XenApp 7.9 and later.

* **EnableFASPlugin.ps1**  
  Configure StoreFront and the VDA to use the Federated Authentication Service credential plugin and logon data provider. Script takes a single parameter, the Store Virtual Path, e.g. "/Citrix/Store"  

* **DisableFASPlugin.ps1**  
  Configure StoreFront and the VDA to use the standard credential plugin and logon data provider. Script takes a single parameter, the Store Virtual Path, e.g. "/Citrix/Store"  

* **TrustXML.ps1**  
  Configure the XML brokers in the XenDesktop site to trust XML requests  

# Advanced Use Case Flow Diagram and Export/Import Scripts

* **NSG-FAS.pptx**
  Complete flow diagram for an advanced deployment of XenApp/XenDesktop with NetScaler and FAS
  
* **export_shadow_accts.ps1**
  PowerShell script to facilitate the export of user accounts from a primary domain

* **import_shadow_accts.ps1**
  PowerShell script to facilitate the creation of shadow accounts in a secondary domain, to be used with the export_shadow_accts.ps1 script.
  
