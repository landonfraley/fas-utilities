# export_shadow_accts.ps1
# Version 1.0
# Date: July 9, 2018
# Author: jeff.sani@citrix.com
# This is an example export script which can be used to create a csv file 
# for use with an import script to create Shadow Accounts in a target
# AD directory for use with Citrix FAS



# Import the ActiveDirectory Module
Import-Module ActiveDirectory

# Define the Export path -could also prompt for this if desired
$path = Split-Path -parent "C:\*.*"

#Create a variable for the date stamp in the log file
$LogDate = get-date -f yyyyMMddhhmm

# Define CSV and log file location variables
$csvfile = $path + "\export_shadow_accts_$logDate.csv"


# Prompt for AD Server
$ADServer = Read-Host -Prompt 'Input a Domain Controller to export records from'

# Get Admin account credential
$GetAdminact = Get-Credential -Message 'Enter the domain credentials to use to connect to the directory with'

# Prompt for the search base to recurse from for user accounts
$SearchBase = Read-Host -Prompt 'Input the search base in DN format where you want to recurse from - i.e. OU=MyOU,DC=contoso,DC=local'

# Prompt to specify a specific AD group within the target base from which you want to export users from
$AddGrpConfirmation = Read-Host -Prompt 'Do you wish to only export users who are a member of a specific group? Yes/No'
$TargetDate = (Get-Date)
$TargetLogonDate = $TargetDate.AddDays(-30)
switch($AddGrpConfirmation.ToLower()) 
{ 
	{($_ -EQ 'yes') -OR ($_ -EQ "y")} {
	$ExportGroupName = Read-Host -Prompt 'Specify a Group Name you wish to use as a search filter'
	$ExportGroup = Get-ADGroup -searchbase $SearchBase -server $ADServer -Credential $GetAdminact  -Filter {Name -EQ $ExportGroupName} | Select -ExpandProperty DistinguishedName
	#Write-Host "Group DN = '$ExportGroup'" 

    #Filter for users from a specific AD group that are not disabled, expired, and have logged-in within the last 30 days
	$Filter =  "memberOf -RecursiveMatch '$ExportGroup' -AND Enabled -EQ 'True' -or AccountExpirationDate -notlike '*' -and AccountExpirationDate -LT '$TargetDate' -OR LastLogonDate -notlike '*' -and LastLogonDate -LT '$TargetLogonDate'"
	#Write-Host "Filter = '$Filter'" 
	}
	default {

    # Else just filter for users that are not disabled, expired, and have logged-in within the last 30 days
	$Filter = "Enabled -EQ 'True' -or AccountExpirationDate -NOTLIKE '*' -and AccountExpirationDate -LT '$TargetDate' -OR LastLogonDate -NOTLIKE '*' -and LastLogonDate -LT '$TargetLogonDate'"
}
}

 $Users = Get-ADUser -Filter $Filter -searchbase $SearchBase -Server $ADServer -Credential $GetAdminact -Properties * | 
 Select-Object @{Label = "firstname";Expression = {$_.GivenName}},
 @{Label = "initial";Expression = {$_.Initials}},
 @{Label = "lastname";Expression = {$_.Surname}},
 @{Label = "displayname";Expression = {$_.DisplayName}},
 @{Label = "title";Expression = {$_.Title}},
 @{Label = "department";Expression = {$_.Department}},
 @{Label = "company";Expression = {$_.Company}},
 @{Label = "email";Expression = {$_.EmailAddress}},
 @{Label = "phone";Expression = {$_.OfficePhone}} |
 Sort-Object Surname | 
 Export-Csv -Path $csvfile -NoTypeInformation
