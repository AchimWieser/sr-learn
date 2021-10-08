#Requires -Module Az.KeyVault

Write-Error '!!! Step by step documentation. Do not run !!!' -ErrorAction Stop
<#

https://docs.microsoft.com/en-us/azure/key-vault/quick-create-powershell

#>

function Test-quick-create-powershell-az-keyvault
{
    param(
        [Parameter(Mandatory)]
        [PSCredential]$AzAccountCred
    )

    Write-Error '!!! Step by step documentation. Do not run !!!' -ErrorAction Stop

    Connect-AzAccount -Credential $AzAccountCred -ErrorAction Stop
    $azContext = Get-AzContext
    $accountId = $azContext.Account.Id

    New-AzResourceGroup -Name 'RG_SR_Learn' -Location 'germanywestcentral'

    Get-AzResourceGroup

    New-AzKeyVault -Name 'SR-Learn-KeyVault' -ResourceGroupName 'RG_SR_Learn' -Location 'germanywestcentral'

    Get-AzKeyVault

    Set-AzKeyVaultAccessPolicy -VaultName 'SR-Learn-KeyVault' -UserPrincipalName $accountId -PermissionsToSecrets get,set,delete,list

    $secretvalue = ConvertTo-SecureString "T€st123!" -AsPlainText -Force
    Set-AzKeyVaultSecret -VaultName 'SR-Learn-KeyVault' -Name "ExamplePassword" -SecretValue $secretvalue

    Get-AzKeyVaultSecret -VaultName 'SR-Learn-KeyVault' -Name "ExamplePassword" -AsPlainText
}


<# result of -> New-AzKeyVault -Name 'SR-Learn-KeyVault' -ResourceGroupName 'RG_SR_Learn' -Location 'germanywestcentral'
Vault Name                          : SR-Learn-KeyVault
Resource Group Name                 : RG_SR_Learn
Location                            : germanywestcentral
Resource ID                         : /subscriptions/<SubscriptionID>/resourceGroups/RG_SR_Learn/providers/Microsoft.KeyVault/vaults/SR-Learn-KeyVault
Vault URI                           : https://<keyvault-name-id>.vault.azure.net/
Tenant ID                           : <TenantID>
SKU                                 : Standard
Enabled For Deployment?             : False
Enabled For Template Deployment?    : False
Enabled For Disk Encryption?        : False
Enabled For RBAC Authorization?     : False
Soft Delete Enabled?                : True
Soft Delete Retention Period (days) : 90
Purge Protection Enabled?           :
Access Policies                     :
                                      Tenant ID                                  : <UUID>
                                      Object ID                                  : <UUID>
                                      Application ID                             :
                                      Display Name                               : <Display Name>
                                      Permissions to Keys                        : get, create, delete, list, update, import, backup, restore, recover
                                      Permissions to Secrets                     : get, list, set, delete, backup, restore, recover
                                      Permissions to Certificates                : get, delete, list, create, import, update, deleteissuers, getissuers, listissuers,
                                      managecontacts, manageissuers, setissuers, recover, backup, restore
                                      Permissions to (Key Vault Managed) Storage : delete, deletesas, get, getsas, list, listsas, regeneratekey, set, setsas, update, recover,
                                      backup, restore


Network Rule Set                    :
                                      Default Action                             : Allow
                                      Bypass                                     : AzureServices
                                      IP Rules                                   :
                                      Virtual Network Rules                      :

Tags                                :
#>

<#


https://docs.microsoft.com/en-us/powershell/module/az.keyvault/


https://portal.azure.com/

https://github.com/PowerShell/Modules/blob/master/Modules/Microsoft.PowerShell.SecretManagement/




#>
<#
https://devblogs.microsoft.com/powershell/secrets-management-module-vault-extensions/

Register-SecretsVault registers a PowerShell module as an extension vault for the current user context.
Validation is performed to ensure the module either provides the required binary with implementing type or the required script commands.
If a dictionary of additional parameters is specified then it will be stored securely in the built-in local vault.
#>
