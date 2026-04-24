# Step 1: Get access token
$loginBody = @{
    username = "admin"
    password = "admin"
    provider = "db"
    refresh  = $true
} | ConvertTo-Json

$loginResponse = Invoke-RestMethod -Uri "http://159.65.7.49:8088/api/v1/security/login" `
    -Method Post `
    -ContentType "application/json" `
    -Body $loginBody

$ACCESS = $loginResponse.access_token
Write-Host "Access token retrieved (starts with): $($ACCESS.Substring(0,20))..."

# Step 2: Get CSRF Token
# We use Invoke-WebRequest to catch the cookies automatically
$csrfResponse = Invoke-WebRequest -Uri "http://159.65.7.49:8088/api/v1/security/csrf_token/" `
    -Method Get `
    -Headers @{ "Authorization" = "Bearer $ACCESS" } `
    -SessionVariable mySession

$CSRF = ($csrfResponse.Content | ConvertFrom-Json).result
Write-Host "CSRF Token retrieved: $CSRF"

# Step 3: Get guest token with NEW username format
$guestBody = @{
    resources = @( @{ type = "dashboard"; id = "2c5b735e-52d0-417b-a6ee-8db9494f187d" } )
    rls = @()
    user = @{
        username   = "role:subtenant:tenant:KAJ:subtenant:BEKASIUTARA"
        first_name = "FOSSIL"
        last_name  = "KAJ"
    }
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://159.65.7.49:8088/api/v1/security/guest_token/" `
    -Method Post `
    -Headers @{ 
        "Authorization" = "Bearer $ACCESS"
        "X-CSRFToken"   = $CSRF
    } `
    -ContentType "application/json" `
    -Body $guestBody `
    -WebSession $mySession