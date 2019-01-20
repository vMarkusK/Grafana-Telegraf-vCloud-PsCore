function Get-BasicAuth {
    param (
        [String]$username,
        [String]$password
    )

    "Basic String: $([Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$($username):$($password)")))"
    
}