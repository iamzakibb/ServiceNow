# Parameters
Param(
   [string]$organization = "OrgOneTestDemo",          # Azure DevOps organization name
   [string]$project = "ProjectOne",                   # Azure DevOps project name
   [string]$repositoryId = "TestRepoOne",             # Azure DevOps repository ID
   [string]$branchName = "main",                      # Branch to inspect
   [string]$token = ""  # Personal Access Token (PAT)
)

# Base64-encode the PAT for authorization
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$token"))

# Construct the API URL to get commits with associated work items
$commitUrl = "https://dev.azure.com/$organization/$project/_apis/git/repositories/$repositoryId/commits?searchCriteria.includeWorkItems=true&api-version=7.1-preview.1"

# Make the API call to get commit details
$response = Invoke-RestMethod -Uri $commitUrl -Method Get -Headers @{Authorization=("Basic $($base64AuthInfo)")}

# Loop through commits and fetch only those with linked work items
foreach ($commit in $response.value) {
    if ($commit.workItems) {
        Write-Host "Commit ID: $($commit.commitId)"
        Write-Host "Author: $($commit.author.name)"
        Write-Host "Date: $($commit.author.date)"
        Write-Host "Comment: $($commit.comment)"

        foreach ($workItem in $commit.workItems) {
            # Retrieve detailed work item information
            $workItemDetailsUrl = $workItem.url + "?api-version=7.0"
            $workItemDetails = Invoke-RestMethod -Uri $workItemDetailsUrl -Method Get -Headers @{Authorization=("Basic $($base64AuthInfo)")}

            # Remove HTML tags from the description
            $description = $workItemDetails.fields.'System.Description' -replace '<[^>]*>', ''

            # Display relevant work item fields
            [PSCustomObject]@{
                "WitID"          = $workItemDetails.id
                "rev"            = $workItemDetails.rev
                "Title"          = $workItemDetails.fields.'System.Title'
                "AssignedTo"     = $workItemDetails.fields.'System.AssignedTo.displayName'
                "ChangedDate"    = $workItemDetails.fields.'System.ChangedDate'
                "ChangedBy"      = $workItemDetails.fields.'System.ChangedBy.displayName'
                "WorkItemType"   = $workItemDetails.fields.'System.WorkItemType'
                "Priority"       = $workItemDetails.fields.'Microsoft.VSTS.Common.Priority'
                "Description"    = $description
                "IterationPath"  = $workItemDetails.fields.'System.IterationPath'
                "AssignedToEmail" = $workItemDetails.fields.'System.AssignedTo'.uniqueName
                          } 
        }
        Write-Host "----------------------------------"
    }
}
