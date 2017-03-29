if($UserCredential -eq $null) {
    $UserCredential = Get-Credential
}

if($Session -eq $null) {
    $Session = New-CsOnlineSession -Credential $UserCredential -Verbose
    Import-PSSession $Session
}
#Get-CsOAuthConfiguration
Set-CsOAuthConfiguration -ClientAdalAuthOverride Allowed
Get-CsOAuthConfiguration