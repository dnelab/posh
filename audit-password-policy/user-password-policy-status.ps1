try {
    Get-MsolDomain -ErrorAction Stop > $null
} catch {
    if($msolcred -eq $null) {
	    $msolcred = get-credential
    }

    if($msol_session -eq $null) {
        write-host "Connecting to office 365..."
        Import-Module MSOnline
        $msol_session = Connect-MsolService -Credential $msolcred
    }
}

#### domain policy ####
$domain = $msolcred.UserName.Split("@")[1]
$policy = Get-MsolPasswordPolicy -DomainName $domain
$warn = if($policy.NotificationDays -eq $null) {14} else {$policy.NotificationDays}
$old = if($policy.ValidityPeriod -eq $null) {90} else {$policy.ValidityPeriod}

#### user ####
$upn = Read-Host -Prompt "User (ex: pierre)?"
$user = Get-MsolUser -UserPrincipalName "$upn@$domain"

Write-Host $user.DisplayName ":" -ForegroundColor DarkYellow
Write-Host "----------------------------------------------------------" -ForegroundColor DarkYellow

$expires = if($policy.ValidityPeriod -gt 1000) {"no"} else { "$old days"}
$age =  ((Get-Date) - ($user.LastPasswordChangeTimestamp)).TotalDays
$blocked = if($user.BlockCredential){"is"}else{"isn't"}
$remaining = $old - $age
$warn_remaining = $remaining - $warn

Write-Host " - global password expiration policy : $expires"
Write-Host " - password is $age days old"
Write-Host " - account $blocked blocked"
if($user.PasswordNeverExpires) {
    Write-Host " - password never expires flag is set"
}
Write-Host " - password expires in $remaining days"
Write-Host " - user will be warned in $warn_remaining days"

### expire ?
