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


# Invoke the API
$response = Invoke-RestMethod -Uri $final_endpoint -Method Post -Headers $headers -Body $payload

# Output the response
$response | ConvertTo-Json -Depth 5

# Extract the ticket number
$ticketNumber = $response.result.number
$sysId = $response.result.sys_id

# Print the ticket number and sys_id
Write-Host "Ticket Number: $ticketNumber"
Write-Host "Sys ID: $sysId"
