# Variables
$organization = "OrgOneTestDemo"  # Replace with your Azure DevOps organization name
$project = "ProjectOne"            # Replace with your Azure DevOps project name
$repositoryId = "TestRepoOne"      # Replace with your Azure DevOps repository ID or name
$branchName = "main"               # The branch you want to inspect (e.g., 'main')
$pat = ""  # Replace with your Personal Access Token

# Base64-encoded PAT for authorization
$encodedPat = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($pat)"))

# Headers
$headers = @{
    Authorization = "Basic $encodedPat"
}

# REST API endpoint to get the latest commit in the main branch
$uri = "https://dev.azure.com/$organization/$project/_apis/git/repositories/$repositoryId/commits?searchCriteria.itemVersion.version=$branchName&searchCriteria.$top=1&api-version=6.0"

# Make the API call to get the latest commit
$response = Invoke-RestMethod -Uri $uri -Method Get -Headers $headers

# Extract commit details
$commit = $response.value[0]  # Since we're only retrieving one commit, take the first entry

# Display commit details
Write-Host "Commit ID: $($commit.commitId)"
Write-Host "Author: $($commit.author.name)"
Write-Host "Date: $($commit.author.date)"
Write-Host "Comment: $($commit.comment)"

# REST API endpoint to get linked work items for the commit
$workItemsUri = "https://dev.azure.com/$organization/$project/_apis/git/repositories/$repositoryId/commits/$($commit.commitId)/workItems?api-version=7.0"

# Make the API call to get linked work items
$workItemsResponse = Invoke-RestMethod -Uri $workItemsUri -Method Get -Headers $headers

# Loop through each linked work item and retrieve details
foreach ($workItem in $workItemsResponse.value) {
    # Extract work item ID
    $workItemId = $workItem.id

    # REST API endpoint to get work item details
    $workItemDetailsUri = "https://dev.azure.com/$organization/$project/_apis/wit/workitems/$workItemId?api-version=7.0"
    
    # Make the API call to get work item details
    $workItemDetails = Invoke-RestMethod -Uri $workItemDetailsUri -Method Get -Headers $headers
    
    # Extract and display relevant fields
    $priority = $workItemDetails.fields.'Microsoft.VSTS.Common.Priority'
    $title = $workItemDetails.fields.'System.Title'
    $description = $workItemDetails.fields.'System.Description'
    $assignedTo = $workItemDetails.fields.'System.AssignedTo'.displayName

    Write-Host "`nWork Item ID: $workItemId"
    Write-Host "Priority: $priority"
    Write-Host "Title: $title"
    Write-Host "Description: $description"
    Write-Host "Assigned To: $assignedTo"
    Write-Host "----------------------------------------"
}
