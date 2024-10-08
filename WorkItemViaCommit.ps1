Param(
   [string]$organization = "OrgOneTestDemo",          # Azure DevOps organization name
   [string]$project = "ProjectOne",                   # Azure DevOps project name
   [string]$repositoryId = "TestRepoOne",             # Azure DevOps repository ID
   [string]$branchName = "main",         
   [string]$token = ""  
   
)

# Base64-encode the PAT for authorization
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$token"))

# Construct the API URL to get commit details
$commitUrl = "https://tfs.clev.frb.org/$organization/$project/_apis/git/repositories/$repositoryId/commits?searchCriteria.includeWorkItems=true&api-version=7.1-preview.1"

try {
    # Make the API call to get commit details
    $response = Invoke-RestMethod -Uri $commitUrl -Method Get -Headers @{Authorization=("Basic $base64AuthInfo")}

    # Check if the response is empty
    if (-not $response.value) {
        Write-Host "No commits found with linked work items."
        return
    }

    # Loop through commits and fetch only those with linked work items
    foreach ($commit in $response.value | Sort-Object -Property date -Descending | Select-Object -First 1) {
        if ($commit.workItems) {
            Write-Host "Commit ID: $($commit.commitId)"
            Write-Host "Author: $($commit.author.name)"
            Write-Host "Date: $($commit.author.date)"
            Write-Host "Comment: $($commit.comment)"

            foreach ($workItem in $commit.workItems) {
                # Retrieve detailed work item information
                $workItemDetailsUrl = "$($workItem.url)?api-version=7.0"
                $workItemDetails = Invoke-RestMethod -Uri $workItemDetailsUrl -Method Get -Headers @{Authorization=("Basic $base64AuthInfo")}

                # Remove HTML tags from the description
                $description = $workItemDetails.fields.'System.Description' -replace '<[^>]+>', ''

                # Display relevant work item fields
                $workItemObj = [PSCustomObject]@{
                    "WitID"        = $workItemDetails.id
                    "rev"          = $workItemDetails.rev
                    "Title"        = $workItemDetails.fields.'System.Title'
                    "AssignedTo"   = $workItemDetails.fields.'System.AssignedTo'.displayName
                    "ChangedDate"  = $workItemDetails.fields.'System.ChangedDate'
                    "ChangedBy"    = $workItemDetails.fields.'System.ChangedBy'.uniqueName
                    "WorkItemType" = $workItemDetails.fields.'System.WorkItemType'
                    "Priority"     = $workItemDetails.fields.'Microsoft.VSTS.Common.Priority'
                    "Description"  = $description
                    "Iteration"    = $workItemDetails.fields.'System.IterationPath'
                    "Discussion"   = $workItemDetails.fields.'System.History'

                }

                $workItemObj | Format-List
            }
        } else {
            Write-Host "No linked work items found for the latest commit."
        }
    }
} catch {
    Write-Host "An error occurred: $($_.Exception.Message)"
    
}
