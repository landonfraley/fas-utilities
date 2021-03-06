# import_shadow_accts.ps1
# Version 1.0
# Date: July 9, 2018
# Author: jeff.sani@citrix.com
# This script can be used to create shadow accounts for the purposes of Federated Authentication
# via NetScaler as SAML SP and/or IdP and XA/XD Federated Authentication Service

# Import the ActiveDirectory Module
Import-Module ActiveDirectory
  
# Store the data from ADUsers.csv in the $ADUsers variable - note if you used the export script you will need to rename the file
$ADUsers = Import-csv C:\export_shadow_accts.csv

# Prompt for AD Server
$ADServer = Read-Host -Prompt 'Input a Domain Controller to import records to'

# Get Admin account credential
$GetAdminact = Get-Credential -Message 'Enter the domain credentials to use to connect to the directory with'

# Prompt for the search base to recurse from for user accounts
$OU = Read-Host -Prompt 'Input the base OU where you want to create the accounts - i.e. OU=MyOU,DC=contoso,DC=local'

# Prompt for the desred uPNSuffix to use for the created accounts
$uPNSuffix = Read-Host -Prompt 'Input the uPN suffix you want to use for the created accounts - i.e. contoso.local'

# Prompt to specify a specific AD group within the target base from which you want to export users from
$AddGrpConfirmation = Read-Host -Prompt 'Do you wish to add imported users to a specific group? Yes/No'
If($AddGrpConfirmation.ToLower() -EQ 'yes' -OR $AddGrpConfirmation.ToLower() -EQ "y") {
	# Add users to group
	$ImportGroupName = Read-Host -Prompt 'Specify a Group Name you wish to add imported users to'
}


# Random password generator
function Get-RandomCharacters($length, $characters) {
    $random = 1..$length | ForEach-Object { Get-Random -Maximum $characters.length }
    $private:ofs=""
    return [String]$characters[$random]
}
# Scramble password function 
function Scramble-String([string]$inputString){     
    $characterArray = $inputString.ToCharArray()   
    $scrambledStringArray = $characterArray | Get-Random -Count $characterArray.Length     
    $outputString = -join $scrambledStringArray
    return $outputString 
}
 
# Loop through each row containing user details in the CSV file 
$N = 100
# Otionally use random seed
#$N = {Get-Random -Minimum 7 -Maximum 7}

foreach ($User in $ADUsers)
{
	# Read user data from each field in each row and assign the data to a variable as below
	$N = $N + 1	
	$Firstname 	= $User.firstname
	$Middlename = $User.initial
	$Lastname 	= $User.lastname
	$DisplayName = $User.displayname
	$Username 	= 'Shadow-' + $N
    $Jobtitle   = $User.jobtitle
    $Department = $User.department
    $Company    = $User.company
    $Email      = $User.email
    $Telephone  = $User.telephone
	
	# The below lines create a random, scrambled password.  You can alter the length of the password by adjusting
	# the -length attribute for each chracter type.  Since Federation is being used for authentication, user passwords
	# in the service directory need not be  #known so can be very complex
	$Password = Get-RandomCharacters -length 5 -characters 'abcdefghiklmnoprstuvwxyz'
	$Password += Get-RandomCharacters -length 2 -characters 'ABCDEFGHKLMNOPRSTUVWXYZ'
	$Password += Get-RandomCharacters -length 2 -characters '1234567890'
	$Password += Get-RandomCharacters -length 2 -characters '!"§$%&/()=?}][{@#*+'
	$Password = Scramble-String $Password

	# Check to see if the user already exists in AD
	if (Get-ADUser -F {SamAccountName -eq $Username})
	{
		 #If user does exist, give a warning
		 Write-Warning "A user account with username $Username already exist in Active Directory."
	}
	else
	{
		# User does not exist then proceed to create the new user account
		
        #Account will be created in the OU provided by the $OU variable 
		New-ADUser `
			-Credential $GetAdminact `
			-Server $ADServer `
            -SamAccountName $Username `
            -UserPrincipalName "$Username@$uPNSuffix" `
            -Name "$Firstname $Lastname" `
            -GivenName $Firstname `
			-Initials $Middlename `
            -Surname $Lastname `
            -Enabled $True `
            -DisplayName $DisplayName `
            -Path $OU `
            -OfficePhone $Telephone `
            -EmailAddress $Email `
            -Title $Jobtitle `
            -Department $Department `
            -AccountPassword (convertto-securestring $Password -AsPlainText -Force) -ChangePasswordAtLogon $False `
			#-AccountPassword (convertto-securestring $Password -AsPlainText -Force) -ChangePasswordAtLogon $True

		# Post-account creation operations
		
		switch($AddGrpConfirmation.ToLower()) 
		{ 
			{($_ -EQ 'yes') -OR ($_ -EQ "y")} {
			# This parameter mandates that the shadow account created can only logon with a smartcard (FAS) 
			Set-ADUser -Identity $Username -SmartcardLogonRequired $True
			Set-ADUser -Identity $Username -CannotChangePassword $True
			# Add users to group
			Add-ADGroupMember -Identity $ImportGroupName -Members $Username
				}
		default {
			# This parameter mandates that the shadow account created can only logon with a smartcard (FAS) and specifies that the password cannot be changed
			Set-ADUser -Identity $Username -SmartcardLogonRequired $True
			Set-ADUser -Identity $Username -CannotChangePassword $True
		}
		
	}
}
}
