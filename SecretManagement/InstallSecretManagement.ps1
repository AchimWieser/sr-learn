Write-Error '!!! Step by step documentation. Do not run !!!' -ErrorAction Stop

<#

https://devblogs.microsoft.com/powershell/secretmanagement-module-v1-1-0-preview-update/

# Breaking Change in Version 1.1.0

Currently, when SecretManagement loads an extension vault module for use,
it loads the module into the current user session.
However, this method of hosting extension vault modules prevented SecretManagement
from running in ConstrainedLanguage (CL) mode.
To fix this problem, v1.1.0 of SecretManagement now hosts extension vaults in a separate runspace session.


https://devblogs.microsoft.com/powershell/secretmanagement-and-secretstore-are-generally-available/

# SecretManagement Uses
SecretManagement is valuable in heterogeneous environments where you may want to separate
the specifics of the vault from a common script which needs secrets.
SecretManagement is also a convenience feature which allows users to simplify their interactions
with various vaults by only needing to learn a single set of cmdlets.

Since SecretManagement is a module abstraction layer in PowerShell, it becomes useful once
extension vaults are registered (more on that below). There are trade-offs between security,
usability, and specificity for any vault so it is up to the user to configure SecretManagement
to integrate with the vaults that best match their requirements, as well as to assess
the extent to which they trust any vault extensions not developed by Microsoft.

SecretManagement does not impose a common authentication for extension vaults and allows
each individual vault to provide its own mechanism.
Some may require a password or token, while others may leverage current account credentials.

Some key scenarios we have heard from PowerShell users are:
- Sharing a script across my org (or open source) without knowing the platform/local vault of all the users
- Running my deployment script in local, test and production with the change of only a single parameter (-Vault)
- Changing the backend of the authentication method to meet specific security or organizational needs without needing to update all my scripts


https://devblogs.microsoft.com/powershell/secrets-management-module-vault-extensions/

# Secret data types
The Secrets Management module supports five data types,
and the built-in local vault supports all five types.
However, extension vaults can implement any subset of the supported types:

- byte[]
- string
- SecureString
- PSCredential
- Hashtable

The Hashtable data type is used by the module to store optional vault extension parameters.
Because the additional parameters may contain secrets, the parameters are stored securely as
a Hashtable in the built-in local vault.

https://github.com/PowerShell/SecretManagement/blob/master/Docs/ARCHITECTURE.md#extension-vault-registry-file-location

# Extension vault registry file location
SecretManagement is designed to be installed and run within a user account on both Windows and
non-Windows platforms. The extension vault registry file is located in a user account protected directory.

For Windows platforms the location is:
$env:LOCALAPPDATA\Microsoft\PowerShell\secretmanagement

For non-Windows platforms the location:
$HOME/.secretmanagement


https://github.com/PowerShell/SecretManagement/blob/master/Docs/ARCHITECTURE.md#windows-managed-accounts

# Limitations
# Windows Managed Accounts
SecretManagement does not currently work for Windows managed accounts.

SecretManagement depends on both %LOCALAPPDATA% folders to store registry information, and
Data Protection APIs for safely handling secrets with the .Net SecureString type.
However, Windows managed accounts do not have profiles or %LOCALAPPDATA% folders, and
Windows Data Protection APIs do not work for managed accounts.
Consequently, SecretManagement will not run under managed accounts.

#>


# install secret management (Run as Admin)
Install-Module -Name 'Microsoft.PowerShell.SecretManagement' -Scope AllUsers -Force -Verbose

# verify
Get-Module -ListAvailable -Name '*SecretManagement'

Get-Command -Module 'Microsoft.PowerShell.SecretManagement' | Select-Object -Property Name
Get-Command -Module 'Microsoft.PowerShell.SecretManagement' |
    Select-Object -ExpandProperty name |
    ForEach-Object { Get-Help $_ | Select-Object Name, Synopsis }

<#
https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.secretmanagement/
Name
----
Get-Secret
Get-SecretInfo
Get-SecretVault
Register-SecretVault
Remove-Secret
Set-Secret
Set-SecretInfo
Set-SecretVaultDefault
Test-SecretVault
Unlock-SecretVault
Unregister-SecretVault
#>


# find secret vault extension modules in PowerShell Gallery
Find-Module -Tag 'SecretManagement'

<#
Version Name                                    ProjectUri
------- ----                                    ----------
3.5.0   Az.KeyVault                             https://github.com/Azure/azure-powershell
1.0.5   Microsoft.PowerShell.SecretStore        https://github.com/powershell/secretstore
0.9.2   SecretManagement.KeePass                https://www.github.com/JustinGrote/SecretManagement.KeePass
0.2.1   SecretManagement.LastPass               https://github.com/TylerLeonhardt/SecretManagement.LastPass
1.1.0   SecretManagement.Hashicorp.Vault.KV     https://github.com/joshcorr/SecretManagement.Hashicorp.Vault.KV
0.1.1   SecretManagement.BitWarden              https://github.com/Gaspack/SecretManagement.BitWarden
0.3     SecretManagement.CyberArk               https://github.com/aaearon/SecretManagement.CyberArk
0.1.3   SecretManagement.KeyChain               https://github.com/SteveL-MSFT/SecretManagement.KeyChain
0.0.4.6 SecretManagement.1Password              https://github.com/cdhunt/SecretManagement.1Password
0.0.9.1 SecretManagement.Chromium               https://www.github.com/JustinGrote/SecretManagement.Chromium
1.0.2   SecretManagement.Keybase                https://github.com/tiksn/SecretManagement.Keybase
1.0.435 SecretManagement.PleasantPasswordServer https://github.com/constantinhager/SecretManagement.PleasantPasswordServer
0.2     SecretManagement.DevolutionsHub
1.1.2   PersonalVault                           https://github.com/hkarthik7/PersonalVault
16.0.1  SecretManagement.Keeper                 https://github.com/Keeper-Security/secrets-manager
#>

# RUN as Admin for Scope AllUsers
Install-Module -Name 'Microsoft.PowerShell.SecretStore' -Force -Scope AllUsers -Verbose
# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.secretstore/

Install-Module -Name 'Az.KeyVault' -Force -Scope AllUsers -Verbose

Install-Module -Name 'SecretManagement.Chromium' -Force -Scope AllUsers -Verbose

# get installed secret vault modules
Get-Module -ListAvailable | Where-Object -Property Tags -Contains 'SecretManagement'




# First steps secret management

Get-SecretVault | Select-Object *

Get-Command -Module 'Microsoft.PowerShell.SecretStore' | Select-Object -Property Name
<#
Name
----
Get-SecretStoreConfiguration
Reset-SecretStore
Set-SecretStoreConfiguration
Set-SecretStorePassword
Unlock-SecretStore
#>

# register store
Register-SecretVault -Name 'SecretStore' -ModuleName 'Microsoft.PowerShell.SecretStore' # -DefaultVault

Reset-SecretStore -Scope CurrentUser -Interaction None -Force -PassThru -Authentication None
# Gefährlich, Authentication default ist Password,
# läßt man den Authentication Parameter jedoch weg und gibt kein Passwort an, kann man den Store nicht entsperren
# Löosung nochmal reset ausführen
#-Password <SecureString> -Authentication <Password | None>
# -> Reset-SecretStore : AllUsers scope is not yet supported.

Get-SecretStoreConfiguration

Install-Module -Name 'Microsoft.PowerShell.SecretStore' -Force -Scope CurrentUser -Verbose
# in PowerShell 7 ausführen

Set-Secret -Vault 'SecretStore' -Name 'Test1' -Secret 'Secret1'

Get-SecretInfo -Vault 'SecretStore'


Get-Secret -Name 'Test1' -Vault 'SecretStore' -AsPlainText

$svc = Get-Service -Name 'ScriptRunnerService'
$svc.GetType()

$js = $svc | Select-Object -Property * | ConvertTo-Json
#$js | Get-Member # string
#$js | ConvertFrom-Json | Get-Member # PSCustomObject
$myObject = $js | ConvertFrom-Json

$hashtable = @{}
foreach( $property in $myobject.psobject.properties.name )
{
    $hashtable[$property] = $myObject.$property
}

# string
Set-Secret -Vault 'SecretStore' -Name 'SRService' -Secret $js
Get-Secret -Vault 'SecretStore' -Name 'SRService' -AsPlainText | ConvertFrom-Json | Get-Member

# hashtable
Set-Secret -Vault 'SecretStore' -Name 'SRService 2' -Secret $hashtable
Get-Secret -Vault 'SecretStore' -Name 'SRService 2' -AsPlainText

# SecureString -> -SecureStringSecret Parameter
$testPwd = ConvertTo-SecureString -String 'T€st123$' -AsPlainText -Force

Set-Secret -Vault 'SecretStore' -Name 'SecString 1' -SecureStringSecret $testPwd
Get-Secret -Vault 'SecretStore' -Name 'SecString 1' -AsPlainText
$secString = Get-Secret -Vault 'SecretStore' -Name 'SecString 1'
ConvertFrom-SecureString -SecureString $secString

# PSCredential
$userName = 'Test123'
$userPwrd = ConvertTo-SecureString -String 'T€st123$' -AsPlainText -Force
$inCred = New-Object -TypeName pscredential -ArgumentList @($userName, $userPwrd)

Set-Secret -Vault 'SecretStore' -Name 'Cred 1' -Secret $inCred
$outCred = Get-Secret -Vault 'SecretStore' -Name 'Cred 1'
$outCred.UserName
$outCred.GetNetworkCredential().Password

# Hashtable
<# Set-Secret : Exception calling "WriteObject" with "4" argument(s):
"The object type for Date Hashtable entry is not supported.
Supported types are byte[], string, SecureString, PSCredential"
#>
$data = @{
    Name = 'Achim'
    Company = 'ScriptRunner'
    Date = Get-Date -Format 'yyyy-MM-dd'
    Password = $userPwrd
    Credential = $inCred
}

Set-Secret -Vault 'SecretStore' -Name 'Data 1' -Secret $data
Get-Secret -Vault 'SecretStore' -Name 'Data 1' -AsPlainText

$outData = Get-Secret -Vault 'SecretStore' -Name 'Data 1'
$secureString = $outdata.Name
$outData.Credential.GetNetworkCredential().Password

# Wie mache ich aus einem SecureString einen plain String?
# in PS7: -> ConvertFrom-SecureString -SecureString $outData.Name -AsPlainText
# in WPS: ConvertFrom-SecureString ->  encrypted standard string
# Methode 1:  System.Runtime.InteropServices.Marshal
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureString)
$plainString = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($BSTR)
$plainString
[Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)

# Methode 2: NetworkCredential
[System.Net.NetworkCredential]::new('', $SecureString).Password
# mehr PowerShell like
(New-Object -TypeName 'System.Net.NetworkCredential' -ArgumentList '', $secureString).Password
New-Object -TypeName 'System.Net.NetworkCredential' -ArgumentList '', $secureString |
    ForEach-Object { $_.Password }





# byte Array
$filePath = 'test.txt'
$filePath = Join-Path -Path (Get-Location) -ChildPath $filePath
$byteArray = [System.IO.File]::ReadAllBytes($filePath)

#$byteArray.Length
Set-Secret -Vault 'SecretStore' -Name 'Bytes 1' -Secret $byteArray
$outBytes = Get-Secret -Vault 'SecretStore' -Name 'Bytes 1'

# Don't do this!
Invoke-Expression -Command ([System.Text.Encoding]::UTF8.GetString($outBytes))


Get-SecretInfo -Vault 'SecretStore'


# Provide Metadata








