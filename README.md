# fas-utilities
Useful scripts for configuring the Federated Authentication Service in XenDesktop and XenApp 7.9 and later.

* **EnableFASPlugin.ps1**  
  Configure StoreFront and the VDA to use the Federated Authentication Service credential plugin and logon data provider. Script takes a single parameter, the Store Virtual Path, e.g. "/Citrix/Store"  

* **DisableFASPlugin.ps1**  
  Configure StoreFront and the VDA to use the standard credential plugin and logon data provider. Script takes a single parameter, the Store Virtual Path, e.g. "/Citrix/Store"  

* **TrustXML.ps1**  
  Configure the XML brokers in the XenDesktop site to trust XML requests  
