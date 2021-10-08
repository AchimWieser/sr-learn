# ScriptRunner Learn - Secret Management

2021-10-07

## Secret Management Module

- What is the Secret Management Module?
- Operational scenarios
- Installation and Setup
- Secret Management Module and ScriptRunner

## Overview

### Breaking Change in Version 1.1.0

Currently, when SecretManagement loads an extension vault module for use,
it loads the module into the current user session.
However, this method of hosting extension vault modules prevented SecretManagement
from running in ConstrainedLanguage (CL) mode.
To fix this problem, v1.1.0 of SecretManagement now hosts extension vaults in a separate runspace session.

<https://devblogs.microsoft.com/powershell/secretmanagement-module-v1-1-0-preview-update/>

### SecretManagement Uses

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

<https://devblogs.microsoft.com/powershell/secretmanagement-and-secretstore-are-generally-available/>

### Secret data types

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

<https://devblogs.microsoft.com/powershell/secrets-management-module-vault-extensions/>

### Extension vault registry file location

SecretManagement is designed to be installed and run within a user account on both Windows and
non-Windows platforms. The extension vault registry file is located in a user account protected directory.

For Windows platforms the location is:

- `%LOCALAPPDATA%\Microsoft\PowerShell\secretmanagement`

For non-Windows platforms the location:

- `$HOME/.secretmanagement`

<https://github.com/PowerShell/SecretManagement/blob/master/Docs/ARCHITECTURE.md#extension-vault-registry-file-location>

### Limitations

#### Windows Managed Accounts

SecretManagement does not currently work for Windows managed accounts.

SecretManagement depends on both `%LOCALAPPDATA%` folders to store registry information, and
**Data Protection APIs** for safely handling secrets with the .Net SecureString type.
However, Windows managed accounts do not have profiles or `%LOCALAPPDATA%` folders, and
**Windows Data Protection APIs** do _not_ work for managed accounts.
Consequently, SecretManagement will _not_ run under managed accounts.

<https://github.com/PowerShell/SecretManagement/blob/master/Docs/ARCHITECTURE.md#windows-managed-accounts>

## Secret Management Cmdlets

Name                   | Synopsis
----                   | --------
Get-Secret             | Finds and returns a secret by name from registered vaults.
Get-SecretInfo         | Finds and returns secret metadata information of one or more secrets.
Get-SecretVault        | Finds and returns registered vault information.
Register-SecretVault   | Registers a SecretManagement extension vault module for the current user.
Remove-Secret          | Removes a secret from a specified registered extension vault.
Set-Secret             | Adds a secret to a SecretManagement registered vault.
Set-SecretInfo         | Adds or replaces additional secret metadata to a secret currently stored in a vault.
Set-SecretVaultDefault | Sets the provided vault name as the default vault for the current user.
Test-SecretVault       | Runs an extension vault self test.
Unlock-SecretVault     | Unlocks an extension vault so that it can be access in the current session.
Unregister-SecretVault | Un-registers an extension vault from SecretManagement for the current user.

<https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.secretmanagement/>

## Overview available Secret Stores in PowerShellGallery

<https://www.powershellgallery.com/packages?q=tag%3ASecretManagement>

```powershell
Find-Module -Tag 'SecretManagement'
```

Version | Name                                   | ProjectUri
------- | ----                                   | ----------
3.5.0   | Az.KeyVault                            | <https://github.com/Azure/azure-powershell>
1.0.5   | Microsoft.PowerShell.SecretStore       | <https://github.com/powershell/secretstore>
0.9.2   | SecretManagement.KeePass               | <https://www.github.com/JustinGrote/SecretManagement.KeePass>
0.2.1   | SecretManagement.LastPass              | <https://github.com/TylerLeonhardt/SecretManagement.LastPass>
1.1.0   | SecretManagement.Hashicorp.Vault.KV    | <https://github.com/joshcorr/SecretManagement.Hashicorp.Vault.KV>
0.1.1   | SecretManagement.BitWarden             | <https://github.com/Gaspack/SecretManagement.BitWarden>
0.3     | SecretManagement.CyberArk              | <https://github.com/aaearon/SecretManagement.CyberArk>
0.1.3   | SecretManagement.KeyChain              | <https://github.com/SteveL-MSFT/SecretManagement.KeyChain>
0.0.4.6 | SecretManagement.1Password             | <https://github.com/cdhunt/SecretManagement.1Password>
0.0.9.1 | SecretManagement.Chromium              | <https://www.github.com/JustinGrote/SecretManagement.Chromium>
1.0.2   | SecretManagement.Keybase               | <https://github.com/tiksn/SecretManagement.Keybase>
1.0.435 | SecretManagement.PleasantPasswordServer| <https://github.com/constantinhager/SecretManagement.PleasantPasswordServer>
0.2     | SecretManagement.DevolutionsHub|
1.1.2   | PersonalVault                          | <https://github.com/hkarthik7/PersonalVault>
16.0.1  | SecretManagement.Keeper                | <https://github.com/Keeper-Security/secrets-manager>

## Code Examples for ScriptRunner

- [Local SecretStore](./scriptrunner/TestLocalStore.ps1)
- [Azure Key Vault](./scriptrunner/TestAzKeyVault.ps1)
