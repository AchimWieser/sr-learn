#Requires -Module Az.KeyVault

function Test-MyAzKeyVault{
	[CmdletBinding()]
	param(
		[string]$VaultName = 'SR-Learn-KeyVault',
		[string]$SecretName = 'ExamplePassword'

	)

	$secret = Get-AzKeyVaultSecret -VaultName $VaultName -Name $SecretName -AsPlainText

	if($SRXEnv){
		$SRXEnv.ResultMessage = $secret | Out-String
	}
}


