## INPUT PARAMETERS  
$ScriptDirectory = "<enter localscript root directory of this ps file - ExecuteSecurityScript.ps1 "  # Eg. "D:\OneDrive - Microsoft\GEM PROJECT\GEMSecurity\GEM.Security\DeploymentFiles"

$TenantId = "<enter GEM Tenant Id>"

$SubscriptionId = "<enter GEM subscription Id>" #TargetSubscriptionIds is same

$Location = "<enter GEM resource location>" # eg. west europe

$ResourceGroupName = "<enter a [New] GEM Scan resource group name>" # name of a new Azure scan resource group to be created eg. GEM-Aware-Final-AZTS

#Create a UserAssignedIdentityName refering the link -  https://learn.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/how-manage-user-assigned-managed-identities?pivots=identity-mi-methods-azp

$UserAssignedIdentityName = ""   # eg. GEM-Aware-Final-AZTS-Scanresults

$SendAlertNotificationToEmailIds = "<enter alert recipient email id>"

#####################

$PSVersionTable

$ExecutionContext.SessionState.LanguageMode

Install-Module -Name Az.Accounts -AllowClobber -Scope CurrentUser -repository PSGallery
Install-Module -Name Az.Resources -AllowClobber -Scope CurrentUser -repository PSGallery
Install-Module -Name Az.Storage -AllowClobber -Scope CurrentUser -repository PSGallery
Install-Module -Name Az.ManagedServiceIdentity -AllowClobber -Scope CurrentUser -repository PSGallery
Install-Module -Name Az.Monitor -AllowClobber -Scope CurrentUser -repository PSGallery
Install-Module -Name Az.OperationalInsights -AllowClobber -Scope CurrentUser -repository PSGallery
Install-Module -Name Az.ApplicationInsights -AllowClobber -Scope CurrentUser -repository PSGallery
Install-Module -Name Az.Websites -AllowClobber -Scope CurrentUser -repository PSGallery
Install-Module -Name Az.Network -AllowClobber -Scope CurrentUser -repository PSGallery
Install-Module -Name Az.FrontDoor -AllowClobber -Scope CurrentUser -repository PSGallery

Install-Module -Name AzureAD -AllowClobber -Scope CurrentUser -repository PSGallery

cd $ScriptDirectory

Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

.".\AzTSSetup.ps1"

Disconnect-AzAccount

Disconnect-AzureAD

Connect-AzAccount -Tenant $TenantId

Connect-AzureAD -TenantId $TenantId

$UserAssignedIdentity = Set-AzSKTenantSecuritySolutionScannerIdentity -SubscriptionId $SubscriptionId -ResourceGroupName $ResourceGroupName -Location $Location UserAssignedIdentityName $UserAssignedIdentityName -TargetSubscriptionIds $SubscriptionId

$UserAssignedIdentity.Id

$UserAssignedIdentity.PrincipalId 

Grant-AzSKGraphPermissionToUserAssignedIdentity -UserAssignedIdentityObjectId $UserAssignedIdentity.PrincipalId -MSGraphPermissionsRequired @("PrivilegedAccess.Read.AzureResources", "Directory.Read.All") -ADGraphPermissionsRequired @("Directory.Read.All")

$HostSubscriptionId = $SubscriptionId

$HostResourceGroupName = $ResourceGroupName

$AzureEnvironmentName = 'AzureCloud'

$ADApplicationDetails = Set-AzSKTenantSecurityADApplication -SubscriptionId $HostSubscriptionId -ScanHostRGName $HostResourceGroupName -AzureEnvironmentName $AzureEnvironmentName

$ADApplicationDetails.WebAPIAzureADAppId

$ADApplicationDetails.UIAzureADAppId 

Set-AzContext -SubscriptionId $SubscriptionId
#login prompt 
Connect-AzAccount -TenantId $TenantId

Set-AzContext -SubscriptionId $SubscriptionId

Disconnect-AzAccount

Disconnect-AzureAD

#login prompt
Connect-AzAccount -TenantId $TenantId

Set-AzContext -SubscriptionId $SubscriptionId

$DeploymentResult = Install-AzSKTenantSecuritySolution -SubscriptionId $SubscriptionId -ScanHostRGName $ResourceGroupName -Location $Location -ScanIdentityId $UserAssignedIdentity.Id -SendAlertNotificationToEmailIds $SendAlertNotificationToEmailIds -Verbose

Start-AzSKTenantSecuritySolutionOnDemandScan -SubscriptionId $HostSubscriptionId -ScanHostRGName $HostResourceGroupName


#once completed 
# you can query the results 