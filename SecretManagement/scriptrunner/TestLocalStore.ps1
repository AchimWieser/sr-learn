#Requires -Module Microsoft.PowerShell.SecretStore, Microsoft.PowerShell.SecretManagement

function Test-LocalStore {
	[CmdletBinding()]
	param(
		[string]$VaultName = 'SecretStore',
		[string]$SecretName = 'Data 1'
	)

	$secret = Get-Secret -Vault $VaultName -Name $SecretName -AsPlainText

	if($SRXEnv){
		$SRXEnv.ResultMessage = $secret | Out-String
	}

}

function Register-SRStore {
	[CmdletBinding()]
	param(
		[string]$VaultName = 'SRSecretStore',
		[string]$ModuleName = 'Microsoft.PowerShell.SecretStore',
		[hashtable]$VaultParameters,
		[string]$Description,
		[PSCredential]$StorePasswordCred,
		[bool]$Reset = $false
	)

	$registerArgs = @{}
	if($PSBoundParameters.ContainsKey('VaultParameters')) {
		$registerArgs.VaultParameters = $VaultParameters
	}
	if($PSBoundParameters.ContainsKey('Description')) {
		$registerArgs.Description = $Description
	}

	"`nLocalAppDataPath: '$($env:LOCALAPPDATA)'"

	if ($ModuleName -eq 'Microsoft.PowerShell.SecretStore') {
		"`nSet SecretStore ..."

		$storeConfigArgs = @{}
		if ($PSBoundParameters.ContainsKey('StorePasswordCred')) {
			$storeConfigArgs.Authentication = 'Password'
			$storeConfigArgs.Password = $StorePasswordCred.Password
		}
		else {
			$storeConfigArgs.Authentication = 'None'
		}

		# Get-SecretStoreConfiguration
		<#  -> Get-SecretStoreConfiguration: System.NotImplementedException,
			Microsoft.PowerShell.SecretStore.GetSecretStoreConfiguration - Interactive input is not available for ScriptRunner.
		#>

		if ($Reset) {
			"`nReset-SecretStore"
			Reset-SecretStore -Scope CurrentUser -Interaction None -Force -PassThru -Authentication None
		}

		"`nSet-SecretStoreConfiguration"
		Set-SecretStoreConfiguration -PassThru -Scope CurrentUser -Interaction None @storeConfigArgs -Confirm:$false
	}

	"`nRegister-SecretVault"
	Register-SecretVault -Name $VaultName -ModuleName $ModuleName -PassThru @registerArgs -AllowClobber | Out-String

	if ($PSBoundParameters.ContainsKey('StorePasswordCred')) {
		"`nUnlock-SecretStore"
		Unlock-SecretStore -Password $StorePasswordCred.Password
	}

	"`nGet-SecretStoreConfiguration"
	Get-SecretStoreConfiguration | Out-String

	"`nGet-SecretVault"
	Get-SecretVault -Name $VaultName | Select-Object * | Out-String

	"`nGet-SecretInfo"
	Get-SecretInfo -Vault $VaultName | Select-Object * | Out-String

}


function Set-SRStoreSecret {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory)]
		[string]$SecretName,
		[Parameter(Mandatory, HelpMessage = 'ASRDisplay(Password)')]
		$Secret,
		[string]$VaultName = 'SRSecretStore',
		[Parameter(HelpMessage = 'ASRDisplay(MultiLine)')]
		[hashtable]$Metadata = @{},
		[PSCredential]$StorePasswordCred
	)

	if ($PSBoundParameters.ContainsKey('StorePasswordCred')) {
		Unlock-SecretStore -Password $StorePasswordCred.Password
	}

	$secretArgs = @{}
	if ($PSBoundParameters.ContainsKey('Metadata')) {
		$secretArgs.Metadata = $Metadata
	}

	Set-Secret -Vault $VaultName -Name $SecretName -Secret $Secret @secretArgs

	"Get-SecretInfo"
	Get-SecretInfo -Vault $VaultName -Name $SecretName | Select-Object -Property Name, Type, Metadata
}


function Get-SRStoreSecret {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory)]
		[string]$SecretName,
		[string]$VaultName = 'SRSecretStore',
		[PSCredential]$StorePasswordCred,
		[switch]$ShowMetadata
	)

	if ($PSBoundParameters.ContainsKey('StorePasswordCred')) {
		Unlock-SecretStore -Password $StorePasswordCred.Password
	}

	"Get-Secret -Vault '$VaultName' -Name '$SecretName' ..."
	$secret = Get-Secret -Vault $VaultName -Name $SecretName -AsPlainText
	"Received $($secret.Length) chars."

	"Metadata:"
	Get-SecretInfo -Vault $VaultName -Name $SecretName | Select-Object -ExpandProperty Metadata

}


