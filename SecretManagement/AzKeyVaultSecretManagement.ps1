
param(
    [Parameter(Mandatory)]
    [PSCredential]$AzAccountCred
)

Write-Error '!!! Step by step documentation. Do not run !!!' -ErrorAction Stop

Connect-AzAccount -Credential $AzAccountCred -ErrorAction Stop

$azContext = Get-AzContext
$subscriptionId = $azContext.Subscription.Id
#$tenantId = $azContext.Tenant.Id

Get-AzKeyVault


$vaultName = 'SRLearnAzKeyVault'
$AZKVaultName = 'SR-Learn-KeyVault'
$moduleName = 'Az.KeyVault'

$VaultParameters = @{ AZKVaultName = $AZKVaultName; SubscriptionId = $subscriptionId }

Unregister-SecretVault -Name $vaultName
Register-SecretVault -Module $moduleName -Name $vaultName -VaultParameters $VaultParameters


#Get-Command -Module $moduleName | Select-Object -Property Name

Get-SecretVault | Select-Object *

# secureString secret
$secString = ConvertTo-SecureString -String 'T€st123!' -AsPlainText -Force
Set-Secret -Vault $vaultName -Name 'ExamplePassword' -SecureStringSecret $secString

Get-Secret -Vault $vaultName -Name 'ExamplePassword' -AsPlainText

# string secret
Set-Secret -Vault $vaultName -Name 'Test123' -Secret 'T€st123!'
#-Metadata @{ SRLearn = 'SecretManagement'; Date = '2021-10-07' }
#metadata not supported
#'secretName' does not match expected pattern '^[0-9a-zA-Z-]+$

Get-Secret -Vault $vaultName -Name 'Test123' -AsPlainText

Get-SecretInfo -Vault $vaultName

Disconnect-AzAccount

