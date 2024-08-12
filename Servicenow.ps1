# Variables
$instance = "https://frsdev.servicenowservices.com"
$change_endpoint = "/api/now/table/change_request"
$username = ""
$password = ""

$final_endpoint = "$instance$change_endpoint"

# Convert credentials to a secure string for Basic Auth
$pair = "{0}:{1}" -f $username, $password
$encodedCreds = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($pair))

# Headers
$headers = @{
    'Content-Type' = 'application/json'
    'Accept' = 'application/json'
    'Authorization' = "Basic $encodedCreds"
}

# Payload
$payload = @{
    cmdb_ci = "ATL - ATLANTAFED - DEV"
    u_business_justification = "Enhancement"
    requested_by = "Momolu Sancea"
    type = "Standard"
    priority = "3"
    impact = "2"
    state = "New"
    assignment_group = "FIG-SN-DBA-Support"
    category = "Software"
    subcategory = "Internal Application"
    short_description = "BTS - This is a test API submission $((Get-Random -Minimum 1 -Maximum 99999))"
    description = "BTS - this is a long description"
    justification = "Increase Productivity and meets DevOps Goals"
    implementation_plan = "Configure Azure DEVOPS Pipeline"
    risk_and_impact_analysis = "Please fill out the attached SIA and/or WASS form from DEV to QA - See section 5, QA Ticket Attestation in https://frbprod1.sharepoint.com/sites/6F-BTS-EAS/etPages/Security-User-Story-DAST-LAST.aspx/web-1. SIA is attached. WASS not needed for databases."
    backout_plan = "Remove Pipeline"
    test_plan = "Execute Pipeline and verify connectivity"
    communication_plan = "Notify DevSecOps Agile Team"
} | ConvertTo-Json

try {
    # Invoke the API and get the response
    $response = Invoke-RestMethod -Uri $final_endpoint -Method Post -Headers $headers -Body $payload
    
    # Check if the response contains expected fields
    if ($response -and $response.result) {
        # Ticket creation was successful
        Write-Host "Ticket created successfully."
        
        # Extract the ticket number and sys_id
        $ticketNumber = $response.result.number
        $sysId = $response.result.sys_id
    }
    else {
        Write-Host "Error: The response did not contain expected data."
    }
}
catch {
    # Handle exceptions
    Write-Host "An error occurred while trying to create the ServiceNow ticket."
    
    # If there's an HTTP error, show the status code and details
    if ($_.Exception.Response -ne $null) {
        $streamReader = [System.IO.StreamReader]::new($_.Exception.Response.GetResponseStream())
        $errorResponse = $streamReader.ReadToEnd() | ConvertFrom-Json
        Write-Host "Error Details: $($errorResponse | ConvertTo-Json -Depth 5)"
        
        # If status code is available, show it
        $statusCode = $_.Exception.Response.StatusCode.value__
        Write-Host "Status Code: $statusCode"
        
        if ($statusCode -eq 201) {
            Write-Host "Ticket created successfully."
        }
        else {
            Write-Host "Ticket creation failed."
        }
    }
    else {
        Write-Host "No additional error details available."
    }
}

# Print the ticket number and sys_id at the end
if ($ticketNumber -and $sysId) {
    Write-Host "Ticket Number: $ticketNumber"
    Write-Host "Sys ID: $sysId"
}
else {
    Write-Host "Ticket Number and Sys ID are not available."
}
