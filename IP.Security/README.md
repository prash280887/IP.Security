# Introduction 
This is a GEM Security project created for running and generating security scan report for GEM MDP Azure Environemnt.

# Steps to execute 

- Downlaod/Clone the Repo - GEM.Security in local machine.system
- Open the file from the path \DeploymentFiles\ **ExecuteSecurityScan.ps1** in Windows Powershell  (in Admin mode) in your system.
- Read the top section in the .ps1 file (i.e _##INPUT PARAMETERS##_ section ) and modify the values of target Azure Environment parameters as instructed under this section.
 . Add the UserAssignedIdentityName value to in the powershell script parameter $UserAssignedIdentityName  ( example value is- GEM-Aware-Final-AZTS-Scanresults-xx)
- Once all parameter values are set , run the ExecuteSecurityScan.ps1 
- NOTE - During the script execution you will be prompted multiple times to login to the target Azure Server environment with admin login. Provide your azure admin credentials in the popups to login to the target subscription and tenant where scan needs to run.
        Provide N for these following prompts:
        Allow collection of anonymized usage data (Y/N): N
        Provide org/team contact info (Y/N): N
- Once script runs succesfully , goto Azure portal and open the new Azure Log Analytics Workspace (eg. AzSK-AzTS-LAWorkspace-XXXX ) created in the new Security Resource Group (eg. GEM-DP-FINAL-AZTS )
- In the Azure Log Analytics Workspace , goto Logs section and run the below query to display the Security Scan results 

AzSK_ControlResults_CL
| where TimeGenerated > ago(2d) 
| where JobId_d == toint(format_datetime(now(), 'yyyyMMdd'))
| summarize arg_max(TimeGenerated, *) by SubId = tolower(SubscriptionId), RId= tolower(ResourceId), ControlName_s
| where VerificationResult_s != "Passed" and VerificationResult_s !="NotApplicable"

- Click _Export_ Button and choose to option  _CSV (all columns)_  to download the result as csv. 
- Analyse the csv results , take necssary actions accordingly as per the security reasons mentioned in columns **StatusReason_s** . 
- NOTE : The scan runs on all resources in subscription , hence you can view security results based on relevant resources by filtering columns like -  **ResourceGroupName_s** ,**ResourceName_s** , **ControlName_s** , **SubscriptionId** etc.
  
  CleanUp:
  After exporting the sheet,delete the entire resource group.

# Other Notes 
Refer external source docs for reference as provided by infosec team [here](https://github.com/azsk/AzTS-docs/tree/main/01-Setup%20and%20getting%20started) 
